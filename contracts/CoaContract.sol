pragma solidity ^0.5.0;

import "./AdministrativeContract.sol";

/**
 * Contract handling the exchange of CoAs
 */
contract CoaContract {

    address public owner;

    // the identity management
    AdministrativeContract idm;

    // event is emitted for each new request
    event Requested(uint reqNumber, address sender, address receiver);

    // event is emitted when all items of a coa request are answered
    event CoaClosed(uint reqNumber, address sender, address receiver);

    // the CoA request data structure
    struct Request{
        bytes data;         // the encrypted data
        address sender;     // the sender of the CoA request
        address receiver;   // the receiver of the CoA request
        uint[] amount;      // the amounts for each invoice position
    }

    // the CoA
    struct CoA{
        uint[] amount; // the reported amount for each invoice position
    }

    // the CoA requests
    mapping(uint => Request) requests;

    // the CoAs
    mapping(uint => CoA) coas;

    // the number of requests issued
    uint reqNumber = 0;

    /**
     * the constructor of the CoA Exchange contract
     * @param _idm the address of the identity management contract
     */
    constructor(address _idm) public {
        owner = msg.sender;
        idm = AdministrativeContract(_idm);
    }

    /**
     * create a new request
     * @param _data       the encrypted data of the request
     * @param _receiver   the receiver of the request
     * @param _amount     the amounts of each invoice position
     */
    function newRequest(bytes memory _data, address _receiver, uint[] memory _amount) public returns (uint){
        require(idm.isValid(msg.sender), "requester invalid");
        require(idm.isValid(_receiver), "receiver invalid");
        requests[reqNumber].data = _data;
        requests[reqNumber].sender = msg.sender;
        requests[reqNumber].receiver = _receiver;
        requests[reqNumber].amount = _amount;
        coas[reqNumber].amount = _amount;

        for(uint i = 0; i<_amount.length; i++){
            coas[reqNumber].amount[i] = 0;
        }

        emit Requested(reqNumber, msg.sender, _receiver);
        reqNumber++;
        return reqNumber;
    }

    /**
     * create a CoA (answer)
     * @param _requestNumber  the number of the request to answer
     * @param _amount         the reported amounts
     */
    function answer(uint _requestNumber, uint[] memory _amount) public {
        require(_requestNumber < reqNumber, "request id invalid");
        require(requests[_requestNumber].receiver == msg.sender, "not authorized to answer coa request");

        Request memory request = requests[_requestNumber];
        CoA memory coa = coas[_requestNumber];

        bool closed = true;
        for(uint i = 0; i<_amount.length; i++){
            require(request.amount[i] >= coa.amount[i] + _amount[i], "coa exceeds amount bounds");
            coas[_requestNumber].amount[i] = coa.amount[i] + _amount[i];
            closed = closed && (coas[_requestNumber].amount[i]==request.amount[i]);
        }

        if(closed){
            emit CoaClosed(_requestNumber, request.receiver, request.sender);
        }
    }

    /**
     * returns the data of a given request
     * @param requestid the id of the request
     * @return the encrypted data, the request sender, the receiver of the request, the amounts of the request
     */
    function getRequest(uint requestid) public view returns(bytes memory, address, address, uint[] memory) {
        return (requests[requestid].data,requests[requestid].sender, requests[requestid].receiver, requests[requestid].amount);
    }
}

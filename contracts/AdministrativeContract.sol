pragma solidity ^0.5.0;

/**
 * Identity Management Contract
 */
contract AdministrativeContract {

    // the contract owner (e.g. the authority)
    address public owner;

    // the existing roles
    enum Role {Authority, Auditor, Business, None}

    // address maps to true if the address is registered
    mapping(address => bool) public valid;

    // maps vat ids (uint) to the corresponding address
    mapping(uint => address) vatidMap;

    // assigns a role to each address
    mapping(address => Role) permissionMap;

    // assigns a public encryption key to each address
    mapping(address => bytes32) ECIESpk;

    /**
    * the constructor of the contract
    */
    constructor() public {
        owner = msg.sender;         // the owner is the message sender
        valid[msg.sender] = true;   // the address of the owner is valid
        permissionMap[msg.sender] = Role.Authority; //the owner has the authority role
    }

    /**
    * modifier that ckes the validity of the address as well as the role of the msg.sender
    */
    modifier onlyBy(Role _role)
    {
        require(valid[msg.sender], "not authorized");
        require(permissionMap[msg.sender] == _role, "unsufficient permissions");
        _;
    }

    /**
    * register a new business
    * a business can only be added by an authority
    * @param vatid   the vat id to register
    * @param pk_sig  the address of the business (used for authorization)
    * @param pk_enc  256 bit public encryption key
    */
    function addBusiness(uint vatid, address pk_sig, bytes32 pk_enc) public onlyBy(Role.Authority){
        require(valid[pk_sig] == false && vatidMap[vatid] == address(0), "address already registered");
        valid[pk_sig] = true;
        vatidMap[vatid] = pk_sig;
        permissionMap[pk_sig] = Role.Business;
        ECIESpk[pk_sig] = pk_enc;
    }

    /**
     * revoke the vat id of a business
     * @param vatid the vat id to revoke
     */
    function revokeBusiness(uint vatid) public onlyBy(Role.Authority){
        address adr = vatidMap[vatid];
        require(valid[adr] && (permissionMap[adr]==Role.Business), "vat id cannot be revoked");
        valid[adr] = false;
        vatidMap[vatid] = address(0);
        permissionMap[adr] = Role.None;
    }

    /**
     * checks if the address belongs to a valid business
     * @param adr the address to check
     * @return true if the address is valid else false
     */
    function isValid(address adr) public view returns (bool) {
        return valid[adr] && (permissionMap[adr] == Role.Business);
    }
}
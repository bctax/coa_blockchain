var CoaContract = artifacts.require("./CoaContract.sol");
var AdministrativeContract = artifacts.require("./AdministrativeContract.sol");
const truffleAssert = require('truffle-assertions');

contract('CoA Exchange Contract Test', async(accounts) => {
    let authority = accounts[0]; // the authority address
    let company1 = accounts[1]; // company 1 address
    let company2 = accounts[3]; // company 2 address

    let company1Vatid = 1056; // company 1 vat id
    let company2Vatid = 1057; // company 2 vat id

    //the public keys of both companies
    let company1Key = "0x49c7e43c42e28e74e31abbb02534d2a383ec42df5ae41a7cf9da1e74dfc0226a";
    let company2Key = "0x6c28fe8254578df519e3391b1f8801c62be85f7eda83496b5689197d58c3011a";

    /**
     * executed before the tests, registers two sample companies (company1, company2)
     */
    before("setup", async function() {
        let idm = await AdministrativeContract.deployed();
        await idm.addBusiness(company1Vatid, company1, company1Key);
        await idm.addBusiness(company2Vatid, company2, company2Key);
    });

    /**
     * company 1 creates a coa request for company 2.
     * company 2 splits up the coa answer into two reports.
     * checks if the CoaClosed Event is emmited in this case.
     */
    it("normal coa exchange", async() => {
        let instance = await CoaContract.deployed();

        // create a new coa request
        let res = await instance.newRequest("0x98653a", company2, [10,20], {from:company1});

        //checks if the requested event is emitted
        truffleAssert.eventEmitted(res, "Requested", (ev)=>{
            return ev.sender==company1 && ev.receiver==company2;
        }, "receiver or sender of request event are incorrect");

        // get the assigned request number
        let reqNumber = parseInt(res.logs[0].args.reqNumber, 10);
        

        // answers the coa request using two coa reports
        res = await instance.answer(reqNumber, [9,10], {from:company2});
        res = await instance.answer(reqNumber, [1,10], {from:company2});

        // checks if finally the coa is closed, i.e. the CoaClosed event is emitted
        truffleAssert.eventEmitted(res, "CoaClosed", (ev)=>{
            return ev.sender==company2 && ev.receiver == company1;
        }, "receiver or sender of CoaClosed event are incorrect");
    });

    /**
     * checks if the CoAClosed event is NOT emitted if the reported amounts do not match the request
     */
    it("unfinished exchange", async() => {
        let instance = await CoaContract.deployed();

        // compan 1 requests a coa from company 2
        let res = await instance.newRequest("0x98653a", company2, [10,20], {from:company1});
        truffleAssert.eventEmitted(res, "Requested", (ev)=>{
            return ev.sender==company1 && ev.receiver==company2;
        }, "reiver or sender of request event are incorrect");

        // get the request number
        let reqNumber = parseInt(res.logs[0].args.reqNumber, 10);

        // company 2 does not report the full amounts
        res = await instance.answer(reqNumber, [9,10], {from:company2});

        // check that the CoAClosed event is not emitted
        truffleAssert.eventNotEmitted(res, "CoaClosed", (ev)=>{return true;}, "should not emit Coa Closed");
    });
});
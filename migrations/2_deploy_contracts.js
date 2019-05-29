var AdministrativeContract = artifacts.require("./AdministrativeContract.sol");
var CoaContract = artifacts.require("./CoaContract.sol");


module.exports = function(deployer) {
    deployer.deploy(AdministrativeContract).then(function() {
        return deployer.deploy(CoaContract, AdministrativeContract.address);
      });
};
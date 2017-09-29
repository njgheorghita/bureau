var Client = artifacts.require("./Client.sol");
var Org = artifacts.require("./Org.sol");
var Bureau = artifacts.require("./Bureau.sol");
var Loan = artifacts.require("./Loan.sol");

module.exports = function(deployer) {
  deployer.deploy(Org);
  deployer.deploy(Client);
  deployer.deploy(Bureau);
  deployer.deploy(Loan);
};

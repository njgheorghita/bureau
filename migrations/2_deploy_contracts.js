var Client = artifacts.require("./Client.sol");
var Org = artifacts.require("./Org.sol");
var Bureau = artifacts.require("./Bureau.sol");
// var Loan = artifacts.require("./Loan.sol");
var Controller = artifacts.require("./Controller.sol");
var Ballot = artifacts.require("./Ballot.sol");

module.exports = function(deployer) {
  // deployer.deploy(Org);
  // deployer.deploy(Client);
  deployer.deploy(Bureau);
  // deployer.deploy(Loan);
  // deployer.deploy(Ballot);
  deployer.deploy(Controller);
};

var Client = artifacts.require("./Client.sol");
var Org = artifacts.require("./Org.sol");

module.exports = function(deployer) {
  deployer.deploy(Org);
  deployer.deploy(Client);
};

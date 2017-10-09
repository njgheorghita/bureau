var Bureau = artifacts.require("./Bureau.sol");
var Controller = artifacts.require("./Controller.sol");

module.exports = function(deployer) {
  deployer.deploy(Bureau).then(function() {
    return deployer.deploy(Controller, Bureau.address)
  });
};

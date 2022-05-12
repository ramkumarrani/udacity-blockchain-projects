// migrating the appropriate contracts
var ERC721MintableComplete = artifacts.require("ERC721MintableComplete");

module.exports = function(deployer) {
  deployer.deploy(ERC721MintableComplete, "RR_ERC721MintableToken", "RRTOK")
};

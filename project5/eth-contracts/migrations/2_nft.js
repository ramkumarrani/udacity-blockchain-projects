// migrating the appropriate contracts
var ERC721MintableComplete = artifacts.require("RRERC721Token.sol");
var SquareVerifier  = artifacts.require("Verifier.sol");
var SolnSquareVerifier = artifacts.require("./SolnSquareVerifier.sol");

module.exports = function(deployer) {
  deployer.deploy(ERC721MintableComplete, "RR_ERC721MintableToken", "RRTOK");
  deployer.deploy(SquareVerifier);
  deployer.deploy(SolnSquareVerifier, "RR_ERC721MintableToken", "RRTOK");
};

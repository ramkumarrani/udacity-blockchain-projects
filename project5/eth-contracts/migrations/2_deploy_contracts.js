// migrating the appropriate contracts
var SquareVerifier = artifacts.require("Verifier");
var SolnSquareVerifier = artifacts.require("SolnSquareVerifier");

module.exports = async(deployer) => {
    await deployer.deploy(SquareVerifier);
    await deployer.deploy(SolnSquareVerifier, "RR ERC721 Mintable Token", "RR_721");
}

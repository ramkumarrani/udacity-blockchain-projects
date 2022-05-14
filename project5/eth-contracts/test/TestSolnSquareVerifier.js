const SolnVerifier = artifacts.require("SolnSquareVerifier");
const truffleAssertions = require("truffle-assertions");
const Proof = require("../../zokrates/code/square/proof.json");

contract('solnSquareVerifier', accounts => {
    const name = "SSVToken";
    const symbol = "SSVT";

    before(async() => {
        solnSquareVerifierInstance = await SolnVerifier.new(name, symbol, {from: accounts[0]});
    });

    // Test if a new solution can be added for contract - SolnSquareVerifier
    // Test if an ERC721 token can be minted for contract - SolnSquareVerifier
    it('mint a token and add a solution', async() => {
        let result;

        result = await solnSquareVerifierInstance.mintNewNFT(
            accounts[1],
            0,
            Proof.proof.A,
            Proof.proof.A_p,
            Proof.proof.B,
            Proof.proof.B_p,
            Proof.proof.C,
            Proof.proof.C_p,
            Proof.proof.H,
            Proof.proof.K,
            Proof.input
        );
        assert.equal(result.logs[0].event, "Transfer");
        assert.equal(result.logs[1].event, "AddSolution");
    });
});

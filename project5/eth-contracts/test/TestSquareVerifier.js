const Verifier = artifacts.require("Verifier");
const Proof = require("../../zokrates/code/square/proof.json");

contract('TestSquareVerifier', accounts => {
    before(async() => {
        contractInstance = await Verifier.new({from: accounts[0]});
    });

    it('Test verification with correct proof', async() => {
        const isVerified = await contractInstance.verifyTx.call(
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
        assert.equal(isVerified, true, "error: zokrates proof failed")
    });

    it('Test verification with incorrect proof', async() => {
        const isVerified = await contractInstance.verifyTx.call(
            Proof.proof.A,
            Proof.proof.A_p,
            Proof.proof.B,
            Proof.proof.B_p,
            Proof.proof.C,
            Proof.proof.C_p,
            Proof.proof.H,
            Proof.proof.K,
            [4,9] //Proof.input
        );
        assert.equal(isVerified, false, "error: zokrates error with invalid proof")
    });
});
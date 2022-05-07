// this script is used to mint tokens
const Web3 = require("web3");
const HDWalletProvider = require('truffle-hdwallet-provider');
const infuraKey = "52e....";

const Proof = require("../zokrates/code/square/proof.json");

// fetching mnemonic
const fs = require('fs');
const mnemonic = fs.readFileSync(".secret").toString().trim();

// owners
const solnSquareVerifier = "0x1D1609fe1f37E9B5Bb05799f746524d8Ee9350F1";
const contractOwner = "0x75A6D4e12A7ec11a3C6A7C5361DA50Dadc196c47";

// reading SolnSquareVerifier interface
const solnSquareInterface = JSON.parse (
    fs.readFileSync("./build/contracts/SolnSquareVerifier.json")
);

// read 1st arguments
const inArgs = process.argv[2];
const NUM_TOKENS = Number(inArgs);

const provider = new HDWalletProvider (
    mnemonic,
    `https://rinkeby.infura.io/v3/${infuraKey}`
);

const web3 = new Web3(provider);

const main = async() => {

    const contract = new web3.eth.Contract(
        solnSquareInterface.abi,
        solnSquareVerifier,
        {
            from: contractOwner
        }
    );

    for(let i=0; i < NUM_TOKENS; i++) {
        const result = await contract.methods.mintNewNFT(
            contractOwner,
            i,
            Proof.proof.A,
            Proof.proof.A_p,
            Proof.proof.B,
            Proof.proof.B_p,
            Proof.proof.C,
            Proof.proof.C_p,
            Proof.proof.H,
            Proof.proof.K,
            Proof.input
        )
        .send({from: contractOwner});

        console.log(`Minted token ${i}, Tx Hash ${result.transactionHash}`);
    }
    process.exit();
}

console.log("....complete....", NUM_TOKENS);

main();

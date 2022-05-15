# Ethereum Real Estate Marketplace Dapp

This is a Decentralized App used to manage Real Estate from house owner's point of view. Broadly, this project consists of following major steps:

1. Every property is minted as a ERC721 NFT
2. Property deed (title) privacy is managed using zero-proof concept, utilizing zk-SNARK built on ZoKrates
3. Smart Contract is used to manage property ownershp
4. NFT marketplace OpenSea is used to list and transfer the properties

# Project Structure

This repository consists of:

* Smart contracts
* ZoKrates folder to manage title privacy
* Mocha unit testing
* OpenSea listing

# Project Implementation

## Project Installations

This project has been created using following blockchain components:

* Truffle v5.4.30
* Solidity 0.5.1
* Node 14.17.6
* web3.js 1.5.3

To build the application, you can run following commands: `npm install`

## Development

For development, run following commands:

```
truffle compile
truffle migrate
truffle test
```

## Generate ZoKrates verifier.sol

* Run following docker command: `docker run -v <project path>:/home/zokrates/code -it /zokrates/zokrates /bin/bash`
* Create base program: square.code 
* Compile program: ./zokrates compile -i square.code
* Generate trusted set up: ./zokrates setup
* Compute witness: ./zokrates compute-witness -a 2 4
* Generate proof: ./zokrates generate-proof
* Export verifier: ./zokrates export-verifier
* rename verifier.sol to Verifier.sol
* copy Verifier.sol to contracts folder: eth-contracts/contracts

## Contract Deployment on Rinkeby

Run following command to deploy Smart contract on Rinkeby test public network: `truffle migrate --network rinkeby`

The following gives details on Rinkeby deployed contracts:

```
Deploying 'RRERC721Token'
-------------------------
transaction hash:    0x24cf772dcbf83d51d61ed8445777bcf07e07a13a8ffc0622a234cc834b7edd46
contract address:    0xAC03af1Bf77C0ab007ba553366E0f3267f6DA67F
account:             0x75A6D4e12A7ec11a3C6A7C5361DA50Dadc196c47

Deploying 'Verifier'
--------------------
transaction hash:    0x7c176887d3fa29611c72e6e6d6f9e10efd2cd2cdc55fb1c2ecb31a553d24c63a
contract address:    0x34Fab9C775497906DCDDD8e18764f00f8EAcc393
account:             0x75A6D4e12A7ec11a3C6A7C5361DA50Dadc196c47

Deploying 'SolnSquareVerifier'
------------------------------
transaction hash:    0x45eec427ae5a0dab28b40cb7421b21d506fecda4f2dbf65035b9a8c57978b479
contract address:    0xe93d81C94e2f431061b8DA1D4D6C3d5A67d5510E
account:             0x75A6D4e12A7ec11a3C6A7C5361DA50Dadc196c47
```
URLs:<br>
&nbsp;&nbsp;&nbsp;&nbsp;[ERC721 Token](https://rinkeby.etherscan.io/tx/0x24cf772dcbf83d51d61ed8445777bcf07e07a13a8ffc0622a234cc834b7edd46)<br>
&nbsp;&nbsp;&nbsp;&nbsp;[Verifier](https://rinkeby.etherscan.io/tx/0x7c176887d3fa29611c72e6e6d6f9e10efd2cd2cdc55fb1c2ecb31a553d24c63a)<br>
&nbsp;&nbsp;&nbsp;&nbsp;[SolnSquareVerifier](https://rinkeby.etherscan.io/tx/0x45eec427ae5a0dab28b40cb7421b21d506fecda4f2dbf65035b9a8c57978b479)

## Unit Test Results

You can run unit test using `truffle test`.  This will run unit test for 3 components: `ERC721 Token`, `Verifier`, and `SolnSquareVerifier`.  

The unit test has cleared all 3 components and its results are:

<img src="https://github.com/ramkumarrani/udacity-blockchain-projects/blob/master/project5/eth-contracts/output/AllUnitTest.PNG" />

## Mint 10 Tokens

You can use following commands to mint tokens:

```
cd eth-contracts
node mintTokens.js 10
```

Output:<br><br>
```
Token 0 minted, Tx Hash 0x8bc987a027351a7fe7b0b8e5030902dffb68c2405f7504b491e3e2260496c893
Token 1 minted, Tx Hash 0x4fa10af54fd1e905b9ce832f67579d3c689e1d0daf504bc4f54b4e3f4e08bbe8
Token 2 minted, Tx Hash 0x2110a81b3e5eaba7b9d80141216861118921fa4c6cb8de6406295d8d0cf57269
Token 3 minted, Tx Hash 0x048b37c908416aab64e0d0480c4672f85e54f332c608e0a2f74a03c97d00d7e2
Token 4 minted, Tx Hash 0x52a68a6836c5251d0d8c7c9469877490a1384b72d06b5f80c6e5f6f0457b2170
Token 5 minted, Tx Hash 0x33540540a3bc7f0fa3f72a08d77e0ec0b41a7d8e26d8bdc262c9acad46173b74
Token 6 minted, Tx Hash 0xb4abe462e73cb3a4625c0fbd88c2372170eb1ba771d702b5cca033ae420e5518
Token 7 minted, Tx Hash 0x1245a02c81a972b16616196c5da8f49da6a1d77846c752bc92fa5f4eae6932d3
Token 8 minted, Tx Hash 0x473553e4a0de0c1e7fca1fc9ee1d119c665e373d9f5d2967d378b2b5b2268005
Token 9 minted, Tx Hash 0xfdf49ffe13636196916041fa938d323d2959ddca3d0336f2d8360fde7dea7999
```
<br>
<img src="https://github.com/ramkumarrani/udacity-blockchain-projects/blob/master/project5/eth-contracts/output/tokensMinted-10.PNG" />

# Project Resources

* [Remix - Solidity IDE](https://remix.ethereum.org/)
* [Visual Studio Code](https://code.visualstudio.com/)
* [Truffle Framework](https://truffleframework.com/)
* [Ganache - One Click Blockchain](https://truffleframework.com/ganache)
* [Open Zeppelin ](https://openzeppelin.org/)
* [Interactive zero knowledge 3-colorability demonstration](http://web.mit.edu/~ezyang/Public/graph/svg.html)
* [Docker](https://docs.docker.com/install/)
* [ZoKrates](https://github.com/Zokrates/ZoKrates)

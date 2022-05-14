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
URL: https://rinkeby.etherscan.io/tx/0x24cf772dcbf83d51d61ed8445777bcf07e07a13a8ffc0622a234cc834b7edd46

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
URLs:
(https://rinkeby.etherscan.io/tx/0x24cf772dcbf83d51d61ed8445777bcf07e07a13a8ffc0622a234cc834b7edd46 "ERC721 Token")

# Project Resources

* [Remix - Solidity IDE](https://remix.ethereum.org/)
* [Visual Studio Code](https://code.visualstudio.com/)
* [Truffle Framework](https://truffleframework.com/)
* [Ganache - One Click Blockchain](https://truffleframework.com/ganache)
* [Open Zeppelin ](https://openzeppelin.org/)
* [Interactive zero knowledge 3-colorability demonstration](http://web.mit.edu/~ezyang/Public/graph/svg.html)
* [Docker](https://docs.docker.com/install/)
* [ZoKrates](https://github.com/Zokrates/ZoKrates)

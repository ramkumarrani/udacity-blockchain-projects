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

`truffle compile`<br />
`truffle migrate`<br />
`truffle test`

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
ramkumar rani
i am good
```

# Project Resources

* [Remix - Solidity IDE](https://remix.ethereum.org/)
* [Visual Studio Code](https://code.visualstudio.com/)
* [Truffle Framework](https://truffleframework.com/)
* [Ganache - One Click Blockchain](https://truffleframework.com/ganache)
* [Open Zeppelin ](https://openzeppelin.org/)
* [Interactive zero knowledge 3-colorability demonstration](http://web.mit.edu/~ezyang/Public/graph/svg.html)
* [Docker](https://docs.docker.com/install/)
* [ZoKrates](https://github.com/Zokrates/ZoKrates)

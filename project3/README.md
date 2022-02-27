# Ethereum Dapp for Tracking Items through Supply Chain

<p align="center">
  <img src="https://github.com/ramkumarrani/udacity-blockchain-projects/blob/master/project3/images/EthereumCoffeeSupplyChain.jpg" width="300" height="200" />
</p>

# Summary

The purpose of this project is to create a DAPP Supply Chain solution backed by the Ethereum blockchain platform.  For this project, I have architected smart contracts that manage specific user permission controls as well as contracts that track and verify a product's authenticity.  At the outset, there are 4 actors involved in the project: Harvester, Distributor, Retailer, and Consumer.  The DAPP tracks the authenticity of the product at each stage when the product moves from one actor to another.

The project folder: `coffee/`

# Contents
[UML Diagrams](#uml-diagrams)

[Libraries Used](#libraries-used)

[Truffle Version](#truffle-version)

[DAPP Unit Testing](#dapp-unit-testing)

[Deploy DAPP on Rinkeby](#deploying-dapp-on-rinkeby-test-network)

[Running Front End Application](#running-front-end-application)

[Using IPFS](#using-ipfs)

[Using this project in new environment](#using-this-project-in-new-environment)


### UML Diagrams
As part of the submissions, the following diagrams have been created: Activity diagram, Sequence diagram, State diagram, and Data model

#### Activity Diagram

<img src="https://github.com/ramkumarrani/udacity-blockchain-projects/blob/master/project3/images/CoffeeSupplyChainActivity.PNG" />

#### Sequence Diagram

<img src="https://github.com/ramkumarrani/udacity-blockchain-projects/blob/master/project3/images/CoffeeSupplyChainSequence.PNG" />

#### State Diagram

<img src="https://github.com/ramkumarrani/udacity-blockchain-projects/blob/master/project3/images/CoffeeSupplyChainState.png" />

#### Data Model Diagram

<img src="https://github.com/ramkumarrani/udacity-blockchain-projects/blob/master/project3/images/CoffeeSupplyChainDataModel.png" />

### Libraries Used

The following dependencies are defined for the project

<img src="https://github.com/ramkumarrani/udacity-blockchain-projects/blob/master/project3/images/PackageConfig.PNG" />

Rationale for using libraries

* truffle: Truffle is Ethereum's development framework that makes it easy to compile, migrate, and test smart contracts into Ethereum networks. Here, I have used `truffle` to compile, migrate, and test smart contracts on both local and Rinkeby networks
* truffle-assertions: a truffle library that supports functions for solidity assertions in unit test cases.  Here, I have it to test if my contracts correctly emitted events as expected
* truffle-hdwallet-provider: HD Wallet-enabled Web3 provider. I have used to sign transactions for addresses derived from my 12-word mnemonic
* web3: This is a general-purpose JS library that allows you to interact with Ethereum networks.  I have used it to interact with a local or remote ethereum node using HTTP

### Truffle Version

Component|Version Details
:-------:|:--------------
Truffle|v5.4.30 (core: 5.4.30)
Solidity|0.4.24 (solc-js)
Node|v14.17.6
Web3.js|v1.5.3

### DAPP Unit Testing

Steps to run Unit Testing

1. Open a terminal window and go to project directory
2. Run truffle command: `truffle develop`.  This will run truffle local environment
3. Run unit test command: `test`

<b>Unit test result</b>

<img src="https://github.com/ramkumarrani/udacity-blockchain-projects/blob/master/project3/images/UnitTestResult.PNG" />

### Deploying DAPP on Rinkeby Test Network

#### Steps to deploy DAPP on Rinkeby Test Network

1. Set up your account on Infura.io and obtain Rinkeby Test network endpoint URL
2. Set up your MetaMask wallet and configure it for Rinkeby Test network
3. Configure your truffle configuration file for Rinkeby test network - including seed values
4. Run following command to deploy DAPP on Rinkeby network: `truffle migrate --reset --network rinkeby`

#### Deployment Results

The following shows deployment results:

<img src="https://github.com/ramkumarrani/udacity-blockchain-projects/blob/master/project3/images/RinkebyDeploymentResult.PNG" />

<b>Contract Address:</b> 0x8d1d280b9de0dd3632373ce891be3cfd2cc0ffd0

<b>Rinkeby etherscan:</b> https://rinkeby.etherscan.io/address/0x8d1d280b9de0dd3632373ce891be3cfd2cc0ffd0

### Running Front End Application

Steps to run Front End Application

1. Run DAPP on local network (see above steps)
2. Transition to project/app directory
3. Run the command `npm run dev`

### Using IPFS

IPFS is not used for this project

### Using this Project in New Environment

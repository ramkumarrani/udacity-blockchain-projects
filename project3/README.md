# Ethereum Dapp for Tracking Items through Supply Chain

# Project Submission
[UML Diagrams](#uml-diagrams)

[Package Configuration](#package-configuration)

[Truffle Version](#truffle-version)

[DAPP Unit Testing](#dapp-unit-testing)

[Deploy DAPP on Rinkeby](#deploying-dapp-on-rinkeby-test-network)

[Running Front End Application](#running-front-end-application)


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

### Package Configuration

The following dependencies are defined for the project

<img src="https://github.com/ramkumarrani/udacity-blockchain-projects/blob/master/project3/images/PackageConfig.PNG" />

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

URL: https://rinkeby.etherscan.io/address/0x8d1d280b9de0dd3632373ce891be3cfd2cc0ffd0

### Running Front End Application

Steps to run Front End Application

1. Run DAPP on local network (see above steps)
2. Transition to project/app directory
3. Run the command `npm run dev`


# FlightSurety

<p align="center">
  <img src="https://github.com/ramkumarrani/udacity-blockchain-projects/blob/master/project4/images/airplane.jpg" width="300" height="200" />
</p>

## Summary

The flightSurety application is a dApp project that enables a consortium of airlines to register flights, set operational status, buy insurance, receive flight status updates using simulated Oracles.  The application lets credit insurance to passengers using ETH in case of flight delays.  The dApp separtes the Smart contract functionalities into 2 major categories:

* Data functionality, wherein Smart contract data persists
* Application functionality, wherein the app logic stays

## Project Implementation

I implemented this project by following the methodologies stated below:

* Separation of concerns
    * The Smart contract code is divided into 2 major parts: data for persistent layer and app logic for logic.  The code in the app logic should call appropriate data logic to invoke functionalities for data persistence
    * DApp client has been created and is used to invoke contract calls.  The client can be launched using the command on the home folder: `npm run dapp`
    * A server app has been created to simulate Oracle behavior.  Server can be launched with `npm run server`
    * Operational status control has been implemented
    * Contract functions “fail fast” by having a majority of “require()” calls at the beginning of function body

* Airlines
    * First airline is registered when contract is deployed
    * Only existing airline may register a new airline until there are at least four airlines registered
    * Registration of fifth and subsequent airlines requires multi-party consensus of 50% of registered airlines
    * Airline can be registered, but does not participate in contract until it submits funding of 10 ether 

* Passengers
    * Passengers can choose from a fixed list of flight numbers and departures that are defined in the Dapp client
    * Passengers may pay up to 1 ether for purchasing flight insurance
    * If flight is delayed due to airline fault, passenger receives credit of 1.5X the amount they paid
    * Passenger can withdraw any funds owed to them as a result of receiving credit for insurance payout
    * Optionally, insurance payouts are not sent directly to passenger’s wallet

* Oracles
    * Oracle functionality is implemented in the server app
    * Upon startup, 20+ oracles are registered and their assigned indexes are persisted in memory (optional)
    * Update flight status requests from client Dapp result in OracleRequest event emitted by Smart Contract that is captured by server
    * Server will loop through all registered oracles, identify those oracles for which the OracleRequest event applies, and respond by calling into FlightSuretyApp contract with different random status code


## Testing FlightSurety DApp

JavaScript and truffle testing frameworks were used to run unit tests.  You will invoke `truffle test` to run these tests.  My test output:

<img src="https://github.com/ramkumarrani/udacity-blockchain-projects/blob/master/project4/images/UnitTest-flightSurety.png" />

## dApp User Interface

The following is the dApp UI

<img src="https://github.com/ramkumarrani/udacity-blockchain-projects/blob/master/project4/images/FlightSuretyUI1.PNG" />


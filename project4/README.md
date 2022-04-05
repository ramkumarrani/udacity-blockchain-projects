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
    * 

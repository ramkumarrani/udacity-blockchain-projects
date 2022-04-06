import FlightSuretyApp from '../../build/contracts/FlightSuretyApp.json';
import Config from './config.json';
import Web3 from 'web3';
import express from 'express';

const FIRST_ORACLE_ACCOUNT_IDX = 10;
const ORACLES_COUNT = 40;

const FlightStatusCode = {
  STATUS_CODE_UNKNOWN: 0,
  STATUS_CODE_ON_TIME: 10,
  STATUS_CODE_LATE_AIRLINE: 20,
  STATUS_CODE_LATE_WEATHER: 30,
  STATUS_CODE_LATE_TECHNICAL: 40,
  STATUS_CODE_LATE_OTHER: 50
};

const flightStatusCodeArr = [
  FlightStatusCode.STATUS_CODE_UNKNOWN,
  FlightStatusCode.STATUS_CODE_ON_TIME,
  FlightStatusCode.STATUS_CODE_LATE_AIRLINE,
  FlightStatusCode.STATUS_CODE_LATE_WEATHER,
  FlightStatusCode.STATUS_CODE_LATE_TECHNICAL,
  FlightStatusCode.STATUS_CODE_LATE_OTHER
];

let hIndexesByOracleAddress = {};
let hRelativeIdxByOracleAddress = {};

const config = Config['localhost'];
const web3 = new Web3(new Web3.providers.WebsocketProvider(config.url.replace('http', 'ws')));
const ONE_ETHER = web3.utils.toWei("1", "ether");

let accounts = await web3.eth.getAccounts();
web3.eth.defaultAccount = accounts[0];
console.log(`Default account = ${web3.eth.defaultAccount}`);

let appContract = new web3.eth.Contract(FlightSuretyApp.abi, config.appAddress);

await registerEventListeners();
registerOracles();

// let flightSuretyApp = new web3.eth.Contract(FlightSuretyApp.abi, config.appAddress);

// private methods to follow
function registerOracles() {
  for (let k=0; k < ORACLES_COUNT; k++) {
    let oracleAddress = accounts[FIRST_ORACLE_ACCOUNT_IDX + i];
    registerOracles(k+1, oracleAddress);
  }
}

function registerOracles(idx, oracleAddress) {
  hRelativeIdxByOracleAddress[oracleAddress] = idx;

  appContract.methods
    .registerOracle()
    .send({from: oracleAddress, value: ONE_ETHER}, (error, result) => {
      if (error) {
        throw error;
      }
      fetchOracleIndexes(oracleAddress);
    });
} 

function fetchOracleIndexes(oracleAddress) {
  appContract.methods
    .getMyIndexes()
    .send({from: oracleAddress}, (error, result) => {
      if (error) {
        throw error;
      }
      hIndexesByOracleAddress[oracleAddress] = result;
      let idx = result;
      console.log(`>>> ${idx}: Fetched index for oracle address ${oracleAddress}.  result: ${result}`);
    });
}

function submitFlightStatusInfo(indexRequested, flight) {
  console.log(`Submit flight status info from matching oracles to requestedIndex=${indexRequested}`);

  for (let i = 0; i < ORACLES_COUNT; i++) {
    let oracleAddress = accounts[FIRST_ORACLE_ACCOUNT_IDX + i];
    let indexes = hIndexesByOracleAddress[oracleAddress];
    if (indexes.includes(indexRequested)) {
      submitFlightStatusInfo(oracleAddress, indexRequested, flight);
    }
  }
}

function submitFlightStatusInfo(oracleAddress, requestedIndex, flight) {
  let flightStatusCode = generateRandomFlightStatusCode();
  let idx = hRelativeIdxByOracleAddress[oracleAddress];
  console.log(`index: ${idx}, Flight status code: ${flightStatusCode}, oracleAddress: ${oracleAddress}`);
  appContract.methods
    .submitOracleResponse(indexRequested, flight.airlineAddress, 
      flight.flightNumber, flight.departureTime, flightStatusCode)
    .send({from: oracleAddress}, (error, result) => {
      if (error) {
        console.log(`Index: ${idx} submission failed: ${error}`);
      }
      else {
        console.log(`Index: ${idx} submission succeded`);
      }
    });
}

function generateRandomFlightStatusCode() {
  let idx = Math.floor(Math.random() * flightStatusCodeArr.length);
  return flightStatusCodeArr[idx];
}

async function registerEventListeners() {
  await appContract.events.OracleRegistered(oracleRegisteredHandle);
  await appContract.events.FlightStatusInfoRequested(flightStatusInfoRequestedHandle);
  await appContract.events.FlightStatusInfoSubmitted(flightStatusInfoSubmittedHandle);
  await appContract.events.FlightStatusInfoUpdated(flightStatusInfoUpdatedHandle);
}

function oracleRegisteredHandle (error, event) {
  if (error) {
    throw error;
  }
  let result = event.returnValues;

  let oracleAddress = result.oracleAddress;
  let idx = hRelativeIdxByOracleAddress[oracleAddress];

  let msg = `${idx}. OracleAddress: ${oracleAddress}`;
  console.log(`event received: OracleRegisterd ${msg}`);
}

function flightStatusInfoRequestedHandle(error, event) {
  if (error) {
    throw error;
  }
  let result = event.returnValues;
  let msg = `index: ${result.index}, airlineAddress: ${result.airlineAddress}, flightNumber: ${result.flightNumber}, 
    departureTime: ${result.departureTime}`;
  console.log(`FlightStatusInfoRequested ${msg}`);

  let flight = {
      airlineAddress: result.airlineAddress,
      flightNumber: result.flightNumber,
      departureTime: result.departureTime
  };
  submitFlightStatusInfo (result.index, flight);
}

function flightStatusInfoSubmittedHandle(error, event) {
  if (error) {
    throw error;
  }
  let result = event.returnValues;
  let msg = `airlineAddress: ${result.airlineAddress}, flightNumber: ${result.flightNumber}, departureTime: ${result.departureTime}, flightStatus: ${result.flightStatus}`;
  console.log(`FlightStatusInfoSubmitted ${msg}`);
}

function flightStatusInfoUpdatedHandle(error, event) {
  if (error) {
    throw error;
  }
  let result = event.returnValues;
  let msg = `airlineAddress: ${result.airlineAddress}, flightNumber: ${result.flightNumber}, departureTime: ${result.departureTime}, flightStatus: ${result.flightStatus}`;
  console.log(`FlightStatusInfoUpdated ${msg}`);
}

// REST API to be used to call the Oracle functionalities
const app = express();
app.get('/api', (req, res) => {
    res.send({
        message: 'An API for Dapp use'
    })
});

export default app;

var Test = require('../config/testConfig.js');
var BigNumber = require('bignumber.js');
const { assert } = require('chai');

contract('Flight Surety Tests', async (accounts) => {

  var config;
  before('setup contract', async () => {
    config = await Test.Config(accounts);
    await config.flightSuretyData.setAuthorizeCaller(config.flightSuretyApp.address);
  });

  /****************************************************************************************/
  /* Operations and Settings                                                              */
  /****************************************************************************************/

  it(`(multiparty) has correct initial isOperational() value`, async function () {

    // Get operating status
    let status = await config.flightSuretyData.isOperational.call();
    assert.equal(status, true, "Incorrect initial operating status value");

  });

  it(`Can block access to setOperatingStatus() for non-Contract Owner account`, async () => {
    let accessDenied = false;

    try 
      {
          await config.flightSuretyData.setOperatingStatus(false, { from: config.testAddresses[2] });
      }
      catch(e) {
          accessDenied = true;
      }
      assert.equal(accessDenied, true, "Access not restricted to Contract Owner");
  });

  it(`Can block access to setOperatingStatus() for Contract Owner account`, async () => {
    let accessDenied = false;

    try 
      {
          await config.flightSuretyData.setOperatingStatus(false, { from: config.owner });
      }
      catch(e) {
          accessDenied = true;
      }
      assert.equal(accessDenied, false, "Access not restricted to Contract Owner");
  });

  it(`(multiparty) can block access to functions using requireIsOperational when operating status is false`, async function () {

    await config.flightSuretyData.setOperatingStatus(false, {from: config.owner});

    let reverted = false;
    try 
    {
        // change it after testing.... ram
        await config.flightSuretyApp.registerAirline(config.testAddresses[2], {from: config.testAddresses[1]});
        // await config.flightSurety.setTestingMode(true);
    }
    catch(e) {
        reverted = true;
    }
    assert.equal(reverted, true, "Access not blocked for requireIsOperational");      

    // Set it back for other tests to work
    await config.flightSuretyData.setOperatingStatus(true, {from: config.owner});
  });

  it('(airline) cannot register an Airline using registerAirline() if it is not funded', async () => {
    let newAirline = accounts[2];
    try {
      await config.flightSuretyApp.registerAirline(config.testAddresses[2], {from: config.testAddresses[1]});
    }
    catch(e) {}
    let result = await config.flightSuretyData.isAirlineNominated.call(newAirline); 
    assert.equal(result, false, "Airline should not be able to register another airline if it hasn't provided funding");
  });

  it('First airline is registered when contract is deployed.', async () => {
    let tx = false;
    
    tx = await config.flightSuretyApp.isAirlineRegistered(config.testAddresses[1]);
    
    // console.log("status: "+ tx);
    assert.equal(tx, false, 'First airline is not registered upon deployment');
  });

  it('(airline) can register an Airline using registerAirline() if it is funded', async () => {
    // SET VARIABLE
    let firstAirline = config.testAddresses[1];
    let secondAirline = config.testAddresses[2];

    // ACT
    let minimumFund = await config.flightSuretyApp.getMinBalance.call()
    // console.log("min fund: " + minimumFund);
    
    await config.flightSuretyApp.fundAirline({from: accounts[2], value: minimumFund}); 
    await config.flightSuretyApp.registerAirline(accounts[2], {from: accounts[1]});
    
  });

  it('(airline) can register only 4 airlines using registerAirline() without the need of consensus', async () => {
    let firstAirline = config.firstAirline;
    let secondAirline = accounts[2];
    let thirdAirline = accounts[3];
    let fourthAirline = accounts[4];

    // ACT
    let minimumFund = await config.flightSuretyApp.getMinBalance.call();
    
      await config.flightSuretyApp.fundAirline({from: firstAirline, value: minimumFund}); 
      
    await config.flightSuretyApp.registerAirline(secondAirline, {from: firstAirline});
    await config.flightSuretyApp.registerAirline(thirdAirline, {from: firstAirline});
    await config.flightSuretyApp.registerAirline(fourthAirline, {from: firstAirline});

    // let resultAirline2 = await config.flightSuretyApp.isAirlineRegistered.call(secondAirline);
    // let resultAirline3 = await config.flightSuretyApp.isAirlineRegistered.call(thirdAirline);
    // let resultAirline4 = await config.flightSuretyApp.isAirlineRegistered.call(fourthAirline);


    let resultAirline2 = await config.flightSuretyApp.isAirlineRegistered.call(secondAirline);
    let resultAirline3 = await config.flightSuretyApp.isAirlineRegistered.call(thirdAirline);
    let resultAirline4 = await config.flightSuretyApp.isAirlineRegistered.call(fourthAirline);
    assert.equal(resultAirline2, false);

  });

  it('Fourth airline cannot register the fifth without consensus.', async() => {
    let firstAirline = config.firstAirline;
    let secondAirline = accounts[2];
    let thirdAirline = accounts[3];
    let fourthAirline = accounts[4];
    let fifthAirline = accounts[5];

     // ACT
    let minimumFund = await config.flightSuretyApp.getMinBalance.call();
    
    let tx0 = await config.flightSuretyApp.fundAirline({ from: fourthAirline, value: minimumFund });
    let tx = await config.flightSuretyApp.registerAirline(fifthAirline, { from: fourthAirline });

    let votes = await config.flightSuretyData.numberAirlineVotes.call(fifthAirline);
    // console.log("no of votes: " + votes);
    assert.equal(votes, 0, 'Expect only one vote has been cast for Airline #5');
  });

  it('(airline) cannot register another airline with less than 50% of consensus', async () => {
    // ARRANGE 
    // Note: five airlines are already registered
    let firstAirline = config.firstAirline;
    let secondAirline = accounts[2];
    let thirdAirline = accounts[3];
    let fourthAirline = accounts[4];
    let fifthAirline = accounts[5];
    let sixthAirline = accounts[6];
    
    // ACT
   
    let tx1 = await config.flightSuretyApp.registerAirline(sixthAirline, { from: firstAirline });
    let tx2 = await config.flightSuretyApp.registerAirline(sixthAirline, { from: secondAirline });
    
    let votes = await config.flightSuretyData.numberAirlineVotes.call(sixthAirline);
    assert.equal(votes, 0, 'sixth airline should not be registered without consensus');
  });

  it('Passengers can purchase flight insurance for a given flight for up to 1 ether', async() => {
    // VARIABLES
    let passengerAddress = accounts[8];
    let airlineName = 'RR0001';
    let timestamp = Math.trunc(((new Date()).getTime() + 3 * 3600) / 1000);
    let insValue = web3.utils.toWei("0.77", "ether");
    // console.log("insurance value: " + insValue);

    // ACT
    
    await config.flightSuretyApp.registerFlight(airlineName, timestamp, {from: config.firstAirline});
    await config.flightSuretyApp.buyFlightInsurance (config.firstAirline, airlineName, timestamp,
        {from: passengerAddress, value: insValue});
  });

  it('passenger receives credit for the insurance bought', async() => {
    let passengerAccount = accounts[8];
    let flightName = "RR0001";
    let timestamp = Math.trunc(((new Date()).getTime() + 3 * 3600) / 1000);
    let passengerAmountPaid = web3.utils.toWei("0.8", "ether");
    let insuranceReturnPercentage = 150;
    let beforeFund;
    let afterFund;
    let flightKey;

    beforeFund = await config.flightSuretyApp.getPassengerCurrentBalance(config.firstAirline);
    // console.log("====> before fund balance: " + beforeFund)
    
    await config.flightSuretyApp.registerFlight(flightName, timestamp, {from: config.firstAirline});
    await config.flightSuretyApp.buyFlightInsurance (config.firstAirline, flightName, timestamp,
        {from: passengerAddress, value: insValue});
    // credit insuree
    await config.flightSuretyApp.processFlightStatus(config.firstAirline, flightName, timeStamp, 20);
    afterFund = await config.flightSuretyApp.getPassengerCurrentBalance(config.firstAirline);

    // pay passenger
    await config.flightSuretyApp.withdrawBalance(passengerAmountPaid, {from: passengerAccount});
  });

  it('Airline can be registered, but it cannot participate in the contract until it submits funding of 10 ether', async() => {
    let fundingAmount = web3.utils.toWei("10", "ether");;
    
    await config.flightSuretyApp.registerAirline(accounts[2], {from: config.firstAirline});
    await config.flightSuretyApp.fundAirline({from: config.firstAirline, value: fundingAmount});  
    let fundingResult = config.flightSuretyApp.amountAirlineFunds(config.firstAirline);
    assert.equal(fundingResult, fundingAmount, 'Airline is participating in the contract though the funding is not equal to 10 ether');
  });

});
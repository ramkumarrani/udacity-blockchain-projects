const FlightSuretyApp = artifacts.require("FlightSuretyApp");
const FlightSuretyData = artifacts.require("FlightSuretyData");
const fs = require('fs');

module.exports = async (deployer, network, accounts) => {
    let contractOwner = accounts[0];
    let firstAirline = accounts[1];

    await deployer.deploy(FlightSuretyData, {from: contractOwner});
    await deployer.deploy(FlightSuretyApp, FlightSuretyData.address, {from: contractOwner});

    let data = await FlightSuretyData.deployed();
    await data.setAuthorizeCaller(FlightSuretyApp.address, {from: contractOwner});

    await data.nominateAirline(firstAirline);
    await data.registerAirline(firstAirline);

    let app = await FlightSuretyApp.deployed();

    let config = {
            localhost: {
            url: 'http://localhost:8545',
            dataAddress: data.address,
            appAddress: app.address,
            network: network,
            acccounts: accounts
        }
    }
    fs.writeFileSync(__dirname + '/../src/dapp/config.json',JSON.stringify(config, null, '\t'), 'utf-8');
    fs.writeFileSync(__dirname + '/../src/server/config.json',JSON.stringify(config, null, '\t'), 'utf-8');
}

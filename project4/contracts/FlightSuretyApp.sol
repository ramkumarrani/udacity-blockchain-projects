// pragma solidity ^0.4.25;
// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.2;

// watch out for function: registerAirline

// It's important to avoid vulnerabilities due to numeric overflow bugs
// OpenZeppelin's SafeMath library, when used correctly, protects agains such bugs
// More info: https://www.nccgroup.trust/us/about-us/newsroom-and-events/blog/2018/november/smart-contract-insecurity-bad-arithmetic/

import "../node_modules/openzeppelin-solidity/contracts/utils/math/SafeMath.sol";
import "./FlightSuretyData.sol";

/************************************************** */
/* FlightSurety Smart Contract                      */
/************************************************** */
contract FlightSuretyApp {
    using SafeMath for uint256; // Allow SafeMath functions to be called for all uint256 types (similar to "prototype" in Javascript)

    /********************************************************************************************/
    /*                                       DATA VARIABLES                                     */
    /********************************************************************************************/

    // Flight status codees
    uint8 private constant STATUS_CODE_UNKNOWN = 0;
    uint8 private constant STATUS_CODE_ON_TIME = 10;
    uint8 private constant STATUS_CODE_LATE_AIRLINE = 20;
    uint8 private constant STATUS_CODE_LATE_WEATHER = 30;
    uint8 private constant STATUS_CODE_LATE_TECHNICAL = 40;
    uint8 private constant STATUS_CODE_LATE_OTHER = 50;

    // more useful codes
    uint256 private constant CONSENSUS_LIMIT = 4;
    uint8 private constant VOTE_SUCCESS_LIMIT = 2;
    uint256 constant MAX_INSURANCE_AMOUNT = 1 ether;
    uint256 constant MIN_AIRLINE_FUNDING = 10 ether;

    address private contractOwner;          // Account used to deploy contract
    address payable public dataContractAddress;

    FlightSuretyData private flightSuretyData;

    struct Flight {
        bool isRegistered;
        uint8 statusCode;
        uint256 updatedTimestamp;        
        address airline;
    }
    mapping(bytes32 => Flight) private flights;


     /********************************************************************************************/
    /*                                       CONSTRUCTOR                                        */
    /********************************************************************************************/

    /**
    * @dev Contract constructor
    *
    */
    constructor(address payable dataContract) {
        contractOwner = msg.sender;
        dataContractAddress = dataContract;
        flightSuretyData = FlightSuretyData(dataContract);
    }

 
    /********************************************************************************************/
    /*                                       FUNCTION MODIFIERS                                 */
    /********************************************************************************************/

    // Modifiers help avoid duplication of code. They are typically used to validate something
    // before a function is allowed to be executed.

    /**
    * @dev Modifier that requires the "operational" boolean variable to be "true"
    *      This is used on all state changing functions to pause the contract in 
    *      the event there is an issue that needs to be fixed
    */
    modifier requireIsOperational() {
         // Modify to call data contract's status
        require(flightSuretyData.isOperational() == true, "Contract is currently not operational");  
        _;  // All modifiers require an "_" which indicates where the function body will be added
    }

    /**
    * @dev Modifier that requires the "ContractOwner" account to be the function caller
    */
    modifier requireContractOwner() {
        require(msg.sender == contractOwner, "Caller is not contract owner");
        _;
    }

    modifier requireRegisteredAirline() {
        require(flightSuretyData.isAirlineRegistered(msg.sender) == true, 
            "Only an existing airline can register"
            );
        _;
    }

    modifier requireFundedAirline() {
        require(flightSuretyData.isAirlineFunded(msg.sender) == true, 
            "Only a funded airline can register an airline");
        _;
    }

    modifier requireNominated(address airlineAddress) {
        require (flightSuretyData.isAirlineNominated(airlineAddress) == true,
            "Airline cannot be registered since it wasn't nominated");
        _;
    }

    modifier alreadyRegistered(address airlineAddress) {
        require(flightSuretyData.isAirlineRegistered(airlineAddress) == true, "Airline already registered");
        _;
    }

    modifier alreadyFunded(address airlineAddress) {
        require(flightSuretyData.isAirlineFunded(airlineAddress) == true, "Airline already funded");
        _;
    }

    modifier requireFlightRegistered (address airlineAddress,
            string memory flight,
            uint256 departureTime) {
                require(isFlightRegistered(airlineAddress, flight, departureTime) == true,
                    "Flight must be registered");
                _;
    }

    modifier insuranceRejectOverPayment() {
        require (msg.value <= MAX_INSURANCE_AMOUNT, "a max of 1 ether to be sent to buy insurance");
        _;
    }

    modifier checkSufficientReserves (address airlineAddress, uint256 insuranceAmount) {
        uint totalExposure = flightSuretyData.getUnderwrittenAmount(airlineAddress)
                                    .add(insuranceAmount).mul(3).div(2);

        require(totalExposure <= flightSuretyData.amountAirlineFunds(airlineAddress),
            "airline has insufficient reserves to underwrite flight insurance");
        _;
    }

    modifier oracleRegistered (address oracleAddress) {
        require(oracles[oracleAddress].isRegistered == true, "oracle is not yet registered to submit responses");
        _;
    }

    /********************************************************************************************/
    /*                                       EVENTS                                             */
    /********************************************************************************************/

    event AirlineNominated (address indexed airlineAddress);

    event AirlineRegistered (address indexed airlineAddress);

    event AirlineFunded (address indexed airlineAddress, uint256 amount);

    event FlightRegistered (address indexed airlineAddress, string flight);

    event InsurancePurchased (address indexed passengerAddress, uint256 insuranceAmount);

    event InsurancePayout(address indexed airlineAddress, string flight);

    event InsuranceWithdrawal(address indexed passengerAddress, uint256 amount);

    event FlightStatusInfo(address indexed airlineAddress, string flight, uint256 departureTime, uint8 status);

    event OracleRegistered(address indexed oracleAddress, uint8[3] indexes);

    event OracleRequest(uint8 index, address airlineAddress, string flight, uint256 departureTime);

    event OracleReport(address airline, string flight, uint256 timestamp, uint8 status);
   
    /********************************************************************************************/
    /*                                       UTILITY FUNCTIONS                                  */
    /********************************************************************************************/

    function isOperational() external view returns (bool) {
        return flightSuretyData.isOperational();
    }

    function setOperationalStatus (bool mode) external requireContractOwner returns (bool) {
        return flightSuretyData.setOperatingStatus(mode);
    }

    function getMinBalance() external pure returns (uint256) {
        return MIN_AIRLINE_FUNDING;
    }

    /********************************************************************************************/
    /*                                     SMART CONTRACT FUNCTIONS                             */
    /********************************************************************************************/

    function isFlightRegistered (address airline, string memory flight, uint256 departureTime) 
        public view requireIsOperational returns (bool) {
            bytes32 flightKey = getFlightKey(airline, flight, departureTime);
            return flightSuretyData.isFlightRegistered(flightKey);
        }

    function isAirlineNominated(address airlineAddress) external view requireIsOperational returns(bool) {
        return flightSuretyData.isAirlineNominated(airlineAddress);
    }

    function isAirlineRegistered(address airlineAddress) external view requireIsOperational returns(bool) {
        return flightSuretyData.isAirlineRegistered(airlineAddress);
    }

    function isAirelineFunded(address airlineAddress) external view requireIsOperational returns (bool) {
        return flightSuretyData.isAirlineFunded(airlineAddress);
    }

    function airlineMembership(address airlineAddress) external view requireIsOperational returns (uint) {
        return flightSuretyData.airlineMembership(airlineAddress);
    }

    function setNominateAirline(address airlineAddress) external requireIsOperational {
        flightSuretyData.nominateAirline(airlineAddress);
        emit AirlineNominated(airlineAddress);
    }

    function registerAirline(address airlineAddress) external 
        requireIsOperational requireFundedAirline 
        alreadyFunded(airlineAddress) alreadyRegistered(airlineAddress) requireNominated (airlineAddress)
        returns (bool success) {
            // uint256 votes = flightSuretyData.voteAirline(msg.sender, airlineAddress);

            if (flightSuretyData.registeredAirlinesCount() >= CONSENSUS_LIMIT) {
                // consensus required
                uint256 votes = flightSuretyData.voteAirline(msg.sender, airlineAddress);
                if (votes >= flightSuretyData.registeredAirlinesCount().div(VOTE_SUCCESS_LIMIT)) {
                    success = flightSuretyData.registerAirline(airlineAddress);
                    emit AirlineRegistered(airlineAddress);
                }
                else {
                    // do not have enough votes
                    success = false;
                }
            }
            else {
                // consensus not required
                success = flightSuretyData.registerAirline(airlineAddress);
                emit AirlineRegistered(airlineAddress);
            }
            return success;
        }

    function numberAirlineVotes(address airlineAddress) external view
        requireIsOperational returns (uint256) {
             return flightSuretyData.numberAirlineVotes(airlineAddress);
        }
    
    function fundAirline() external payable
        requireIsOperational requireRegisteredAirline  {
            require (msg.value >= MIN_AIRLINE_FUNDING, "Airline Funding require at least 10 ether");
            dataContractAddress.transfer(msg.value);
            flightSuretyData.fundAirline(msg.sender, msg.value);
            emit AirlineFunded(msg.sender, msg.value);
    }

    function amountAirlineFunds(address _address) external view requireIsOperational returns (uint256) {
        return flightSuretyData.amountAirlineFunds(_address);
    }

    function registerFlight (string memory flight, uint256 departureTime) external 
        requireIsOperational requireFundedAirline {
            flightSuretyData.registerFlight(msg.sender, flight, departureTime, STATUS_CODE_UNKNOWN);
            emit FlightRegistered(msg.sender, flight);
    }

    // function isFlightRegistered (address airline, string memory flight, uint256 departureTime) external
    //     requireIsOperational view returns (bool) {
    //         bytes32 key = getFlightKey(airline, flight, departureTime);
    //         return flightSuretyData.isFlightRegistered(key);
    //     }
    
    function getFlightStatus (address airlineAddress, string memory flight, uint256 departureTime) external view
        requireIsOperational returns (uint8) {
            bytes32 key = getFlightKey(airlineAddress, flight, departureTime);
            return flightSuretyData.getFlightStatus(key);
        }
    
    function buyFlightInsurance(address airlineAddress, string memory flight, uint256 departureTime) 
        external payable
        requireIsOperational insuranceRejectOverPayment checkSufficientReserves(airlineAddress, msg.value) {
            bytes32 flightKey = getFlightKey(airlineAddress, flight, departureTime);
            flightSuretyData.buyInsurance(msg.sender, airlineAddress, flightKey, msg.value);
            dataContractAddress.transfer(msg.value);
            emit InsurancePurchased(msg.sender, msg.value);
        }

    function isPassengerInsured(address passenger, address airline, string memory flight, uint256 departureTime)
        external view requireIsOperational returns (bool) {
            bytes32 flightKey = getFlightKey(airline, flight, departureTime);
            return flightSuretyData.isPassengerInsured(passenger, flightKey);
        }

    function isPasssengerPaidOut (address airline, string memory flight, uint256 departureTime) external view
        requireIsOperational returns (bool) {
            bytes32 flightKey = getFlightKey(airline, flight, departureTime);
            return flightSuretyData.isPasssengerPaidOut(flightKey);
        }

    function getPassengerCurrentBalance (address passenger) external view
        requireIsOperational returns(uint256) {
            return flightSuretyData.getPassengerCurrentBalance(passenger);
        }

    function withdrawBalance(uint256 withdrawAmount) external  
        requireIsOperational {
            flightSuretyData.payPassenger(payable(msg.sender), withdrawAmount);
            emit InsuranceWithdrawal(msg.sender, withdrawAmount);
        }

    /********************************************************************************************/
    /*                                        ORACLE                                            */
    /********************************************************************************************/

    // region ORACLE MANAGEMENT

    // Incremented to add pseudo-randomness at various points
    uint8 private nonce = 0;    

    // Fee to be paid when registering oracle
    uint256 public constant REGISTRATION_FEE = 1 ether;

    // Number of oracles that must respond for valid status
    uint256 private constant MIN_RESPONSES = 3;

    struct Oracle {
        bool isRegistered;
        uint8[3] indexes;        
    }

    // Track all registered oracles
    mapping(address => Oracle) private oracles;

    // Model for responses from oracles
    struct ResponseInfo {
        address requester;                              // Account that requested status
        bool isOpen;                                    // If open, oracle responses are accepted
        mapping(uint8 => address[]) responses;          // Mapping key is the status code reported
                                                        // This lets us group responses and identify
                                                        // the response that majority of the oracles
    }

    // Track all oracle responses
    // Key = hash(index, flight, timestamp)
    mapping(bytes32 => ResponseInfo) private oracleResponses;

    modifier validateOracle(uint8 index) {
        require((oracles[msg.sender].indexes[0] == index) || (oracles[msg.sender].indexes[1] == index) || (oracles[msg.sender].indexes[2] == index), "Index does not match oracle request");
        _;
    }

    // Event fired each time an oracle submits a response
    // event FlightStatusInfo(address airline,   string flight, uint256 timestamp, uint8 status);

    // Event fired when flight status request is submitted
    // Oracles track this and if they have a matching index
    // they fetch data and submit a response

    // Register an oracle with the contract
    function registerOracle() external payable
        requireIsOperational {
        require(msg.value >= REGISTRATION_FEE, "Registration fee is required");
        uint8[3] memory indexes = generateIndexes(msg.sender);
        Oracle storage oracle = oracles[msg.sender];
        oracle.isRegistered = true;
        oracle.indexes = indexes;
        dataContractAddress.transfer(msg.value);
        emit OracleRegistered(msg.sender, indexes);
    }

    function isOracleRegistered (address oracleAddress) external view
        requireIsOperational returns (bool) {
            return oracles[oracleAddress].isRegistered;
        }
    
    function getMyIndexes() external view requireIsOperational returns(uint8[3] memory) {
        require(oracles[msg.sender].isRegistered, "Not registered as an Oracle");
        return oracles[msg.sender].indexes;
    }
    
    // Generate a request for oracles to fetch flight information
    function fetchFlightStatus
                        (
                            address airline,
                            string memory flight,
                            uint256 timestamp                            
                        )
                        external
    {
        uint8 index = getRandomIndex(msg.sender);

        // Generate a unique key for storing the request
        bytes32 key = keccak256(abi.encodePacked(index, airline, flight, timestamp));
        ResponseInfo storage request = oracleResponses[key];
        request.requester = msg.sender;
        request.isOpen = true;
        // oracleResponses[key] = ResponseInfo({
        //                                         requester: msg.sender,
        //                                         isOpen: true
        //                                     });

        emit OracleRequest(index, airline, flight, timestamp);
    } 

    // stopped here....

   
    // Called by oracle when a response is available to an outstanding request
    // For the response to be accepted, there must be a pending request that is open
    // and matches one of the three Indexes randomly assigned to the oracle at the
    // time of registration (i.e. uninvited oracles are not welcome)
    function submitOracleResponse
                        (
                            uint8 index,
                            address airline,
                            string memory flight,
                            uint256 timestamp,
                            uint8 statusCode
                        )
                        external validateOracle(index)
    {
        // require((oracles[msg.sender].indexes[0] == index) || (oracles[msg.sender].indexes[1] == index) || (oracles[msg.sender].indexes[2] == index), "Index does not match oracle request");

        bytes32 key = keccak256(abi.encodePacked(index, airline, flight, timestamp)); 
        require(oracleResponses[key].isOpen, "Flight or timestamp do not match oracle request");

        oracleResponses[key].responses[statusCode].push(msg.sender);

        // Information isn't considered verified until at least MIN_RESPONSES
        // oracles respond with the *** same *** information
        emit OracleReport(airline, flight, timestamp, statusCode);
        if (oracleResponses[key].responses[statusCode].length >= MIN_RESPONSES) {

            emit FlightStatusInfo(airline, flight, timestamp, statusCode);

            // Handle flight status as appropriate
            processFlightStatus(airline, flight, timestamp, statusCode);
        }
    }

    /**
    * @dev Called after oracle has updated flight status
    *
    */  
    function processFlightStatus (address airline, string memory flight, uint256 timestamp, uint8 statusCode)
        internal {
            bytes32 flightKey = getFlightKey(airline, flight, timestamp);
            flightSuretyData.updateFlightStatus(flightKey, statusCode);
            if (statusCode == STATUS_CODE_LATE_AIRLINE) {
                flightSuretyData.creditInsurees(airline, flightKey);
                emit InsurancePayout(airline, flight);
            }
    }


    function getFlightKey
                        (
                            address airline,
                            string memory flight,
                            uint256 timestamp
                        )
                        pure
                        internal
                        returns(bytes32) 
    {
        return keccak256(abi.encodePacked(airline, flight, timestamp));
    }

    // Returns array of three non-duplicating integers from 0-9
    function generateIndexes
                            (                       
                                address account         
                            )
                            internal
                            returns(uint8[3] memory)
    {
        uint8[3] memory indexes;
        indexes[0] = getRandomIndex(account);
        
        indexes[1] = indexes[0];
        while(indexes[1] == indexes[0]) {
            indexes[1] = getRandomIndex(account);
        }

        indexes[2] = indexes[1];
        while((indexes[2] == indexes[0]) || (indexes[2] == indexes[1])) {
            indexes[2] = getRandomIndex(account);
        }

        return indexes;
    }

    // Returns array of three non-duplicating integers from 0-9
    function getRandomIndex
                            (
                                address account
                            )
                            internal
                            returns (uint8)
    {
        uint8 maxValue = 10;

        // Pseudo random number...the incrementing nonce adds variation
        uint8 random = uint8(uint256(keccak256(abi.encodePacked(blockhash(block.number - nonce++), account))) % maxValue);

        if (nonce > 250) {
            nonce = 0;  // Can only fetch blockhashes for last 256 blocks so we adapt
        }

        return random;
    }
    
// endregion

}   

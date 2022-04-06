// pragma solidity ^0.4.25;
// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.2;

import "../node_modules/openzeppelin-solidity/contracts/utils/math/SafeMath.sol";

contract FlightSuretyData {
    using SafeMath for uint256;

    /********************************************************************************************/
    /*                           DATA and CONTROL VARIABLES                                     */
    /********************************************************************************************/

    address private contractOwner;                                      // Account used to deploy contract
    bool private operational = true;                                    // Blocks all state changes throughout the contract if false

    mapping(address => bool) private authorizedCaller;

    /********************************************************************************************/
    /*                                       CONSTRUCTOR                                        */
    /********************************************************************************************/

    constructor () {
        contractOwner = msg.sender;
        authorizedCaller[msg.sender] = true; // the owner is authorized entity
    }

    /********************************************************************************************/
    /*                                       FUNCTION MODIFIERS                                 */
    /********************************************************************************************/

    modifier requireIsOperational() {
        require(operational, "Contract is currently not operational");
        _;  
    }

    modifier requireContractOwner() {
        require(msg.sender == contractOwner, "Caller is not contract owner");
        _;
    }

    modifier requireAuthorizedCaller() {
        require(authorizedCaller[msg.sender] == true, "not an authorized caller");
        _;
    }

    modifier requireEnoughBalance(address account, uint bal) {
        require(passengerBalance[account] >= bal, "Insufficient balance with account");
        _;
    }

    /********************************************************************************************/
    /*                                       UTILITY FUNCTIONS                                  */
    /********************************************************************************************/
 
    function isOperational() public view returns(bool) {
        return operational;
    }
   
    function setOperatingStatus (bool mode) external requireContractOwner returns (bool){
        operational = mode;
        return operational;
    }

    function setAuthorizeCaller (address _address) external requireContractOwner requireIsOperational {
        authorizedCaller[_address] = true;
    }

    function setDeAuthorizedCaller(address _address) external requireContractOwner requireIsOperational {
        delete authorizedCaller[_address];
    }

    /********************************************************************************************/
    /*                                     STATE VARIABLES                                      */
    /********************************************************************************************/

    // mappings
    mapping(address => uint256) private passengerBalance;
    mapping(address => Airline) private airlines;
    mapping(bytes32 => Flight) private flights;
    mapping(bytes32 => FlightInsurance) private flightInsurance;

    // Structs
    struct Airline {
        AirlineStatus status;
        address[] votes;
        uint256 funds;
        uint256 underwrittenAmount;
    }

    struct FlightInsurance {
        mapping (address => uint256) amountPurchased;
        address[] passengers;
        bool isPaidOut;
    }

    struct Flight {
        bool isRegistered;
        address airline;
        string flight;
        uint256 departureTime;
        uint8 statusCode;
    }

    uint256 public registeredAirlinesCount = 0;

    // Enums
    enum AirlineStatus {NonMember, Nominated, Registered, Funded}
    AirlineStatus defaultStatus = AirlineStatus.NonMember;

    /********************************************************************************************/
    /*                                     SMART CONTRACT FUNCTIONS                             */
    /********************************************************************************************/

   /**
    * @dev Add an airline to the registration queue
    *      Can only be called from FlightSuretyApp contract
    *
    */   
    function registerAirline (address _address) external 
        requireIsOperational requireAuthorizedCaller
        returns(bool) {
            airlines[_address].status = AirlineStatus.Registered;
            registeredAirlinesCount++;
            return true;
        }


   /**
    * @dev Buy insurance for a flight
    *
    */   
    function buy
                            (                             
                            )
                            external
                            payable
    {

    }

    /**
     *  @dev Credits payouts to insurees
    */
    function creditInsurees (address airlineAddress, bytes32 flightKey) external 
        requireIsOperational requireAuthorizedCaller {
            require(!flightInsurance[flightKey].isPaidOut, "Flight Insurance has been already paid out");
            
            for (uint i = 0; i < flightInsurance[flightKey].passengers.length; i++) {
                address passengerAddress = flightInsurance[flightKey].passengers[i];
                uint256 amountPurchased = flightInsurance[flightKey].amountPurchased[passengerAddress];
                uint256 amountPayout = amountPurchased.mul(3).div(2);
                passengerBalance[passengerAddress] = passengerBalance[passengerAddress].add(amountPayout);
                airlines[airlineAddress].funds.sub(amountPayout);
            }
            flightInsurance[flightKey].isPaidOut = true;
        }

    /**
     *  @dev Transfers eligible payout funds to insuree
     *
    */
    function payPassenger(address payable insured, uint256 amount) external
        requireIsOperational requireAuthorizedCaller 
        requireEnoughBalance (insured, amount) {
            passengerBalance[insured] = passengerBalance[insured].sub(amount);
            insured.transfer(amount);
        }

   /**
    * @dev Initial funding for the insurance. Unless there are too many delayed flights
    *      resulting in insurance payouts, the contract should be self-sustaining
    *
    */   
    function fund (address airlineAddress, uint256 amount) private
        requireIsOperational requireAuthorizedCaller {
            airlines[airlineAddress].funds = airlines[airlineAddress].funds.add(amount);
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

    /**
    * @dev Fallback function for funding smart contract.
    *
    */
    fallback() external payable requireAuthorizedCaller {
        fund(msg.sender, msg.value);
    }

    function numberAirlineVotes (address _address) external view 
        requireIsOperational requireAuthorizedCaller
        returns (uint256) {
            return airlines[_address].votes.length;
    }

    function amountAirlineFunds(address _address) external view
        requireIsOperational requireAuthorizedCaller
        returns (uint) {
            return airlines[_address].funds;
        }
    
    function isAirlineNominated(address _address) external view
        requireIsOperational requireAuthorizedCaller
        returns (bool)  {
            return airlines[_address].status != AirlineStatus.NonMember;
        }
    
    function isAirlineRegistered(address _address) external view
        requireIsOperational requireAuthorizedCaller
        returns (bool) {
            return airlines[_address].status == AirlineStatus.Registered ||
                airlines[_address].status == AirlineStatus.Funded;
        }

    function isAirlineFunded(address _address) external view
        requireIsOperational requireAuthorizedCaller
        returns (bool) {
            return airlines[_address].status == AirlineStatus.Funded;
        }

    function airlineMembership(address _address) external view 
        requireIsOperational requireAuthorizedCaller
        returns (uint) {
            return uint(airlines[_address].status);
        }

    function nominateAirline(address _address) external
        requireIsOperational requireAuthorizedCaller {
            airlines[_address] = Airline(
                AirlineStatus.Nominated,
                new address[](0),
                0,
                0
            );
        }
    
    function voteAirline (address voteAddress, address airlineAddress) external
        requireIsOperational requireAuthorizedCaller    
        returns (uint256) {
            airlines[airlineAddress].votes.push(voteAddress);
            return airlines[airlineAddress].votes.length;
        }
    
    function fundAirline(address _address, uint amount) external
         requireIsOperational requireAuthorizedCaller    
        returns (uint256) {
            airlines[_address].funds = airlines[_address].funds.add(amount);
            airlines[_address].status = AirlineStatus.Funded;
            return airlines[_address].funds;
        }

    function registerFlight(address airline, 
        string memory flight, 
        uint256 departureTime,
        uint8 statusCode) external
        requireIsOperational requireAuthorizedCaller 
        returns(bool) {
            bytes32 key = getFlightKey(airline, flight, departureTime);
            flights[key] = Flight({
                isRegistered: true,
                airline: airline,
                flight: flight,
                departureTime: departureTime,
                statusCode: statusCode
            });
            return flights[key].isRegistered;
        }

    function updateFlightStatus (bytes32 flightKey,
                    uint8 statusCode) external 
        requireIsOperational requireAuthorizedCaller {
            flights[flightKey].statusCode = statusCode;
        }

    function isFlightRegistered (bytes32 key) external view
        requireIsOperational requireAuthorizedCaller
        returns (bool) {
            return flights[key].isRegistered;
        }
    
    function getFlightStatus(bytes32 key) external view 
        requireIsOperational requireAuthorizedCaller
        returns(uint8) {
            return flights[key].statusCode;
        }

    function getUnderwrittenAmount(address _address) external view
        requireIsOperational requireAuthorizedCaller
        returns (uint256) {
            return airlines[_address].underwrittenAmount;
        }

    function buyInsurance (address passengerAddress,
                        address airlineAddress,
                        bytes32 flightKey,
                        uint insuranceAmount) external
        requireIsOperational requireAuthorizedCaller {
            airlines[airlineAddress].underwrittenAmount.add(insuranceAmount);
            flightInsurance[flightKey].amountPurchased[passengerAddress] = insuranceAmount;
            flightInsurance[flightKey].passengers.push(passengerAddress);
        }

    function isPassengerInsured (address passengerAddress, bytes32 flightKey) external view
        requireIsOperational requireAuthorizedCaller
        returns (bool) {
            return flightInsurance[flightKey].amountPurchased[passengerAddress] > 0;
        }
    
    function isPasssengerPaidOut(bytes32 flightKey) external view
        requireIsOperational requireAuthorizedCaller
        returns (bool)  {
            return flightInsurance[flightKey].isPaidOut;
        }
    
    function getPassengerCurrentBalance(address passengerAddress) external view 
        requireIsOperational requireAuthorizedCaller
        returns(uint256) {
            return passengerBalance[passengerAddress];
        }   
}
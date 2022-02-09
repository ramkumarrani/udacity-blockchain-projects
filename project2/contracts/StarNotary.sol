// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../node_modules/openzeppelin-solidity/contracts/token/ERC721/ERC721.sol";

contract StarNotary is ERC721 {

    constructor() ERC721("test name", "TSTN") {
        // only definition is good
    }

    struct Star {
        string name;
    }

    // Implement Task 1 Add a name and symbol properties
    // name: Is a short name to your token
    // symbol: Is a short string like 'USD' -> 'American Dollar'
    string public starName = 'Star Token Project2';
    string public starSymbol = 'ST2';

    // mapping the Star with the Owner Address
    mapping(uint256 => Star) public tokenIdToStarInfo;
    // mapping the TokenId and price
    mapping(uint256 => uint256) public starsForSale;

    // Creating a new star using the struct Star
    function createStar(string memory _name, uint256 _tokenId) public {
        Star memory newStar = Star(_name);
        tokenIdToStarInfo[_tokenId] = newStar;
        _mint(msg.sender, _tokenId);
        // _mint(address(this), _tokenId);
    }

    // putting up star for sale.  (Adding the star tokenid into the mapping starsForSale, first verify that the sender is the owner)
    function putStarUpForSale(uint256 _tokenId, uint256 _price) public {
        require(ownerOf(_tokenId) == msg.sender, "Not an owner to put up star for sale");
        starsForSale[_tokenId] = _price;
    }

    // Function that allows you to convert an address into a payable address
    function _make_payable(address x) internal pure returns (address payable) {
        return payable(x); //address(uint160(x));
    }

    // Function to buy this star
    function buyStar(uint256 _tokenId) public payable {
        require(starsForSale[_tokenId] > 0, "the star should be up for sale");
        uint starCost = starsForSale[_tokenId];
        address ownerAddress = ownerOf(_tokenId);
        require(msg.value > starCost, "You need to have enough Ether");
        transferFrom(ownerAddress, msg.sender, _tokenId); // We can't use _addTokenTo or_removeTokenFrom functions, now we have to use _transferFrom
        address payable ownerAddressPayable = _make_payable(ownerAddress); // We need to make this conversion to be able to use transfer() function to transfer ethers
        ownerAddressPayable.transfer(starCost);
        if(msg.value > starCost) {
            payable(msg.sender).transfer(msg.value - starCost);
        }
        // starsForSale[_tokenId] = 0;
    }
    // Implement Task 1 lookUptokenIdToStarInfo
    function lookUptokenIdToStarInfo (uint _tokenId) public view returns (string memory) {
        //1. You should return the Star saved in tokenIdToStarInfo mapping
        return tokenIdToStarInfo[_tokenId].name;  // returning star name
    }

    // Implement Task 1 Exchange Stars function
    function exchangeStars(uint256 _tokenId1, uint256 _tokenId2) public {
        //1. Passing to star tokenId you will need to check if the owner of _tokenId1 or _tokenId2 is the sender
        //2. You don't have to check for the price of the token (star)
        //3. Get the owner of the two tokens (ownerOf(_tokenId1), ownerOf(_tokenId1)
        //4. Use _transferFrom function to exchange the tokens.

        address ownerOfToken1 = ownerOf(_tokenId1);
        address ownerOfToken2 = ownerOf(_tokenId2);

        // exception handling of owning a star
        require(ownerOfToken1 == msg.sender || ownerOfToken2 == msg.sender, "You must own a star to exchange it");
        
        // transfer stars
        transferFrom(ownerOfToken1, ownerOfToken2, _tokenId1); // move owner of 1 to 2
        transferFrom(ownerOfToken2, ownerOfToken1, _tokenId2); // move owner of 2 to 1
    }

    // Implement Task 1 Transfer Stars
    function transferStar(address _to1, uint256 _tokenId) public {
        //1. Check if the sender is the ownerOf(_tokenId)
        //2. Use the transferFrom(from, to, tokenId); function to transfer the Star

        address tokenOwner = ownerOf(_tokenId);
        require (tokenOwner == msg.sender, "You are not the owner");
        transferFrom(tokenOwner, _to1, _tokenId);  // transfer token owner
    }
}
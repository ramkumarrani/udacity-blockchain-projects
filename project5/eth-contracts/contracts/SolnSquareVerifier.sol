pragma solidity >=0.4.21 <0.6.0;

import './ERC721Mintable.sol';
import './Verifier.sol';

contract SolnSquareVerifier is RRERC721Token {
// TODO define a contract call to the zokrates generated solidity contract <Verifier> or <renamedVerifier>
// TODO define another contract named SolnSquareVerifier that inherits from your ERC721Mintable class

    Verifier verifier;
    address private contractOwner;

// TODO define a solutions struct that can hold an index & an address
    struct Solution {
        uint256 index;
        address client;
    }

// TODO define an array of the above struct
    Solution[] private solutions;

// TODO define a mapping to store unique solutions submitted
    mapping (bytes32 => Solution) uniqueSolution;

// TODO Create an event to emit when a solution is added
    event AddSolution(uint256 index, address client);

    constructor(string memory name, string memory symbol) public
        RRERC721Token(name, symbol) {
            contractOwner = msg.sender;
            verifier = new Verifier();
        }

    modifier onlyOwner() {
        require(msg.sender == contractOwner, "only owner can use this transaction");
        _;
    }

// TODO Create a function to add the solutions to the array and emit the event

    function addSolution(uint256 index, address client) internal {
        bytes32 key = keccak256(abi.encodePacked(index, client));
        
        Solution memory solution = Solution({
            index: index,
            client: client
        });

        solutions.push(solution);

        uniqueSolution[key] = solution;
        emit AddSolution(index, client);
    }
    // added up to here.... ramkumar rani

// TODO Create a function to mint new NFT only after the solution has been verified
//  - make sure the solution is unique (has not been used before)
//  - make sure you handle metadata as well as tokenSupply
    function mintNewNFT(
        address to,
        uint256 tokenId,
        uint[2] calldata a,
        uint[2] calldata a_p,
        uint[2][2] calldata  b,
        uint[2] calldata b_p,
        uint[2] calldata c,
        uint[2] calldata c_p,
        uint[2] calldata h,
        uint[2] calldata k,
        uint[2] calldata input
    ) external onlyOwner {
        bytes32 key = keccak256(abi.encodePacked(tokenId, to));

        require(uniqueSolution[key].client ==  address(0), "error: Solution already exists");
        require(verifier.verifyTx(a, a_p, b, b_p, c, c_p, h, k, input), "error: zokrates proof is invalid");

        // minting new token
        super.mint(to, tokenId);
        // maintain the metadata
        addSolution(tokenId, to);
    }
}
pragma solidity ^0.5.1;

contract Test {
    uint a;

    constructor(uint _a) public {
        a = _a;
    }

    function getA(uint x, uint y) public view returns(uint) {
        if (a > 0 )
            return y-x;
        else 
            return x-y;
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

contract Functions {
    
    function returnMany () public pure returns ( uint, bool, uint ) {
        return (1, true, 2);
    }
    
    function returnManyNamed () public pure returns ( uint someInt, bool trueOrFalse, uint someInt2) {
        return (1, true, 2);
    }


    function returnManyAssigned () public pure returns ( uint x , bool b, uint y) {
         x=1;
         b=true;
         y=10; // return stmt can be ommited
    }

    function destructuringAssignments () public pure returns (uint, bool, uint, uint, bool ) {
        (uint i, bool b, uint j) = returnManyNamed();

        // values can be left out
        (uint x, , bool y) = (4,5,false);

        return (i,b,j,x,y);
    }


    /* # Map cannot be used for either input or output */

    // can use array for input 
    function arrayInput (uint[] memory _arr) public pure {}

    // can use array for output    
    uint[] public arr;
    function arrayOutput() public returns (uint[] memory ) {
        arr.push(12);
        arr.push(1);
        return arr;
    }
}

contract XYZ{
    function someFuncWithManyInputs (
        uint x,
        uint y,
        uint z,
        address a,
        bool b,
        string memory s
    ) public pure returns (uint) {

    }

    function callFunc() external pure returns (uint) {
        return someFuncWithManyInputs(1, 2, 3, address(0), true, "This is string");
    }

    function callFunctionWithKeyValue() external pure returns (uint) {
        return someFuncWithManyInputs({a:address(0), b:false, s:"This is string", x:1, y:2, z:3});
    }
}
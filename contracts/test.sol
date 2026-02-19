// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "hardhat/console.sol";

contract calldata_memory {
    
    string stringTest;

    // stringTest = "TestString";   // incorrect initialization - not allowed outside of a function or constructor
    // console.log(stringTest);


    function memoryTest(string memory _exampleString) public pure returns (string memory) {
        _exampleString = "example";  // You can modify memory
        string memory newString = _exampleString;  // You can use memory within a function's logic
        return newString;  // You can return memory
    }
    
    function calldataTest(string calldata _exampleString) external pure returns (string memory) {
        // cannot modify _exampleString
        // but can return it
        // _exampleString = "isAssigned";
             //TypeError: Type literal_string "isAssigned" is not implicitly convertible to expected type string calldata.

        console.log("");
        return _exampleString;
    }


}
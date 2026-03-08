// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

contract TestContract {
    uint public i;

    function CallMe(uint j) public {
        i += j;
    }

    /* Value Types vs. Reference Types 
        Value Types (uint, int, bool, address): These are simple, fixed-size data. Solidity passes them by value 
    (copying the actual number). They don't need a data location specifier because they fit directly into the stack.
    
        Reference Types (bytes, string, structs, arrays): These can be very large. Passing them by value would be 
    expensive in terms of gas. Instead, Solidity passes a reference (a pointer) to where the data is stored. 
    You must tell Solidity where that data is located.*/

    function getData() public pure returns (bytes memory) {
        return abi.encodeWithSignature("callMe(uint256) ", 123);   // gemini - Remove the space after uint. abi.encode is very sensitive; a space will change the hash and the function call will fail.
    }
}
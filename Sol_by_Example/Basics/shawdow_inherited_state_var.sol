// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

contract A {
    string public name = "Contract A";

    function getName() public view returns (string memory) {
        return name;
    }
}

// shadowing is disallowed in Solidity 0.6
// contract B is A { 
    // string public name = "Contract B";
// }

contract C is A {

    // overriding inherited state variables.
    constructor() {
        name = "Contract C";
    }
}
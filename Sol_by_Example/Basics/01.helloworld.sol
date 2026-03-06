// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "hardhat/console.sol";

contract HelloWorld {
    string public greet  = "Hello World!";
}

contract HelloWordl2 {
    string greet = "Hello World";

    function greetFunc() public view returns (string memory){
        uint x  = 10;
        console.log("valueof x : ",x);
        return greet;
    }
}
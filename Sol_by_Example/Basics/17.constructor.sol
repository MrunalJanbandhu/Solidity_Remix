// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "hardhat/console.sol";

contract X {
    string public name;

    constructor(string memory _name){
        name = _name;
    }

}

contract Y {
    string public text;

    constructor(string memory _text){
        text = _text;
    }
}

// 2 ways to initializae parent contract with parameters

// 1. pass the parameters here in the inheritance list
contract B is X("Input to X"), Y("Input to Y") {}

// 2. Pass the parameters here in the contructor, similar to function modifiers.
contract C is X, Y {
    constructor(string memory _name, string memory _text) X(_name) Y(_text) {}
}

// Parent contructors are always called in the order of inheritance regardless of the 
// order of parents contracts listed in the constructor of the child contract.
/*
    Order of contrcotr called
    1. X
    2. Y
    3. D
*/

contract D is X,Y {
    function consolelog() public pure {
        console.log("D called");
    }
    constructor() X("X called") Y("Y called") {
        console.log("executed when contract is created");
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

contract General {
    string public text = "Hello";
    uint public num = 7;

    function someFunc() public view  {
        uint localVar = 324;

        localVar += 1;
        
        // global
        uint256 timestamp = block.timestamp;
        address sender = msg.sender; 

        // ---
        timestamp += 1;
        require( sender == msg.sender);

    }

    // constants
    address public constant someAddr = 0x777788889999AaAAbBbbCcccddDdeeeEfFFfCcCc;
    uint public constant someNumber = 13224;


    // immutables
    // immutbale vars are like consts, value of immutable var can be set inside the constructor but cannot be modified afterwards

    address public immutable myAddr;
    uint public immutable myUnit;

    constructor(uint _myUnit) {
        myAddr = msg.sender;
        myUnit = _myUnit;
    }

}
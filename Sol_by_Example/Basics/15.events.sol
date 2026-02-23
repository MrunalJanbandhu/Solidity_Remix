// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

/*
Evenets allow logging to the ethereum blockchain. Some user cases are:
    - listening for events and updating user interface 
    - a cheap form of storage
*/

contract Events {
    // event declaration - upto 3 parameters can be indexed, indexed paramerts help you filer the logs by indexed params
    event Log(address indexed sender, string message);
    event AnotherLog();

    function test() public {
        emit Log(msg.sender, "Hello to Logs Event");
        emit Log(msg.sender, "Log to the EVM");
        emit AnotherLog();
    }
}

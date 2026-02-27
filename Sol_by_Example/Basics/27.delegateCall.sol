// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

/* delegatecall is a low level function similar to call,
When contract A executes deleatecall to contract B, B's code is executed
with contract A's storage, msg.sender and msg.value
*/

// deploy contract B first
contract B {
    // storage layout must be the same as contract A
    uint public num;
    address public sender;
    uint public value;

    function setVars(uint _num) public payable {
        num = _num;
        sender = msg.sender;
        value = msg.value;
    }
}

contract A {
    uint public num;
    address public sender;
    uint public value;

    event DelegateResponse(bool success, bytes data);
    event CallResponse(bool success, bytes data);

    // function using delegtecall
    function setVarsDelegateCall(address _contract, uint _num) public payable {
        (bool success, bytes memory data) = _contract.delegatecall(
            abi.encodeWithSignature("setVars(uint)", _num)
        );

        emit DelegateResponse(success, data);
    }

    function setVarsCall(address _contract, uint _num) public payable {
        (bool success, bytes memory data) = _contract.call{value: msg.value}(
            abi.encodeWithSignature("setVars(uint)", _num)
        );

        emit CallResponse(success, data);
    }
}
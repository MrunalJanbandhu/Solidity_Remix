// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

contract Payable {
    // Payable address can send Ether via tranfer or send
    address payable public owner;

    // payable constr. can receive Ether
    constructor() payable {
        owner = payable (msg.sender);
    }

    // function to receive Ether into this contract, call this fn() along with some Ether
    function deposit() public payable {}

    // error, not payable fn()
    function nonpayable () public {}

    function withdraw() public {
        // get the amount of ether stored in this address
        uint amount = address(this).balance;

        // send all ether to owner
        (bool success,) = owner.call{value:amount}("");
        require(success, "Failed to send Ether");
    }

    // Function to tranfer Ether from this contract toaddress from input
    function transfer(address payable _to, uint _amount) public {
        // not that "to" is declared as payable
        (bool success,) = _to.call{value:_amount}("");
        require(success, "Failed to send Ether");
    }

}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

contract TestCallToContract {
    receive() external payable { } 

    function adminWithdraw(address payable _to, uint256 _amount) public payable {
        require(_amount <= address(this).balance, "Insufficient balance");

        (bool success, ) = _to.call{value: _amount}("");
        require(success, "Admin withdraw failed");
    }

    function withdraw() public payable {
        (bool success,) = payable(msg.sender).call{value: address(this).balance}("");
        // (bool success,) = payable(msg.sender).call{value: msg.value}("");
        require(success,"withdraw failed");
    }

    function sendEtherToAccount(address payable _to) public payable {
        (bool success,) = _to.call{value: address(this).balance}("");
        // (bool success,) = payable(msg.sender).call{value: msg.value}("");
        require(success,"failed to send ether");
    }

    function getContactBalance() public view returns (uint256) {
        return address(this).balance;
    }
}
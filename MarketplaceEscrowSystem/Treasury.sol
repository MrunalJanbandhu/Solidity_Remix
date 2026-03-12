// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "./AccessManager.sol";

contract Treasury is AccessManager {

    error ZeroAmount();
    error TransferFailed();
    error InsufficientBalance();

    event FeeReceived(address indexed sender, uint256 amount);
    event FallbackCalled(address indexed sender, uint256 amount, bytes data);
    event Withdrawn(address indexed to, uint256 amount);

    receive() external payable {
        emit FeeReceived(msg.sender, msg.value);
    }

    fallback() external payable {
        emit FallbackCalled(msg.sender, msg.value, msg.data);
    }


    function withdraw(address to, uint256 amount) external onlyRole(ADMIN) {
        if (to == address(0))            
            revert ZeroAddress();
        if (amount == 0)
            revert ZeroAmount();
        if (amount > address(this).balance) 
            revert InsufficientBalance();

        (bool success, ) = to.call{ value: amount }("");
        if (!success) revert TransferFailed();

        emit Withdrawn(to, amount);
    }

    function balance() external view returns (uint256) {
        return address(this).balance;
    }
}
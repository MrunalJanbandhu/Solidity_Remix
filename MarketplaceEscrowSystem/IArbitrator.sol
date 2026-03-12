// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

interface IArbitrator {
    function notifyDispute(uint256 orderId, address buyer, address seller, uint256 amount) external;
}

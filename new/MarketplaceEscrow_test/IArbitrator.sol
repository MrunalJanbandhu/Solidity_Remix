// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;
 
/// @title IArbitrator
/// @notice Interface that any external arbitrator contract must implement.
///         EscrowMarketplace calls `notifyDispute` when a dispute is opened.
interface IArbitrator {
    /// @notice Notify the arbitrator that order `orderId` is now disputed.
    /// @param orderId  The disputed order ID
    /// @param buyer    Buyer address
    /// @param seller   Seller address
    /// @param amount   Escrowed amount in wei
    function notifyDispute(
        uint256 orderId,
        address buyer,
        address seller,
        uint256 amount
    ) external;
}

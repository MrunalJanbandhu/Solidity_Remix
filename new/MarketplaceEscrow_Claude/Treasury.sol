// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;
 
import "./AccessManager.sol";

/// @title Treasury
/// @notice Holds marketplace fees; admin can withdraw accumulated ETH
contract Treasury is AccessManager {
    // ─────────────────────────── Errors ──────────────────────────

    error ZeroAmount();
    error TransferFailed();
    error InsufficientBalance(uint256 requested, uint256 available);

    // ─────────────────────────── Events ──────────────────────────

    event FeeReceived(address indexed from, uint256 amount);
    event Withdrawn(address indexed to, uint256 amount);
    event FallbackCalled(address indexed sender, uint256 value, bytes data);

    // ──────────────────────── ETH Reception ──────────────────────

    /// @notice Accept ETH sent directly (fees forwarded from EscrowMarketplace)
    receive() external payable {
        emit FeeReceived(msg.sender, msg.value);
    }

    /// @notice Catch any other calls with data
    fallback() external payable {
        emit FallbackCalled(msg.sender, msg.value, msg.data);
    }

    // ──────────────────────── Admin Actions ──────────────────────

    /// @notice Withdraw `amount` of ETH to `to` (admin only)
    /// @param to      Recipient address
    /// @param amount  Amount in wei
    function withdraw(address to, uint256 amount) external onlyRole(ROLE_ADMIN) {
        if (to == address(0)) revert ZeroAddress();
        if (amount == 0) revert ZeroAmount();
        uint256 bal = address(this).balance;
        if (amount > bal) revert InsufficientBalance(amount, bal);

        // CEI: state cleared before external call (balance tracks via EVM)
        (bool ok, ) = to.call{value: amount}("");
        if (!ok) revert TransferFailed();

        emit Withdrawn(to, amount);
    }

    // ──────────────────────── View ────────────────────────────────

    /// @notice Current ETH balance held in the treasury
    function balance() external view returns (uint256) {
        return address(this).balance;
    }
}

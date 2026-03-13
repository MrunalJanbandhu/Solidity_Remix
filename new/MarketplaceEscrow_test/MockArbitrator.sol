// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;
    
import "./IArbitrator.sol";

/// @title MockArbitrator
/// @notice Records dispute notifications for test assertions
contract MockArbitrator is IArbitrator {
    struct DisputeRecord {
        uint256 orderId;
        address buyer;
        address seller;
        uint256 amount;
    }

    DisputeRecord[] public disputes;
    uint256 public notifyCount;

    event DisputeNotified(uint256 indexed orderId, address buyer, address seller, uint256 amount);

    /// @inheritdoc IArbitrator
    function notifyDispute(
        uint256 orderId,
        address buyer,
        address seller,
        uint256 amount
    ) external override {
        disputes.push(DisputeRecord(orderId, buyer, seller, amount));
        notifyCount++;
        emit DisputeNotified(orderId, buyer, seller, amount);
    }

    /// @notice Retrieve the last recorded dispute
    function lastDispute() external view returns (DisputeRecord memory) {
        require(disputes.length > 0, "no disputes");
        return disputes[disputes.length - 1];
    }
}

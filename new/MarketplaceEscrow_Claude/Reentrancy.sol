// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

interface IEscrow {
    function createOrder(address seller, bytes32 detailsHash) external returns (uint256);
    function fundOrder(uint256 orderId) external payable;
    function confirmReceived(uint256 orderId) external;
}

/// @dev Attack contract that attempts reentrancy on confirmReceived via receive()
contract ReentrantBuyer {
    IEscrow public escrow;
    uint256 public orderId;
    bool    private _attacking;

    constructor(address _escrow) {
        escrow = IEscrow(_escrow);
    }

    function setup(address seller, bytes32 detailsHash) external {
        orderId = escrow.createOrder(seller, detailsHash);
    }

    function fund() external payable {
        escrow.fundOrder{value: msg.value}(orderId);
    }

    function attack() external {
        _attacking = true;
        escrow.confirmReceived(orderId);
    }

    /// @dev On receiving ETH (seller payout), attempt to re-enter confirmReceived
    receive() external payable {
        if (_attacking) {
            _attacking = false;
            // This should be blocked by the reentrancy guard
            escrow.confirmReceived(orderId);
        }
    }
}

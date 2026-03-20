// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;
   
import "./IArbitrator.sol";

contract MockArbitrator is IArbitrator {
    // resolve dispute, notifyDispute from interface 

    struct DisputeRecord {
        uint256 orderId;
        address buyer;
        address seller;
        uint256 amount;
    }

    DisputeRecord[] public disputes;

    event DisputeNotified(uint256 indexed orderId, address buyer, address seller, uint256 amount);

    function notifyDispute(uint256 orderId, address buyer, address seller, uint256 amount) 
        external override 
        {
            // notify dispute - push into appropriate data type
            disputes.push(DisputeRecord(orderId, buyer, seller, amount));
            emit DisputeNotified(orderId, buyer, seller, amount);   
        } 

    function disputeCount() external view returns (uint256) {
        return disputes.length;
    }

    function getDispute(uint256 index) external view returns (DisputeRecord memory) {
        return disputes[index];
    }

}
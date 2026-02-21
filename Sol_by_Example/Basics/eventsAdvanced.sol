// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

/*
Events are powerful tool that enables adv functionlaitites and architecrures.
    - Event filetering and monitoring for real-time updates and analytics
    - Event log analysis and decoding for data extraction and processing
    - Event-driven architecures for decentrailzed applications(dApps)
    - Event subscriptions for real-time notificaitons and updates

        EventDrivenArchitecure contract demos event-driven arch. where events are used to coordinate and
    triggers different stages of a process, such as initiating and confirming transfers.

        EventSubscription contract showcases how to implemtn event subs., allowing ext contracts or clients to 
    subscribe and receive real-time updates when events are emitted. Also demos how to handle event subscriptions 
    and manage the subscription lifecycle. 
*/

contract EventDrivenArchitecure {
    event TransferInitiated(
        address indexed from, address indexed to, uint vlaue
    );
    event TransferConfirmed(
        address indexed from, address indexed, uint value
    );

    mapping (bytes32 => bool) public transferConfimation;

    function initiateTranfer(address to, uint value) public {
        emit TransferInitiated(msg.sender, to, value);

        // initiate tranfer logic
    }

    function confirmTrasfer(bytes32 transferId) public {
        require(!transferConfimation[transferId], "Transfer aldready confirmed");
        transferConfimation[transferId] = true;
        emit TransferConfirmed(msg.sender, address(this), 0);
        // confirm transfer logic
    }
}

contract EventSubscription{
    
}
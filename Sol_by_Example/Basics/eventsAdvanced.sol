// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "hardhat/console.sol";

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

    function consolelog() public pure{
        console.log("Yo");
    }
}


// Event Subscription and Real-Time Updates
interface IEventSubscriber {
    function handleTransferEvent(address from, address to, uint value) external;
}

contract EventSubscription{
    event LogTransfer(address indexed from, address indexed to, uint value);

    mapping(address =>bool) public subscribers;
    address[] public subscribersList;

    function subscribe() public {
        require(!subscribers[msg.sender], "Already Subscribed");
        subscribers[msg.sender] = true;
        subscribersList.push(msg.sender);
    }    

    function unsubscribe() public {
        require(subscribers[msg.sender], "Not subscribed");
        subscribers[msg.sender] = false;
        for(uint i=0; i<subscribersList.length ;i++){
            if(subscribersList[i] == msg.sender){
                subscribersList[i] = subscribersList[subscribersList.length -1];
                subscribersList.pop();
                break;
            }
        }
    }

    function transfer(address to, uint value) public {
        emit LogTransfer(msg.sender, to, value);
        for(uint i=0;i<subscribersList.length; i++){
            IEventSubscriber(subscribersList[i]).handleTransferEvent(
                msg.sender, to , value
            );
        }
    }
}

/*
    - Index the right event parameters to enable efficient filtering and searching. 
    Address should typically be indexed, while amounts generally should not.
    - Avoid redundant events by not emitting events that are already covered by underlying libraries or contracts.
    - Events cannot be used in view or pure functions, as they alter the state of the blockchain by storing logs.
    - Be mindful of the gas cost associated with emitting evetns, especially when indexing parameters, as it can impact 
    overall gas consumption of your contract.
*/
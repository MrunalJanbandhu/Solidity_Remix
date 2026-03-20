// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "./AccessManager.sol";
import "./Treasury.sol";
import "./IArbitrator.sol";

contract EscrowMarketplace is AccessManager {
   
    enum OrderState {
        Created,
        Funded,
        Shipped,
        Completed,
        Disputed,
        Refunded,
        Cancelled
    }

    struct Order {
        uint256 id;
        address buyer;
        address seller;
        uint256 amount;
        uint256 createdAt;
        bytes32 detailsHash;            // off-chain metadata hash
        OrderState state;
    }
    
    Treasury public immutable treasury;
    IArbitrator public arbitrator;

    uint256 private _nextOrderId = 1;   // question - why private
    bool private _locked;               // false by default

    // OrderId => struct Order 
    mapping (uint256 => Order ) private _orders;

    uint256 public feeBps = 100;
    uint256 public constant MAX_FEE_BPS = 500;

    error NonReentrant();
    error NotBuyer(uint256);
    error InvalidState(uint256, OrderState);
    error ZeroAmount();
    error TransferFailed();   
    error OrderNotFound(uint256); 
    error NotSeller(uint256);
    error FeeTooHigh(uint256, uint256);

    event OrderCreated(
        uint256 indexed orderId, 
        address indexed buyer,
        address indexed seller,
        bytes32 detailHash
    );
    event OrderFunded(uint256 indexed id, uint256 amount);
    event OrderShipped(uint256 indexed id);
    event OrderCompleted(uint256 indexed id, uint256 payoutToSeller, uint256 fee);
    event DisputeOpened(uint256 indexed id, address indexed openedBy);
    event DisputeResolved(uint256 indexed id, bool releasedToSeller);
    event Refunded(uint256 indexed id, uint256 amount);
    event Cancelled(uint256 indexed id);
    event FeeUpdated(uint256 oldBps, uint256 newBps);
    event ArbitratorUpdated(address oldArbitrator, address newArbitrator);

    modifier nonReentrant() {
        if(_locked) {
            revert NonReentrant();
        }

        _locked = true;
        _;
        _locked = false;
    }

    constructor (address payable treasuryAddress, address arbitratorAddress) {
        if( treasuryAddress == address(0)) revert ZeroAddress();
        if( arbitratorAddress == address(0)) revert ZeroAddress();

        treasury = Treasury(treasuryAddress);
        arbitrator = IArbitrator(arbitratorAddress);
    }
    
    // buyer flow
    // question - why external and not public?
    function createOrder(address _seller, bytes32 _detailHash) external returns (uint256 orderId) {
        if(_seller == msg.sender)
            revert Unauthorized();
        if(!hasRole(_seller,SELLER))
            revert Unauthorized();
       

        orderId = _nextOrderId++;

        _orders[orderId] = Order({
            id:          orderId,
            buyer:       msg.sender,
            seller:      _seller,
            amount:      0,
            createdAt:   block.timestamp,
            detailsHash: _detailHash,          // off-chain metadata hash
            state:       OrderState.Created
        });

        emit OrderCreated(orderId, msg.sender, _seller, _detailHash);
    }

    function fundOrder(uint256 orderId) payable external nonReentrant {
        Order storage o = _orders[orderId];

        if ( o.buyer != msg.sender ) 
            revert NotBuyer(orderId);
        if ( o.state != OrderState.Created )
            revert InvalidState(orderId, o.state);
        if( msg.value == 0 )
            revert ZeroAmount();

        o.amount = msg.value;
        o.state = OrderState.Funded;

        emit OrderFunded(orderId, msg.value);

    } 

    function confirmReceived(uint256 orderId) external nonReentrant {
        Order storage o = _orders[orderId];

        if( msg.sender != o.buyer ) 
            revert NotBuyer(orderId);
        if( o.state != OrderState.Shipped ) 
            revert InvalidState(orderId, o.state);

        o.state = OrderState.Completed;

        (uint256 payout, uint256 fee) = _calcFee(o.amount);

        emit OrderCompleted(orderId, payout, fee);

        _safeTransfer(o.seller, payout);
        _safeTransfer(address(treasury), fee);

    }

    function cancelUnfunded(uint256 orderId) external {
        Order storage o = _getOrder(orderId);

        if(o.buyer != msg.sender) {
            revert NotBuyer(orderId);
        }
        if(o.state != OrderState.Created){
            revert InvalidState(orderId, o.state);
        }
        
        o.state = OrderState.Cancelled;

        emit Cancelled(orderId);
    }

    // Seller flow
    function markShipped(uint256 orderId) external {
        Order storage o = _getOrder(orderId);

        if( msg.sender != o.seller)     
            revert NotSeller(orderId);
        if( o.state != OrderState.Funded)
            revert InvalidState(orderId, o.state);

        o.state = OrderState.Shipped;

        emit OrderShipped(orderId);

    }

    // Dispute Flow
    function openDispute(uint256 orderId) external {
        Order storage o = _getOrder(orderId);

        if( msg.sender != o.buyer ) {
            revert NotBuyer(orderId);
        }
        if( o.state != OrderState.Funded && o.state != OrderState.Shipped ){
            revert InvalidState(orderId, o.state);
        }

        o.state = OrderState.Disputed;

        emit DisputeOpened(orderId, msg.sender);

        try arbitrator.notifyDispute( orderId, o.buyer, o.seller, o.amount ) {}
        catch {}
    }

    function resolveDispute (uint256 orderId, bool releaseToSeller) external nonReentrant onlyRole(MEDIATOR) {
        Order storage o = _getOrder(orderId);

        if( o.state != OrderState.Disputed) {
            revert InvalidState(orderId, o.state);
        }

        if( releaseToSeller ) {
            o.state = OrderState.Completed;
        }
        else {
            o.state = OrderState.Refunded;
        }

        emit DisputeResolved(orderId, releaseToSeller);

        if( releaseToSeller ) {
            (uint256 payout, uint256 fee) = _calcFee(o.amount);
            emit OrderCompleted(orderId, payout, fee);
            _safeTransfer(address(treasury), fee);
            _safeTransfer(o.seller, payout);
        }
        else {
            emit Refunded(orderId, o.amount);
            _safeTransfer(o.buyer, o.amount);
        }

    }
    
    function refundBuyer(uint256 orderId) external nonReentrant onlyRole(MEDIATOR) {
        Order storage o = _getOrder(orderId);

        if( o.state != OrderState.Disputed ) {
            revert InvalidState(orderId, o.state);
        }

        uint256 amt = o.amount;
        o.state = OrderState.Refunded;

        emit Refunded(orderId, o.amount);

        _safeTransfer(o.buyer, amt);
    }

    // Admin
    function updateFee(uint256 newBps) external onlyRole(ADMIN) {
        if( newBps > MAX_FEE_BPS ) {
            revert FeeTooHigh(newBps, MAX_FEE_BPS);
        }

        emit FeeUpdated(feeBps, newBps);

        feeBps = newBps;
    }

    function setArbitrator(address newArbitrator) external onlyRole(ADMIN) {
        if( newArbitrator == address(0) ) {
            revert ZeroAddress();
        }

        emit ArbitratorUpdated(address(arbitrator), newArbitrator);

        arbitrator = IArbitrator(newArbitrator);
    }

    function getOrder(uint256 orderId) external view returns (Order memory) {
        return _getOrder(orderId);
    }

    function _getOrder(uint256 orderId) internal view returns (Order storage) {
        Order storage o = _orders[orderId];
        if( o.buyer == address(0) ) 
            revert OrderNotFound(orderId);
        return o;
    }

    function _safeTransfer(address to, uint256 amount) internal {
        if( amount == 0)
            return;
        (bool ok, ) = to.call{value: amount}("");
        if (!ok) revert TransferFailed();
    }

    function _calcFee(uint256 amount) internal view returns(uint256 payout, uint256 fee) {
        fee = (amount * feeBps) / 10_000; // question - 10_000?
        payout = amount - fee;
    }
}
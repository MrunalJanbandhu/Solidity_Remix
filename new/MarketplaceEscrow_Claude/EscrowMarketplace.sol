// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "./AccessManager.sol";
import "./IArbitrator.sol";

/// @title EscrowMarketplace
/// @notice Multi-party escrow marketplace with strict state-machine order lifecycle.
///         Inherits AccessManager for role-based access control.
///         Fees are forwarded to an external Treasury contract.
///         Reentrancy guard implemented manually (no OpenZeppelin).
contract EscrowMarketplace is AccessManager {

    // ─────────────────────────── State Machine ───────────────────

    enum OrderState {
        Created,    // 0 — order exists, not yet funded
        Funded,     // 1 — buyer has deposited ETH
        Shipped,    // 2 — seller has marked as shipped
        Completed,  // 3 — buyer confirmed receipt, funds released
        Disputed,   // 4 — dispute opened, awaiting mediator
        Refunded,   // 5 — dispute resolved in buyer's favour
        Cancelled   // 6 — cancelled before funding
    }

    // ─────────────────────────── Data Types ──────────────────────

    struct Order {
        uint256   id;
        address   buyer;
        address   seller;
        uint256   amount;       // agreed price in wei (set when funded)
        uint256   createdAt;    // block.timestamp at creation
        bytes32   detailsHash;  // off-chain metadata hash (IPFS / backend)
        OrderState state;
    }

    // ─────────────────────────── Storage ─────────────────────────

    /// @notice Treasury contract that receives marketplace fees
    address payable public treasury;

    /// @notice Optional external arbitrator (can be address(0))
    address public arbitrator;

    /// @notice Fee in basis points (1 BPS = 0.01%).  Default 100 BPS = 1%
    uint16 public feeBps;

    uint16 public constant MAX_FEE_BPS = 500; // 5% hard cap

    uint256 public nextOrderId;

    mapping(uint256 => Order) public orders;

    /// @dev Manual reentrancy lock
    bool private _locked;

    // ─────────────────────────── Errors ──────────────────────────

    error InvalidState(uint256 orderId, OrderState current, OrderState expected);
    error NotBuyer(uint256 orderId, address caller);
    error NotSeller(uint256 orderId, address caller);
    error IncorrectPayment(uint256 sent, uint256 required);
    error TransferFailed();
    error FeeTooHigh(uint16 bps, uint16 max);
    error ReentrantCall();
    error SameAddress();

    // ─────────────────────────── Events ──────────────────────────

    event OrderCreated(uint256 indexed id, address indexed buyer, address indexed seller, bytes32 detailsHash);
    event OrderFunded(uint256 indexed id, uint256 amount);
    event OrderShipped(uint256 indexed id);
    event OrderCompleted(uint256 indexed id, uint256 payoutToSeller, uint256 fee);
    event DisputeOpened(uint256 indexed id, address indexed openedBy);
    event DisputeResolved(uint256 indexed id, bool releasedToSeller);
    event Refunded(uint256 indexed id, uint256 amount);
    event Cancelled(uint256 indexed id);
    event FeeUpdated(uint16 oldBps, uint16 newBps);
    event ArbitratorUpdated(address indexed oldArbitrator, address indexed newArbitrator);
    event TreasuryUpdated(address indexed oldTreasury, address indexed newTreasury);

    // ─────────────────────────── Modifiers ───────────────────────

    modifier nonReentrant() {
        if (_locked) revert ReentrantCall();
        _locked = true;
        _;
        _locked = false;
    }

    modifier onlyBuyer(uint256 orderId) {
        if (orders[orderId].buyer != msg.sender) revert NotBuyer(orderId, msg.sender);
        _;
    }

    modifier onlyOrderSeller(uint256 orderId) {
        if (orders[orderId].seller != msg.sender) revert NotSeller(orderId, msg.sender);
        _;
    }

    modifier inState(uint256 orderId, OrderState expected) {
        OrderState current = orders[orderId].state;
        if (current != expected) revert InvalidState(orderId, current, expected);
        _;
    }

    // ─────────────────────────── Constructor ─────────────────────

    /// @param _treasury   Address of deployed Treasury contract
    /// @param _feeBps     Initial fee in basis points (≤ 500)
    /// @param _arbitrator Optional external arbitrator (pass address(0) to skip)
    constructor(address payable _treasury, uint16 _feeBps, address _arbitrator) {
        if (_treasury == address(0)) revert ZeroAddress();
        if (_feeBps > MAX_FEE_BPS) revert FeeTooHigh(_feeBps, MAX_FEE_BPS);

        treasury   = _treasury;
        feeBps     = _feeBps;
        arbitrator = _arbitrator;
        nextOrderId = 1;
    }

    // ══════════════════════ BUYER ACTIONS ════════════════════════

    /// @notice Create a new order with an off-chain metadata hash.
    /// @param seller       Seller's address (must hold ROLE_SELLER)
    /// @param detailsHash  keccak256 of order metadata stored off-chain
    /// @return orderId     ID of the newly created order
    function createOrder(address seller, bytes32 detailsHash)
        external
        returns (uint256 orderId)
    {
        if (seller == address(0)) revert ZeroAddress();
        if (seller == msg.sender) revert SameAddress();
        if (!hasRole(seller, ROLE_SELLER)) revert Unauthorized(seller, ROLE_SELLER);

        orderId = nextOrderId++;

        orders[orderId] = Order({
            id:          orderId,
            buyer:       msg.sender,
            seller:      seller,
            amount:      0,
            createdAt:   block.timestamp,
            detailsHash: detailsHash,
            state:       OrderState.Created
        });

        emit OrderCreated(orderId, msg.sender, seller, detailsHash);
    }

    /// @notice Fund a Created order with the exact agreed ETH amount.
    /// @dev    msg.value becomes the locked escrow amount.
    ///         Transitions: Created → Funded
    function fundOrder(uint256 orderId)
        external
        payable
        onlyBuyer(orderId)
        inState(orderId, OrderState.Created)
        nonReentrant
    {
        if (msg.value == 0) revert IncorrectPayment(msg.value, 1);

        // Effects
        Order storage order = orders[orderId];
        order.amount = msg.value;
        order.state  = OrderState.Funded;

        emit OrderFunded(orderId, msg.value);
    }

    /// @notice Buyer confirms delivery — releases funds to seller minus fee.
    ///         Transitions: Shipped → Completed
    function confirmReceived(uint256 orderId)
        external
        onlyBuyer(orderId)
        inState(orderId, OrderState.Shipped)
        nonReentrant
    {
        Order storage order = orders[orderId];

        // Effects first (CEI)
        order.state = OrderState.Completed;

        uint256 fee    = _calculateFee(order.amount);
        uint256 payout = order.amount - fee;

        emit OrderCompleted(orderId, payout, fee);

        // Interactions
        _sendEth(order.seller, payout);
        if (fee > 0) _sendEth(treasury, fee);
    }

    /// @notice Buyer cancels a Created (unfunded) order.
    ///         Transitions: Created → Cancelled
    function cancelUnfunded(uint256 orderId)
        external
        onlyBuyer(orderId)
        inState(orderId, OrderState.Created)
    {
        orders[orderId].state = OrderState.Cancelled;
        emit Cancelled(orderId);
    }

    /// @notice Buyer opens a dispute (Funded or Shipped).
    ///         Transitions: Funded|Shipped → Disputed
    function openDispute(uint256 orderId)
        external
        onlyBuyer(orderId)
        nonReentrant
    {
        Order storage order = orders[orderId];
        OrderState s = order.state;

        if (s != OrderState.Funded && s != OrderState.Shipped) {
            // Provide a meaningful error; use Funded as the "expected" hint
            revert InvalidState(orderId, s, OrderState.Funded);
        }

        // Effects
        order.state = OrderState.Disputed;
        emit DisputeOpened(orderId, msg.sender);

        // Notify external arbitrator (optional — swallow failure gracefully)
        if (arbitrator != address(0)) {
            try IArbitrator(arbitrator).notifyDispute(
                orderId,
                order.buyer,
                order.seller,
                order.amount
            ) {} catch {}
        }
    }

    // ══════════════════════ SELLER ACTIONS ═══════════════════════

    /// @notice Seller marks the order as shipped.
    ///         Transitions: Funded → Shipped
    function markShipped(uint256 orderId)
        external
        onlyOrderSeller(orderId)
        inState(orderId, OrderState.Funded)
    {
        orders[orderId].state = OrderState.Shipped;
        emit OrderShipped(orderId);
    }

    // ══════════════════════ MEDIATOR / ADMIN ACTIONS ═════════════

    /// @notice Resolve a disputed order.
    ///         `releaseToSeller = true`  → Completed  (seller gets paid minus fee)
    ///         `releaseToSeller = false` → Refunded   (buyer gets full amount back)
    ///         Transitions: Disputed → Completed | Refunded
    function resolveDispute(uint256 orderId, bool releaseToSeller)
        external
        onlyAdminOrMediator
        inState(orderId, OrderState.Disputed)
        nonReentrant
    {
        Order storage order = orders[orderId];

        if (releaseToSeller) {
            // Effects
            order.state = OrderState.Completed;

            uint256 fee    = _calculateFee(order.amount);
            uint256 payout = order.amount - fee;

            emit DisputeResolved(orderId, true);
            emit OrderCompleted(orderId, payout, fee);

            // Interactions
            _sendEth(order.seller, payout);
            if (fee > 0) _sendEth(treasury, fee);
        } else {
            // Effects
            uint256 refundAmt = order.amount;
            order.state = OrderState.Refunded;

            emit DisputeResolved(orderId, false);
            emit Refunded(orderId, refundAmt);

            // Interactions
            _sendEth(order.buyer, refundAmt);
        }
    }

    /// @notice Direct refund by mediator/admin (e.g. seller agrees pre-shipping).
    ///         Order must be in Disputed state.
    ///         Alias for resolveDispute(orderId, false) — kept for explicit interface.
    function refundBuyer(uint256 orderId)
        external
        onlyAdminOrMediator
        inState(orderId, OrderState.Disputed)
        nonReentrant
    {
        Order storage order = orders[orderId];
        uint256 refundAmt = order.amount;

        // Effects
        order.state = OrderState.Refunded;
        emit Refunded(orderId, refundAmt);

        // Interactions
        _sendEth(order.buyer, refundAmt);
    }

    // ══════════════════════ ADMIN CONFIG ═════════════════════════

    /// @notice Update the marketplace fee in basis points (max 500 = 5%)
    function updateFee(uint16 newBps) external onlyRole(ROLE_ADMIN) {
        if (newBps > MAX_FEE_BPS) revert FeeTooHigh(newBps, MAX_FEE_BPS);
        emit FeeUpdated(feeBps, newBps);
        feeBps = newBps;
    }

    /// @notice Update the treasury address
    function updateTreasury(address payable newTreasury) external onlyRole(ROLE_ADMIN) {
        if (newTreasury == address(0)) revert ZeroAddress();
        emit TreasuryUpdated(treasury, newTreasury);
        treasury = newTreasury;
    }

    /// @notice Update the arbitrator address (address(0) to disable)
    function updateArbitrator(address newArbitrator) external onlyRole(ROLE_ADMIN) {
        emit ArbitratorUpdated(arbitrator, newArbitrator);
        arbitrator = newArbitrator;
    }

    // ══════════════════════ VIEW HELPERS ═════════════════════════

    /// @notice Return full order data
    function getOrder(uint256 orderId) external view returns (Order memory) {
        return orders[orderId];
    }

    /// @notice Calculate the fee for a given amount using current feeBps
    function calculateFee(uint256 amount) external view returns (uint256) {
        return _calculateFee(amount);
    }

    // ══════════════════════ INTERNAL ═════════════════════════════

    function _calculateFee(uint256 amount) internal view returns (uint256) {
        return (amount * feeBps) / 10_000;
    }

    /// @dev Safe ETH transfer — reverts on failure
    function _sendEth(address to, uint256 amount) internal {
        (bool ok, ) = to.call{value: amount}("");
        if (!ok) revert TransferFailed();
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

/*Implements role-based access control with ADMIN, SELLER, MEDIATOR.

*/


/// @title AccessManager
/// @notice Role-based access control base contract (no OpenZeppelin)
/// @dev Roles: ADMIN (0), SELLER (1), MEDIATOR (2)
abstract contract AccessManager {
    // ─────────────────────────── Roles ───────────────────────────

    uint8 public constant ROLE_ADMIN    = 0;
    uint8 public constant ROLE_SELLER   = 1;
    uint8 public constant ROLE_MEDIATOR = 2;

    /// @dev address => role => granted
    mapping(address => mapping(uint8 => bool)) private _roles;

    // ─────────────────────────── Errors ──────────────────────────

    error Unauthorized(address caller, uint8 role);
    error ZeroAddress();
    error InvalidRole();

    // ─────────────────────────── Events ──────────────────────────

    event RoleGranted(address indexed account, uint8 role, address indexed by);
    event RoleRevoked(address indexed account, uint8 role, address indexed by);

    // ──────────────────────── Constructor ────────────────────────

    constructor() {
        // deployer receives ADMIN role
        _grantRole(msg.sender, ROLE_ADMIN);
    }

    // ─────────────────────────── Modifiers ───────────────────────

    modifier onlyRole(uint8 role) {
        if (!hasRole(msg.sender, role)) revert Unauthorized(msg.sender, role);
        _;
    }

    // ADMIN OR MEDIATOR — used for dispute resolution
    modifier onlyAdminOrMediator() {
        if (!hasRole(msg.sender, ROLE_ADMIN) && !hasRole(msg.sender, ROLE_MEDIATOR)) {
            revert Unauthorized(msg.sender, ROLE_MEDIATOR);
        }
        _;
    }

    // ──────────────────────── Role Logic ─────────────────────────

    /// @notice Check whether `account` holds `role`
    function hasRole(address account, uint8 role) public view returns (bool) {
        return _roles[account][role];
    }

    /// @notice Grant a role to an account (admin only)
    function grantRole(address account, uint8 role) external onlyRole(ROLE_ADMIN) {
        if (account == address(0)) revert ZeroAddress();
        if (role > ROLE_MEDIATOR) revert InvalidRole();
        _grantRole(account, role);
    }

    /// @notice Revoke a role from an account (admin only)
    function revokeRole(address account, uint8 role) external onlyRole(ROLE_ADMIN) {
        if (account == address(0)) revert ZeroAddress();
        if (role > ROLE_MEDIATOR) revert InvalidRole();
        _revokeRole(account, role);
    }

    // ─────────────────────── Internal Helpers ────────────────────

    function _grantRole(address account, uint8 role) internal {
        if (!_roles[account][role]) {
            _roles[account][role] = true;
            emit RoleGranted(account, role, msg.sender);
        }
    }

    function _revokeRole(address account, uint8 role) internal {
        if (_roles[account][role]) {
            _roles[account][role] = false;
            emit RoleRevoked(account, role, msg.sender);
        }
    }
}

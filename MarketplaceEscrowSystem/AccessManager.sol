// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

contract AccessManager {

    uint8 public constant ADMIN    = 1;
    uint8 public constant SELLER   = 2;
    uint8 public constant MEDIATOR = 3;

    mapping(address => mapping(uint8 => bool)) private _roles;

    error Unauthorized();
    error ZeroAddress();

    event RoleGranted(address indexed account, uint8 indexed role);
    event RoleRevoked(address indexed account, uint8 indexed role);

    constructor() {
        _grantRole(msg.sender, ADMIN);
    }

    modifier onlyRole(uint8 role) {
        if (!_roles[msg.sender][role]) revert Unauthorized();
        _;
    }

    function grantRole(address account, uint8 role) external onlyRole(ADMIN) {
        if (account == address(0)) revert ZeroAddress();
        _grantRole(account, role);
    }

    function revokeRole(address account, uint8 role) external onlyRole(ADMIN) {
        if (account == address(0)) revert ZeroAddress();
        _roles[account][role] = false;
        emit RoleRevoked(account, role);
    }

    function hasRole(address account, uint8 role) public view returns (bool) {
        return _roles[account][role];
    }

    function _grantRole(address account, uint8 role) internal {
        _roles[account][role] = true;
        emit RoleGranted(account, role);
    }

}
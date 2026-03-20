// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

/*
    Implements role-based access control with ADMIN, SELLER, MEDIATOR.
    AccessManager contract is a base contract inherited by EscrowMarketplace
*/

contract AccessManager {

    uint8 public constant ADMIN    = 1;
    uint8 public constant SELLER   = 2;
    uint8 public constant MEDIATOR = 3;

    error Unauthorized(); 
    error ZeroAddress();

    event RoleGranted(address indexed account, uint8 indexed role);
    event RoleRevoked(address indexed account, uint8 indexed role);

    // role_addr -> role_assigned -> bool 
    mapping (address => mapping (uint8 => bool)) private _roles;

    constructor () {
        // question: why did we write a seperate function and even then an internal function for grant role
        _grantRole(msg.sender, ADMIN);  
    }

    modifier onlyRole(uint8 _role) {
        if ( !_roles[msg.sender][_role]) {
            revert Unauthorized();
        }
        _;
    }

    // question why address doesn't have memory keyword
    function grantRole(address _account, uint8 _assignRole ) external onlyRole(ADMIN) {
        if( _account == address(0) || _assignRole == ADMIN ) {
            revert Unauthorized();
        }
        _grantRole(_account, _assignRole);
    }

    function revokeRole(address _account, uint8 _role) external onlyRole(ADMIN) {
        if(_account == address(0) ) {
            revert ZeroAddress();
        }
        _roles[_account][_role] = false;
        emit RoleRevoked(_account, _role);
    }

    // what is the role of internal helper function
    function _grantRole(address _account, uint8 _assignRole ) internal {
        _roles[_account][_assignRole] = true;
        emit RoleGranted(_account, _assignRole);
    }

    function hasRole(address account, uint8 role) public view returns (bool) {
        return _roles[account][role];
    }

}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

// modifier are code that can be run before and/or after a function call
// modifiers can be user to : restrict access, validate inputs, guard against reentrany hack
import "hardhat/console.sol";

contract FunctionModifier {
    address public owner;
    uint public x=10;
    bool public locked;

    constructor() {
        owner = msg.sender;
        console.log("default value of bool is", locked);
    }

    // modifier to check the caller is the owner of the contract
    modifier onlyOwner() {
        require(msg.sender == owner, "Not Owner");
        // underscore is a special character only used inside a function modifer 
        // and it tells Solidity to execute the rest of the code
        _;
    }

    // modifier can take inputs. This modifier chceks that the addr passed in is not the zero address
    modifier validAddress(address _addr) {
        require(_addr != address(0), "not a valid address");
        _;
    }

    function changeOwner(address _newOwner) public onlyOwner validAddress(_newOwner) {
        owner = _newOwner;
    }

    // Modifiers can be called before and/or after a function.
    // this is preventing a function from being called while it is still executing
    modifier noReentrancy() {
        require(!locked, "No reentrancy");
        locked = true;
        _;
        locked = false;
    }

    function decrement(uint _i) public noReentrancy{ 
        console.log("Entered the decemrent function ----------------------------");
        x -= _i;

        if( _i > 1 ) {
            console.log("Entered the if ========");
            decrement(_i-1);
            console.log(" No reentrancy ----------------------------");
            console.log("i=",_i);
        }
    }
}
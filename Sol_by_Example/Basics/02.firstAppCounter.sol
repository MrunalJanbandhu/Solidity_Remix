// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

// import "hardhat/console.sol";

contract Counter {
    // uint256 count;
    int256 count;

    function inc() public {
        count += 1;
    }

    function dec() public {
        require( count > 0, "count cannot be negative");
        // console.log("no revert");
        count -= 1;
    }

    function getCount() public view returns(int256) {
    // function getCount() public view returns(uint256) {
        
        return count;
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "hardhat/console.sol";


/*
Variables are decalres as either storage, memory or calldata to explicitly specify the location of data stored.

storage - variable is a state variable (stored on the blockchain)
memory - variable is in memory and it exists while a function is being called
calldata - speical data location that contains function arguments (most probably used in external functions)
*/

contract DataLocations {
    uint[] public arr;
    mapping(uint => address) public map;
    mapping(uint => uint) public myMap;

    struct MyStruct {
        uint foo;
        uint bar;
    }

    MyStruct[] public myStructs;

    function f(uint[] calldata _arr, uint _index) public {
        // Using calldata
        // _arr is a calldata array passed to the function
        // It cannot be modified directly, but can be read

        // Using storage
        // arr is a state variable (storage)
        // It can be modified directly
        arr.push(_arr[_index]);

        // Using memory
        // Creating a new array in memory
        uint[] memory memArr = new uint[](_arr.length);
        for (uint i = 0; i < _arr.length; i++) {
            memArr[i] = _arr[i] * 2;
        }

        // Using mapping (storage)
        // myMap is a state variable (storage)
        // It can be modified directly
        myMap[_index] = memArr[_index];

        // Using struct in storage
        // myStructs is a state variable (storage)
        // It can be modified directly
        MyStruct storage myStruct = myStructs[_index];
        myStruct.foo = _arr[_index];
        myStruct.bar = memArr[_index];

        // Using struct in memory
        // Creating a new struct in memory
        MyStruct memory myMemStruct = MyStruct(_arr[_index], memArr[_index]);
        // You can use myMemStruct here, but it won't persist after the function call
        myStructs.push(myMemStruct);

    }

    function _f(
        uint[] storage _arr,
        mapping (uint => address) storage _map,
        MyStruct storage _myStruct) internal {
        // _arr is a reference to a storage array
        // It can be modified directly
        _arr.push(1);

        // _map is a reference to a storage mapping
        // It can be modified directly
        _map[1] = msg.sender;

        // _myStruct is a reference to a storage struct
        // It can be modified directly
        _myStruct.foo = 77;
        _myStruct.bar = 100;
    }
}
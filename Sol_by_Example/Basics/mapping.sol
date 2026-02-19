// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;


// mapping(keyType => valueType) -- mappings are not iterable  
// keyTyype built-in valye type, byte, string or contract -- valueType can be any type another mapping or array

contract Mappings {

    mapping ( address => uint ) public myMapping;

    function get(address _address) public view returns(uint) {
        // if value not set returns default value
        return myMapping[_address];

    }

    function set( address _addr, uint _val) public {
        // update value at this address
        myMapping[_addr] = _val;
    }

    function remove( address _address) public {
        // reset the value to the default value
        delete myMapping[_address];
    }
}

contract NestMapping {

    mapping(address => mapping(uint => bool)) public nestedMapping;
    // mapping(address =>( mapping(uint => bool))) public nestedMapping;    // this is different from above - check it out

    function get ( address _address, uint _val ) public view returns (bool) {
        return nestedMapping[_address][_val];
    }

    function set ( address _address, uint _val, bool _check ) public {
        nestedMapping[_address][_val] = _check;
    }

    function removeMapping (address _address, uint _val) public {
        delete nestedMapping[_address][_val];
    }

}
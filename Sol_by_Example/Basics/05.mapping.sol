// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;


/* Deleting a struct which contains a mapping is dangerous
In Solidity, deleting a struct that contains a mapping—or deleting a nested mapping itself—does not actually 
erase the underlying data stored in the nested mapping, resulting in "ghost data".


struct Inner {
    mapping(uint256 => uint256) map;
}
mapping(address => Inner) public nested;

function deleteData(address _addr) public {
    // This deletes `nested[_addr]` but NOT the `map` inside `Inner`
    delete nested[_addr]; 
}

*/

// mapping(keyType => valueType) -- mappings are not iterable  
// keyTyype built-in valye type, byte, string or contract -- valueType can be any type another mapping or array

contract Mappings {

    mapping ( address => uint ) public myMapping;
    // 0x617F2E2fD72FD9D5503197092aC168c91465E7f2 [2] = true
    // 0x617F2E2fD72FD9D5503197092aC168c91sd6E7f2 - 3

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

// name = uint

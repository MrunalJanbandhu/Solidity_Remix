// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

/*
msg.data is a special global variable in solidity that contains 
the complete calldata of the current function call.

It contains data about two things: function selector (the function which is called) 
+ function arguments
*/

/*fallback is a special function that is executed either when
    - a function that does not exist is called or
    - Ether is sent directly to a contract but receive() does not exist or msg.data is not empty
*/

contract Fallback { 
    event Log(string func, uint gas);

    // Fallabck function must be decalred as external
    fallback() external payable { 
        emit Log("fallback", gasleft());
    }

    // receive is a variant of fallback that is triggered when msg.data is empty
    receive() external payable { 
        emit Log("receive", gasleft());
    }

    // helper fn() to check bal of this contract
    function getBalance() public view returns (uint) { 
        return address(this).balance;
    }
}

contract SendToFallback {
    function tranferToFallback(address payable _to) public payable {
        _to.transfer(msg.value);    // msg.value represents the amount of Ether sent with the transaction.
    }

    function callFallback(address payable _to) public payable {
        (bool sent, ) = _to.call{value: msg.value}("");
        require(sent,"Failed to send Ether");
    }
}

/* ---------=========--------- */
// fallback can optionally take bytes for input and output
//      TestFallbackInputOutput -> FallbackInputOutput -> Counter

contract FallbackInputOutput {
    address immutable target;

    constructor(address _target){
        target = _target;
    }

    fallback(bytes calldata data) external payable returns (bytes memory) { 
        (bool ok, bytes memory res) = target.call{value: msg.value}(data);
        require(ok,"call failed");
        return res;
    }
}

contract Counter {
    uint public count;

    function get() external view returns (uint) {
        return count;
    }

    function inc() external returns (uint) {
        count += 1;
        return count;
    }
}

contract TestFallbackInputOutput {
    event Log(bytes res);

    function test(address _fallback, bytes calldata data) external {
        (bool ok, bytes memory res) = _fallback.call(data);
        require(ok,"call failed");
        emit Log(res);
    }

    function getTestData() external pure returns (bytes memory, bytes memory) {
        return (abi.encodeCall(Counter.get, ()), abi.encodeCall(Counter.inc, ()));
    }
}
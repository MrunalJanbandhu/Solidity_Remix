// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

/*
Solidity supports multiple inheritance. Contracts can inherit other contract by using the is keyword.
Functions overridden by a child contract must be declared as virtual.
Function overdie a parent function must use the keywork override.
Order is imp in inheritance
You have to list the parent contracts in the order from "most-base-like" to "most-derived".
*/

/* Graph of inheritance
    A
   /  \
  B    C
 / \  / 
F   D,E   

*/  

contract A {
    function foo() public pure virtual returns (string memory) {
        return "A";
    }
}

// contract inherit other contracts by using the keyword 'is'.
contract B is A {
    function foo() public pure virtual override returns (string memory) {
        return 'B';
    }
}

contract C is A {
    function foo() public pure virtual override returns (string memory) {
        return "C";
    }
}

// when a fun() called that is defined multiple times in diff. contracts, parent contracts
// are searched from right to left, and in a depth-first manner.
contract D is B, C {
    // D.foo() returns "C"
    // since C is right most parent contract with funciton foo()
    function foo() public pure override(B, C) returns (string memory) {
        return super.foo();
    }
}

contract E is C, B {
    // E.foo() returns "B"
    // since B is the right most parent contract with function foo()
    function foo() public pure override(C,B) returns (string memory) {
        return super.foo();
    }
    
}

// Inheritance must be ordered from "most base-like" to "most-derived"
// Swapping the order of A and B will throw a compilation error.
contract F is A, B {
    function foo() public pure override(A, B) returns (string memory) {
        // return super.foo();      // solidity C3 linearization 
        return A.foo();             // direct call, ignores linearization
    }
}

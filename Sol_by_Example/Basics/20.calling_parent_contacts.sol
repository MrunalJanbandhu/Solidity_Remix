// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

// Parent contracts can be called directly, or by using the keyword super.
// Using super, all of the immediate parent contracts will be called.

/* Inheritance tree
         A
        / \
       B   C
        \ /
        D,E
*/

contract A {
    // This is an event. You can emit events from you functions and they are logged into
    // txn log. In our case, this will be useful for tracing function calls.

    event Log(string message);
    
    function foo() public virtual {
        emit Log("A.foo() is called");
    }

    function bar() public virtual {
        emit Log("A.bar() is called");
    }
}

contract B is A {
     function foo() public virtual override  {
        emit Log("B.foo() is called");
        A.foo();
    }

    function bar() public virtual override  {
        emit Log("B.bar() is called");
        super.bar();
    }
}

contract C is A {
     function foo() public virtual override  {
        emit Log("C.foo() is called");
        A.foo();
    }

    function bar() public virtual override  {
        emit Log("C.bar() is called");
        super.bar();
    }
}

contract D is B, C {
    /*  - call D.foo and check txn logs.
        Altough D inherits A, B and C, it only called C and then A.
        - call D.bar and check txn logs.
        D called C, then B, and finally A.
        Altough super was called twice (by B and C) it only called A once.
    */
    function foo() public override (B, C) {
        super.foo();
    }

    function bar() public override (B, C) {
    // function bar() public override (C, B) {
        super.bar();
    }
}

// contract E is C,B,A {        // declaration of A later is not allowed - linearization?
// contract E is A, C,B {
contract E is C,B {         // the rightmost order matters here not in the overide(C,B) in function
    function foo() public override ( C,B) {
    // function foo() public override ( C,B, A) {
        super.foo();
    }

    function bar() public  override (B,C) {
    // function bar() public  override (A,C,B) {
        super.bar();
    }
}

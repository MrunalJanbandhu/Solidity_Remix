// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

contract TestError {
    // require should be used to validate conditions such as:
    // inputs, balance before transfers, return values from calls, state variables, condition before exeuction, etc.
   
    function testRequire(uint _number) pure public {
        require(_number > 10, "number should be greater than 10");
    }

    function testRevert(uint _number) pure public{
        
        // revert is userful when the condition to check is complex
        if(_number > 10){
            revert("number should be greater than 10");
        }
    }

    uint public num;

    // function testAssert() public view {
    function testAssert() public view {
        // assert should be only be used to test for internal erroes and to check invariants
        // here we assert that num is always equal to 0, since it is impossible to update the value of num
        // num++;
        assert(num == 0);
    }

    error InsufficientBalance(uint balance, uint withdrawAmount);

    function testCustomError(uint _withdrawAmount) public view {
        uint bal = address(this).balance;
        if ( bal < _withdrawAmount ) {
            revert InsufficientBalance ({
                balance: bal,
                withdrawAmount: _withdrawAmount
            });
        }
    }
}

contract Accounts {
    uint public balance;
    uint public constant MAX_UINT = 2 ** 256 -1;

    function deposit(uint _amount) public {
        uint oldBalance = balance;
        uint newBalance = balance + _amount;

        require(newBalance >= oldBalance, "Overflow");

        balance = newBalance;

        assert(balance >= oldBalance);
    }

    function withdraw(uint _amount) public {
        uint oldBalance = balance;

        require(balance >= _amount, "Underflow");

        if( balance < _amount ) {
            revert("Underflow");
        }

        balance -= _amount;

        assert(balance <= oldBalance);
    }
}
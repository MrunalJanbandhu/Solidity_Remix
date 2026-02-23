// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

// Transient storage (EIP-1153)

interface ITest {
    function val() external view returns (uint);
    function test() external;
}


// contract for testing TestStorage and TestTransientStorage - difference betw normal and transient storage
contract Callback {
    uint public val;

    fallback() external  {
        val = ITest(msg.sender).val();    
    }

    function test(address target) external {
        ITest(target).test();
    }
}       

contract TestStorage {
    uint public val;

    function test() public {
        val = 123;
        bytes memory b = "";
        msg.sender.call(b);
    }
}

contract TestTransientStorage {
    bytes32 constant SLOT = 0;

    function  test() public  {

    // Warning: Transient storage as defined by EIP-1153 can break the composability of smart contracts: 
    // Since transient storage is cleared only at the end of the transaction and not at the end of the outermost call frame to the
    // contract within a transaction, your contract may unintentionally misbehave when invoked multiple times in a complex transaction. 
    // To avoid this, be sure to clear all transient storage at the end of any call to your contract
    // The use of transient storage for reentrancy guards that are cleared at the end of the call is safe.
        assembly {
            tstore(SLOT, 321)
        }
        bytes memory b = "";
        msg.sender.call(b);
    }

    function val() public view returns (uint v) {
        assembly {
            v := tload(SLOT)
        }
    }
}

// contract for testing reentrancy protection
contract MaliciousCallback {
    uint public  count = 0;

    // trying to reenter the target contract multiple itmes
    fallback() external {
        ITest(msg.sender).test();
    }

    // test function to initiate reentrane attack
    function attack (address _target) external {
        // first call to test()
        ITest(_target).test();
    }

}

contract ReentrancyGuard {
    bool private locked;

    modifier lock() {
        require(!locked);
        locked = true;
        _;
        locked = false;
    }

    // 27587 gas ?
    function test() public lock {
        // ignore call error
        bytes memory b = "";
        msg.sender.call(b);
    }

}

contract ReentrancyGuardTransient {
    bytes32 constant SLOT = 0;

    modifier lock() {
        assembly {
            if tload(SLOT) { revert(0,0)}
            tstore(SLOT,1)
        }
        _;
        assembly {
            tstore(SLOT,0)
        }
    }

    // 4909 gas ? 
    function test() external lock {
        // ignore call error
        bytes memory b = "";
        msg.sender.call(b);
    }
}
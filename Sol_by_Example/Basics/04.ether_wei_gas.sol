// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

contract Sample {
    uint public num;

    // read and write 
    function set(uint _num ) public {
        num = _num;     // txn need to be sent to write a state var
    }

    function get() public view returns (uint) {
        return num;
    }


    // ether and wei
    // transaction are paid with ether, 1 eth = 10^18 wei
    
    //  1 wei = 1
    uint public oneWei = 1 wei;

    //  1 gwei = 10^9 wei
    uint public oneGwei = 1 gwei;
    
    //  1 eth = 10^18 wei
    uint public oneEther = 1 ether;

    bool public isOneEther = (oneEther == 1e18);


    /*
    // gas limit - max amt of gas you're willling to use for your txn, set by you
    // block gas limit - max amt of gas allowed in a block, set by the network
    uint public i = 0;

    function forever () public {
        while (true) {
            i +=1;      // all of gas are spent and txn fails
        }
    }
    */

    function foo(uint x) public pure returns (uint) {
        if (x<10){
            return 0;
        }
        else if (x<20){
            return 1;
        }
        else {
            return 2;
        }
    }

    function ternary(uint _x) public pure returns (uint) {
        return _x < 10 ? 1 : 2;
    }



    /* for and while loops */ // wihle and do while loops are rarely used cause unbounded loops can hit gas limit fialing txn

    function loop() public pure {
        for( uint i=0; i<10 ; i++) {
            if (i%2 == 0) {
                continue ;
            }
            if ( i==7) {
                break;
            }
        }
        uint j;
        while ( j<10 ){
            j++;
        }
    }


}
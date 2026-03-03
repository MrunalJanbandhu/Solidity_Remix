// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

contract AssemblyVariable {
    function yul_let() public pure returns (uint z) {
        assembly {
            // the lang used for assembly is called yul
            // local variables
            let x:= 100
            z := 50
        }
    }
}
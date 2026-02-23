// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "hardhat/console.sol";

/* Fn() and state vars have to declare whether they are accessible by other contracts..
Functions can be declared as 
    - public: any contract and accoun can call
    - private: only inside the contract that defines this function
    - internal: only inside a contract that inherits an internal function
    - external: only outside the contract and accounts can call
State vars can be declared as public, private, or internal but not external 
*/

contract Base {
    // private fn() can be only called inside this contract 
    // contracts that inheirt this contract cannot call this function.

    function privateFunc() private pure returns (string memory) {
        return "private function called";
    }

    function testPrivateFunc() public pure returns ( string memory) {
        return privateFunc();
    }

    // Internal function can be called 
    //  - inside this contract, inside contracts that inherit this contract
    function internalFunc() internal pure returns (string memory){
        return "internal function called";
    }  
    
    function testInternalFunc() public pure virtual returns ( string memory) {
        return internalFunc();
    }

    function publicFunc() public pure returns ( string memory) {
        return "public function called";
    }

    function testPublicFunc() public pure returns ( string memory) {
        return publicFunc();
    }

    function externalFunc() external pure returns ( string memory) {
        return "public function called";
    }

    // This function will not compile since we're trying to call an external function here.
    // function testExternalFunc() public pure returns ( string memory) {
    //     return publicFunc();
    // }

    //State Variables
    string private privateVar = "my private variable";
    string internal internalVar = "my internal variable";
    string public publicVar = "my public variable";
    // state vars cannot be external so this code won't compile
    // string external externalVar = "my external variable";

}

contract Child is Base {
    // Inherited contracts do not have access to private functions and state vars
    // function testPrivateFunc() public pure override returns (string memory) {
    //     return privateFunc();
    // }

    string public newVar = internalFunc();
    string public newPublicVar = publicFunc();

    // newPublicVar = publicVar;        // state change operation outside the function are not allowed

    // string public newInternalVar = externalFunc();
    // string public newPrivateVar = privateFunc();
    function consoleLog() public  {
        console.log("internalFunc returnred value = ",newVar);
        console.log("publicFunc returned value = ",newPublicVar);
        newPublicVar = publicVar;    // accessing state variable from child class
        console.log("After assignment newPublicVar = ",newPublicVar);

        console.log("State var - internal = ", internalVar);
        console.log("State var - public = ", publicVar);

    }

    // Internal function can be called inside child contracts
    function testInternalFunc() public pure override returns (string memory) {
        return internalFunc();
    }
}

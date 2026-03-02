// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "./Foo.sol";

import {Unauthorized, add as func, Point} from "./Foo.sol";

contract Import {
    Foo public foo = new Foo();

    // test foo.sol by getting its name
    function gotFooName() public view returns (string memory) {
        return foo.name();
    }
}

/* External
You can also import from GitHub by simply copying the url

// https://github.com/owner/repo/blob/branch/path/to/Contract.sol
import "https://github.com/owner/repo/blob/branch/path/to/Contract.sol";

// Example import ECDSA.sol from openzeppelin-contract repo, release-v4.5 branch
// https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v4.5/contracts/utils/cryptography/ECDSA.sol
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v4.5/contracts/utils/cryptography/ECDSA.sol";
*/

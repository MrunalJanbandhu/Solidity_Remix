// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "hardhat/console.sol";

contract Arrays {
    uint[] public arr2;
    uint[] public arr = [1,2,3];

    //fixed sized array, all ele. to 0
    uint[10] public fixedArray;

    function get(uint i) public view returns (uint) {
        return arr[i];
    }

    // Solidity can return entire array, but this function should be avoided for arrays that can grow indefinitely in length 
    function getArray() public view returns (uint[] memory) {
        return arr;
    }

    function push(uint i) public {
        arr.push(i);            // append and len+1
    }

    function pop() public {
        arr.pop();              // last element is removed 
    }

    function getLength() public view returns(uint) {
        return arr.length;
    }

    function remove(uint index) public {
        delete arr[index];      // reset the default value at index
    }

    function exmaples() external pure {
        // create array in memeory, only fixed size can be created
        uint[] memory myArray = new uint[](5);  

        for(uint i=0;i<myArray.length;i++){
            console.log("myArray[%d]",i,  myArray[i]);    
        }
        

        // create a nested array in memory 
        // b = [[1,2,3], [4,5,6]]
        uint[][] memory nestedArray = new uint[][](2);
        for( uint i=0; i<nestedArray.length; i++){
            nestedArray[i] = new uint[](3);
        }

        nestedArray[0][0] = 1;
        nestedArray[0][1] = 2;
        nestedArray[0][2] = 3;
        nestedArray[1][0] = 4;
        nestedArray[1][1] = 5;
        nestedArray[1][2] = 6;

        for(uint i=0; i<nestedArray.length; i++){
            for(uint j=0; j<nestedArray[i].length; j++){
                console.log("nestedArray[%d][%d] = %d", i, j, nestedArray[i][j]);
            }
        }
    }
}

contract ArrayRemovalByShifting {
    uint[] public arr = [1,2,34,5,6,7,8];

    // function removeByShifting(uint[] memory arr, uint _index) public {
    function removeByShifting(uint _index) public {
        require(_index < arr.length, "Index out of bounds");

        for( uint i=_index; i< arr.length-1; i++){
            arr[i] = arr[i+1];
        }

        arr.pop(); // pop() is not available in uint256[] memory outside of storage
        // arr[arr.length-1] = 0; // set last element to 0
        // arr.length--;  // TypeError: Member "length" is read-only and cannot be used to resize arrays.
    }

    // function getArray(uint[] memory arr) public view returns (uint[] memory) {
    function getArray() public view returns (uint[] memory) {
        return arr;
    }

    function test() external pure {
        uint[] memory testArray = new uint[](5);
        
        testArray[0] = 11;
        testArray[1] = 22;
        testArray[2] = 33;
        testArray[3] = 44;
        testArray[4] = 55;

        // fixed size array
        // uint256[5] memory testArray = [11,22,33,44,55];  // definition of array is not possible 

        // converting it to the dynamically-sized array if needed
        uint256[] memory dynamicArray = testArray; // TypeError: Type uint256[5] memory is not implicitly convertible to expected type uint256[] memory fpr above statement
                                                    // but can when fixed size array allocation is correct conversion is possible

        console.log(dynamicArray[0]);
        // removeByShifting(dynamicArray, 2);
    }

}
// This code eliminates all the non-alphanumeric characters and then checks for Palindrome (if not needed then the `cleanString` and `toLowerCase` functions can be commented out)
// eg. 1. an input of "aa" will return true 
//     2. an input of "" will return true 
//     3. an input of "b" will return true 
//     3. an input of "hello" will return false 
//     4. an input of "madam, in Eden, I'm Adam" will be return true  (since all non-alphanumeric characters are eliminated)
//     5. an input of "A Toyota's a Toyota." will return true
//     6. an input of "A man a plan a canal Panama" will be return true

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
contract Palindrome {
    function toLowerCase(string memory str) internal pure returns (string memory) {
        bytes memory strBytes = bytes(str);
        bytes memory newStrBytes = new bytes(strBytes.length);
        for (uint256 i = 0; i < strBytes.length; i++) {
            if (strBytes[i] >= "A" && strBytes[i] <= "Z") {
            // Convert uppercase letter to lowercase
            newStrBytes[i] = bytes1(uint8(strBytes[i]) + 32);
            } else {
            // Copy other characters as is
            newStrBytes[i] = strBytes[i];
            }
        }
        return string(newStrBytes);
    }
    function cleanString(string memory str) internal pure returns (string memory){  //removes non-alphanumeric characters
        bytes memory strBytes = bytes(str);
        bytes memory newStrBytes = new bytes(strBytes.length);
        uint j = 0;

        for (uint256 i = 0; i < strBytes.length; i++) {
            if (
                (strBytes[i] >= "0" && strBytes[i] <= "9") || // 0-9
                (strBytes[i] >= "A" && strBytes[i] <= "Z") || // A-Z
                (strBytes[i] >= "a" && strBytes[i] <= "z")   // a-z
            ) {
                newStrBytes[j] = strBytes[i];
                j++;
            }
        }
        bytes memory cleanedStrBytes = new bytes(j);
        for (uint i = 0; i < j; i++) {
            cleanedStrBytes[i] = newStrBytes[i];
        }

        return toLowerCase(string(cleanedStrBytes));
    }
    function isPalindrome(string memory str) pure public returns (bool){
        
        bytes memory strBytes = bytes(cleanString(str));
        uint len = strBytes.length;
        
        for (uint i = 0; i < len / 2; i++) {
            if (strBytes[i] != strBytes[len - 1 - i]) {
                return false;
            }
        }
        return true;
    }
}
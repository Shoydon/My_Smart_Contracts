// function primeDifference(uint n) pure returns (uint): This function takes a uint as a parameter and returns the absolute difference between n and the closest prime number to n.

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract leastPrimeDifference {

    function isPrime(uint num) internal pure returns (bool) {
        if (num < 2) {
            return false;
        }
        for (uint i = 2; i <= num / 2; i++) {
            if (num % i == 0) {
                return false;
            }
        }
        return true;
    }

    function primeDifference(uint n) public pure returns (uint) {
        require(n >= 0);
        if(isPrime(n)){
            return 0;
        }
        if (n == 0) {
            return 2;
        }
        
        uint lower = n - 1;
        uint upper = n + 1;

        while (true){
            if(lower == 0 || isPrime(upper)){
                return (upper - n);
            }
            if(isPrime(lower)){
                return (n - lower);
            }
            else{
                lower -- ;
                upper ++;   
            }
        }
        return 0;
    }
}



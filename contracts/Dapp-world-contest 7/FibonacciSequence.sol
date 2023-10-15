// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
contract Fibonacci {
    //To find the value of n+1 th Fibonacci number
    function fibonacci(uint n) public pure returns (uint) {
        if (n <= 1) {
            return n;
        }
        uint f1 = 1;
        uint f2 = 0;
        uint fn = 0;
        for (uint i = 2; i <= n; i++) {
            fn = f1 + f2;
            f2 = f1;
            f1 = fn;
        }
        return fn;
    }
}

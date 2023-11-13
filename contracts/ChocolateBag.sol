// buyChocolates(uint n): This function will allow the owner to purchase n number of chocolates and add them to the chocolate bag.

// sellChocolates(uint n): This function will allow the owner to sell n number of chocolates from the chocolate bag.

// chocolatesInBag() returns (int n): This function will return the total number of chocolates in the chocolate bag.

// showTransaction(uint n) returns (int txn): This function will return the nth transaction. If the nth transaction is one where chocolates were bought, then the output(txn) will be the number of chocolates bought.  If the nth transaction is one where chocolates were sold, then the output(txn) will be negative of the number of chocolates sold 

// numberOfTransactions() returns (uint n): This function will return the total number of transactions done by the owner in his shop. i.e. a total number of times chocolates were bought and sold in his shop. 

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

contract ChcolateShop {

    uint ChocolateBag;
    int[] transactions;

    // this function allows the owner to buy n chocolates
    function buyChocolates(uint n) public {
        require(n > 0);
        ChocolateBag += n;
        transactions.push(int(n));
    }

    // this function allows the owner to sell n chocolates
    function sellChocolates(uint n) public {
        require(ChocolateBag >= n);
        ChocolateBag -= n;
        transactions.push(-1*int(n));
    }

    // this function returns total chocolates present in bag
    function chocolatesInBag() public view returns(uint){
        return ChocolateBag;
    }

    // this function returns the nth transaction
    function showTransaction(uint n) public view returns(int) {
        return transactions[n-1];
    }

    //this function returns the total number of transactions
    function numberOfTransactions() public view returns(uint) {
        return transactions.length;
    }
}
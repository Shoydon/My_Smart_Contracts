// constructor(uint totalSupply, uint tokenPrice, uint saleDuration) : The constructor function initializes the contract by setting the total supply of tokens, the token price in wei, and the duration of the token sale.
// purchaseToken() : This function allows an address to purchase tokens during the token sale. The address can only purchase tokens once. The function checks if the token sale is active, the amount sent is sufficient to purchase at least one token, and there are enough tokens available for purchase.
// sellTokenBack(uint amount) : This function allows a buyer to sell back a specified amount of tokens they have purchased. The user can only be able to sell a maximum of 20% of their bought tokens in a week. The corresponding amount in wei should be transferred back to the buyer's address. 
// checkTokenPrice() returns (uint): This function returns the current price of the tokens in wei.
// checkTokenBalance(address buyer) returns (uint):This function returns the token balance of a specific buyer address.
// saleTimeLeft(address buyer) returns (uint):This function returns the remaining time for the token sale in seconds. If the sale has ended then the transaction should fail.

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract TokenSale {

    struct Transaction{
        uint initialTokens;
        uint balance;
        uint lastSale;
        bool hasPurchased;
    }

    uint256 totalSupply;
    uint256 tokenPrice;
    uint256 saleDuration;
    mapping (address => Transaction) transactions;
    mapping (address => uint) salesInAWeek;

    constructor(
        uint256 _totalSupply,
        uint256 _tokenPrice,
        uint256 _saleDuration
    ) {
        totalSupply = _totalSupply;
        tokenPrice = _tokenPrice;
        saleDuration = block.timestamp + _saleDuration;
    }

    modifier saleActive{
        require(block.timestamp <= saleDuration);
        _;
    }

    function checkTokenPrice() public view returns (uint256) {
        return tokenPrice;
    }

    function purchaseToken() saleActive public payable {
        require(!transactions[msg.sender].hasPurchased);
        uint paymentAmount = msg.value;
        uint tokensToBuy = paymentAmount / tokenPrice;
        require(tokensToBuy > 0);
        require(totalSupply >= tokensToBuy);
        transactions[msg.sender].balance = tokensToBuy;
        transactions[msg.sender].initialTokens = tokensToBuy;
        transactions[msg.sender].hasPurchased = true;
        uint remainingAmount = paymentAmount % tokenPrice;
        payable(msg.sender).transfer(remainingAmount);
        totalSupply -= tokensToBuy;
    }

    function checkTokenBalance(address buyer) public view returns (uint256) {
        return transactions[buyer].balance;
    }

    function saleTimeLeft() saleActive public view returns (uint256) {
        return saleDuration - block.timestamp; 
    }

    function sellTokenBack(uint256 amount) public payable {
        require(transactions[msg.sender].hasPurchased);
        require(amount > 0);
        require(salesInAWeek[msg.sender] + amount <= transactions[msg.sender].initialTokens * 20/100);
        if (block.timestamp >= transactions[msg.sender].lastSale + 1 weeks) {
            salesInAWeek[msg.sender] = 0; // Reset the counter if a week has passed
        }
        
        uint saleAmount = tokenPrice * amount;
        transactions[msg.sender].balance -= amount;
        totalSupply += amount;
        transactions[msg.sender].lastSale = block.timestamp;
        salesInAWeek[msg.sender] += amount;
        
        payable(msg.sender).transfer(saleAmount);
    }
}   

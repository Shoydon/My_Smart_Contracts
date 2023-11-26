// similar to the easier version but with extra functtionalities:
// Extra functionalities:
// 1. Referral System:
// When a token is purchased through a referral, the referrer should receive a certain percentage of tokens as a reward.
// The referral rewards are as follows:
// ◦ 5% tokens for the first referral
// ◦ 4% tokens for the second referral
// ◦ 3% tokens for the third referral
// ◦ 2% tokens for the fourth referral
// ◦ 1% tokens for the fifth referral
// ◦ 0% tokens for further referrals
// Referrals are tracked for each referrer, and the referrer's address is provided as a parameter when purchasing tokens.
// You are not allowed to use your current address as the referrer address, If A wants to buy tokens he cannot put his own address as referrer address.
// If A buys 100 tokens with referrer address of B and this is the 1st referral then , A gets 100 tokens , 5 token that will be awarded to ‘B’ will be deducted from the total supply.
// 2. Dynamic Token Price Adjustment:
// The token price should be adjusted dynamically based on the number of tokens bought and sold, relative to the total supply.
// When tokens are purchased, the token price should increase by half of the percentage of tokens bought relative to the total supply. For example, if someone buys 20% of the initial total supply, the price should increase by 10%.
// When tokens are sold, the token price should decrease by the same percentage of tokens sold relative to the total supply. For example, if someone sells 10% of the initial total supply, the price should decrease by 10%.

// purchaseToken(address referrer) : Allows users to purchase tokens by sending the required amount of ether.The referrer field cannot be empty. The referrer should receive the appropriate percentage of tokens as a reward. The token price should be adjusted based on the number of tokens bought and the remaining total supply.The tokens referrer got shall not be considered for calculating the new token price.
// getReferralCount(address referrer) returns (uint):Returns the number of referrals made by a given referrer.
// getReferralRewards(address referrer) returns (uint):Returns the total number of tokens rewarded to a given referrer.

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
contract TokenSale {
    struct Transaction{
        uint initialTokens;
        uint balance;
        uint lastSale;
        bool hasPurchased;
        uint referralCount;
        uint rewards;
    }
    uint256 initialTotalSupply;
    uint256 totalSupply;
    uint256 tokenPrice;
    uint256 saleDuration;
    mapping (address => Transaction) transactions;
    mapping (address => uint) salesInAWeek;
    constructor(uint256 _totalSupply, uint256 _tokenPrice, uint256 _saleDuration) {
        initialTotalSupply = _totalSupply;
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
    function purchaseToken(address referrer) saleActive public payable {
        require(msg.sender != referrer);
        require(referrer != address(0));
        require(!transactions[msg.sender].hasPurchased);
        uint paymentAmount = msg.value;
        uint tokensToBuy = paymentAmount / tokenPrice;
        require(tokensToBuy > 0);
        require(totalSupply >= tokensToBuy);
        transactions[msg.sender].balance += tokensToBuy;
        transactions[msg.sender].initialTokens += tokensToBuy;
        transactions[msg.sender].hasPurchased = true;
        if(transactions[referrer].referralCount < 5){
            uint refPercent = 5 - transactions[referrer].referralCount;
            uint reward = (refPercent * tokensToBuy);
            reward = reward / 100 ;
            // here we calculate reward in 2 steps

            if(totalSupply < reward){
                transactions[referrer].balance += totalSupply;
                transactions[referrer].rewards += totalSupply;
                totalSupply = 0;
            } else {
                transactions[referrer].balance += reward;
                transactions[referrer].rewards += reward;
                totalSupply -= reward;
            }
        }
        transactions[referrer].referralCount ++;
        uint tokenFraction = tokensToBuy * 100;
        tokenFraction = tokenFraction / initialTotalSupply;
        // here we calculate tokenFraction in 2 steps because if we do it as (tokensToBuy * 100) / initialTotalSupply then tokenFraction will become zero
        // tokenFraction = (tokensToBuy * 100) / initialTotalSupply

        uint increment = tokenPrice * tokenFraction;
        increment = increment / 200;
        tokenPrice += increment;
        // here we do it in 3 steps
        // tokenPrice = tokenPrice(1 + tokenFraction / 200)

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
            salesInAWeek[msg.sender] = 0;
        }
        uint saleAmount = tokenPrice * amount;
        transactions[msg.sender].balance -= amount;
        totalSupply += amount;
        transactions[msg.sender].lastSale = block.timestamp;
        salesInAWeek[msg.sender] += amount;
        uint tokenFraction = amount * 100;
        tokenFraction = tokenFraction / initialTotalSupply;
        uint decrement = tokenPrice * tokenFraction;
        decrement = decrement / 100;
        tokenPrice -= decrement;
        // similar to calculation of tokenFraction and tokenPrice in purchaseToken function

        payable(msg.sender).transfer(saleAmount);
    }

    function getReferralCount(address referrer) public view returns (uint256) {
        return transactions[referrer].referralCount;
    }

    function getReferralRewards(address referrer) public view returns (uint256){
        return transactions[referrer].rewards;
    }
}   

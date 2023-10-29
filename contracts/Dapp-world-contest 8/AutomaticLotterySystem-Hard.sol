// Similar to the `Automatic Lottery System - Easy` code with extra functionalities:
// 1. Gavin is the deployer of the contract and anyone, except Gavin, can enter the lottery pool by paying an amount which consists of entry fees as well. The amount for the participants to enter the pool is determined as follows:
// The total payable amount for a participant is calculated as : “0.1 + (number of games won)*(0.01)” ethers, of which, 10% is the entry fees. This entry fees must go to Gavin’s account as soon as the player enters the pool, and the remaining paid amount must go to the contract address.
// 2. Before 5 players enter the pool, a player can withdraw from the lottery. After this, the player will recieve the amount except the entry fees from the pool.(the 90% of the total amount paid by the player)
// 3. withdraw(): Using this function, a player can withdraw from the lottery pool. If the player is not part of the current active pool, then the player can not withdraw due to which the transaction should revert.
// 4. viewEarnings() view returns (uint): This function must return the ethers in wei units which have been earned by Gavin as profit from the contract. Also, this function must only be accessible to Gavin.

// 5. viewPoolBalance() view returns (uint): This function must return the ethers in wei units which is the amount of ethers present in the pool or the deployed lottery contract.

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract LotteryPool {

    struct EnteredParticipant{
        bool hasEntered;
        uint index;
        uint amount;
    }

    modifier onlyOwner{
        require(msg.sender == owner);
        _;
    }

    bool lotteryHappened;
    uint numberOfParticipants;
    uint256 ownerProfit;
    address owner;
    address prevWinner;
    address[] participants;
    mapping(address => uint) gamesPlayed;
    mapping(address => EnteredParticipant) enteredParticipants;

    constructor() {
        owner = msg.sender;
    }
    
    // For participants to enter the pool
    function enter() public payable {
        require(msg.sender != owner);
        require(!enteredParticipants[msg.sender].hasEntered);
        uint games = gamesPlayed[msg.sender];
        uint amount = 0.1 ether + games * 0.01 ether;
        require(msg.value == amount);
        uint entryFee = amount * 10 / 100;
        uint ninetyPercent = amount - entryFee;
        payable(owner).transfer(entryFee);
        ownerProfit += entryFee;
        participants.push(msg.sender);
        enteredParticipants[msg.sender].hasEntered = true;
        enteredParticipants[msg.sender].index = numberOfParticipants;
        enteredParticipants[msg.sender].amount = ninetyPercent;
        gamesPlayed[msg.sender]++;
        numberOfParticipants++;
        if(numberOfParticipants == 5){
            uint256 random = uint256(keccak256(abi.encodePacked(
                    block.timestamp, 
                    msg.sender, 
                    block.coinbase,
                    block.gaslimit,
                    block.number 
                    ))
                );
            random = random % 5;
            prevWinner = participants[random];
            for(uint i = 0; i < 5; i++){
                delete enteredParticipants[participants[i]];
            }
            delete participants;
            numberOfParticipants = 0;
            payable(prevWinner).transfer(address(this).balance);
            lotteryHappened = true;
        }
        
    }

    // For participants to withdraw from the pool
    function withdraw() public payable{
        require(enteredParticipants[msg.sender].hasEntered);
        uint withdrawAmount = enteredParticipants[msg.sender].amount;
        payable(msg.sender).transfer(withdrawAmount);
        delete enteredParticipants[msg.sender];
        uint len = participants.length;
        for(uint i = 0; i < len; i++){
            if(participants[i] == msg.sender){
                participants[i] = participants[len - 1];
                numberOfParticipants --; 
                participants.pop();
                gamesPlayed[msg.sender]--;
            }
        }
    }

    // To view participants in current pool
    function viewParticipants() public view returns (address[] memory, uint) {
        return (participants, numberOfParticipants);
    }

    // To view winner of last lottery
    function viewPreviousWinner() public view returns (address) {
        require(lotteryHappened);
        return prevWinner;
    }

    // To view the amount earned by Gavin
    function viewEarnings() public onlyOwner view returns (uint256) {
        return ownerProfit;
    }

    // To view the amount in the pool
    function viewPoolBalance() public view returns (uint256) {
        return address(this).balance;
    }
}
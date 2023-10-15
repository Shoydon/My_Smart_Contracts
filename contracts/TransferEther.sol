// 1. Contract with 2 public addresses, ‘sender’ and ‘receiver’.
// 2. TransferEther function allows the sender to initiate a transfer of Ether to the receiver.
// 3. getContractBalance function allows anyone to check the balance of the smart contract.

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TransferEth{

    address public sender;
    address public receiver;

    constructor(){
        sender = msg.sender;
    }

    function receiverAddr(address _receiver) public {
        receiver = _receiver;
    }

    function transferAmount() public payable {
        require(msg.sender == sender, "Only owner can send ether");
        require(receiver != address(0), "Please enter a receiver address");
        (bool success, ) = receiver.call{value: msg.value}("");
        require(success == true, "Transaction failed");
    }

    function getContractBalance() public view returns (uint256){
        return address(this).balance;
    }
}
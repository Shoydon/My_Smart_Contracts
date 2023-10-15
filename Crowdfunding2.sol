//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
contract CrowdFunding{
    event FundsRaised(address contributor, string name, uint amount);
    event FundsReleased(uint totalFundsRaised, string message);
    event Refund(address contributor, string message);
    address payable campaignOwner;
    uint public totalFundsRaised;
    uint public fundingGoal;
    bool public isCampaignComplete;
    uint public deadline;
    struct contributor{
        string name;
        uint amount;
    }
    mapping(address => contributor) public contributions;
    mapping(address => bool) public refunds;
    modifier OnlyOwner(){
        require(msg.sender == campaignOwner, "Only the owner can call this function");
        _;
    }
    constructor(){
        campaignOwner = payable(msg.sender);
        totalFundsRaised = 0 ether;
        fundingGoal = 100 ether;
        deadline = block.timestamp + 3 minutes; 
    }
    function contribute(string memory _name) public payable {
        require(block.timestamp <= deadline, "Campaign is over");
        require(!isCampaignComplete , "Campaign is already complete!");
        require(msg.value > 0, "Contribution must be greater than 0");
        totalFundsRaised += msg.value;
        contributions[msg.sender].name = _name;
        contributions[msg.sender].amount += msg.value;
        refunds[msg.sender] = false;
        if (totalFundsRaised >= fundingGoal) {
            isCampaignComplete = true;
        }
        emit FundsRaised(msg.sender, _name, msg.value);
    }
    function releaseFunds() external OnlyOwner payable{
        require(isCampaignComplete, "Campaign is not yet completed!");
        require(totalFundsRaised >= fundingGoal, "Goal not yet reached!");
        uint256 contractBalance = address(this).balance;
        campaignOwner.transfer(contractBalance);
        emit FundsReleased(totalFundsRaised, "Thankyou all for contributing!");
    }
    function refund() external {
        require(block.timestamp <= deadline, "Campaign is already over");
        require(contributions[msg.sender].amount > 0, "No funds to withdraw");
        require(!refunds[msg.sender], "Already refunded");

        uint refundBalance = contributions[msg.sender].amount;
        payable(msg.sender).transfer(refundBalance);
        contributions[msg.sender].amount = 0;
        refunds[msg.sender] = true;
        totalFundsRaised -= refundBalance;
        emit Refund(msg.sender, "Amount Refunded");
    } 
}

// refunds 
// time constraints for achieving the funding goal. 
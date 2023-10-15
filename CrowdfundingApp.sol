//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
contract CrowdFunding{
    
    struct contributor{
        string name;
        uint amount;
        uint contributionPercent;
    }

    event FundsRaised(address contributor, string name, uint amount);
    event FundsReleased(uint totalFundsRaised, string message);
    event ProfitSent(string name, string message);

    address payable campaignOwner;
    uint public totalFundsRaised;
    uint public fundingGoal;
    bool public isCampaignComplete;
    mapping(address => contributor) public contributions;
    uint profitDeposited;
    uint profit;

    modifier OnlyOwner(){
        require(msg.sender == campaignOwner, "Only the owner can call this function");
        _;
    }

    constructor(uint _fundingGoal){
        campaignOwner = payable(msg.sender);
        totalFundsRaised = 0 ether;
        fundingGoal =  _fundingGoal * 1 ether;
    }
    
    function contribute(string memory _name) public payable {
        require(!isCampaignComplete , "Campaign is already complete!");
        require(msg.value > 0, "Contribution must be greater than 0");
        totalFundsRaised += msg.value;
        contributions[msg.sender].name = _name;
        contributions[msg.sender].amount += msg.value;
        contributions[msg.sender].contributionPercent = contributions[msg.sender].amount/fundingGoal;
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

    function depositProfit() OnlyOwner public payable{
        profitDeposited += msg.value;
        profit = profitDeposited - fundingGoal;
    }
    function viewProfitDeposited() OnlyOwner public view returns(uint, uint){
        return (profitDeposited, profit);
    }
    function sendProfit(address _rcvrAddress)OnlyOwner public payable{
        // uint256 contractBalance = address(this).balance;
        uint256 transferableBal = contributions[_rcvrAddress].amount + profit * contributions[msg.sender].contributionPercent;
        payable(_rcvrAddress).transfer(transferableBal);
        emit ProfitSent(contributions[_rcvrAddress].name, "This contributor has been rewarded");
    }
}
// 1. campaignOwner: The address of the campaign owner who can withdraw the funds once the funding goal is reached.
// 2. fundingGoal: The target amount of Ether that needs to be raised for the campaign to be considered successful.
// 3. totalFundsRaised: The accumulated amount of Ether raised by contributors.
// 4. isCampaignComplete: A boolean variable that indicates whether the funding goal has been reached.
// 5. contributions: A mapping to store the individual contributions made by different addresses.
// 6. FundsRaised: An event emitted when someone makes a contribution.
// 7. FundsReleased: An event emitted when the campaign owner withdraws the funds.
// 8. contribute: A function that allows people to contribute Ether to the campaign. It updates the contributions mapping and checks whether the funding goal has been reached.
// 9. releaseFunds: A function that allows the campaign owner to withdraw the funds once the funding goal is reached. It transfers the entire balance of the contract to the owner's address.
// 10. depositProfit: owner deposits the earnings of the movie, profit is calculated
// 11. viewProfitDeposited
// 12. sendProfit: send profit to the user based on his contribution
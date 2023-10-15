//My academic Blockchain project

// 1. campaignOwner: The address of the campaign owner who can withdraw the funds once the funding goal is reached.
// 2. fundingGoal: The target amount of Ether that needs to be raised for the campaign to be considered successful.
// 3. totalFundsRaised: The accumulated amount of Ether raised by contributors.
// 4. isCampaignComplete: A boolean variable that indicates whether the funding goal has been reached.
// 5. contributors: A nested mapping to store the individual contributions made by different addresses.
// 6. FundsRaised: An event emitted when someone makes a contribution.
// 7. FundsReleased: An event emitted when the campaign owner withdraws the funds.
// 8. contribute: A function that allows people to contribute Ether to the campaign. It updates the contributions mapping and checks whether the funding goal has been reached.
// 9. releaseFunds: A function that allows the campaign owner to withdraw the funds once the funding goal is reached. It transfers the entire balance of the contract to the owner's address.
// 10. createCampaign: A function to create a campaign
// 11. getCampaignData: gives basic details about the campaign

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract CrowdFunding {

    struct contributor {
        string name;
        uint amount;
    }

    struct Campaign {
        address payable campaignOwner;
        string title;
        uint fundingGoal;
        uint totalFundsRaised;
        bool isCampaignComplete;
    }

    //events to be raised after their respective functions are called
    event FundsRaised(address contributor, string name, uint amount);
    event FundsReleased(uint totalFundsRaised, string message);
    event CampaignCreated(string name, uint fundingGoal);

    mapping(address => mapping(uint => contributor)) contributors;
    Campaign[] campaigns;
    uint public numberOfCampaigns = 0;

    function createCampaign(string memory _title, uint _fundingGoal) public payable{
        Campaign memory campaign = Campaign({
            campaignOwner: payable(msg.sender),
            title: _title,
            fundingGoal: _fundingGoal,
            totalFundsRaised: 0,
            isCampaignComplete: false
        });
        campaigns.push(campaign);
        emit CampaignCreated(campaigns[numberOfCampaigns].title, campaigns[numberOfCampaigns].fundingGoal);
        numberOfCampaigns++;
    }

    function contribute(string memory _name, uint _campaignID) public payable {
        require(!campaigns[_campaignID].isCampaignComplete,"Campaign is already complete!");
        require(msg.value > 0, "Contribution must be greater than 0");
        campaigns[_campaignID].totalFundsRaised += msg.value;
        contributors[msg.sender][_campaignID].name = _name;
        contributors[msg.sender][_campaignID].amount += msg.value;
        if (campaigns[_campaignID].totalFundsRaised >= campaigns[_campaignID].fundingGoal) {
            campaigns[_campaignID].isCampaignComplete = true;
        }
        emit FundsRaised(msg.sender, _name, msg.value);
    }

    function releaseFunds(uint _campaignID) external payable {
        require(campaigns[_campaignID].campaignOwner == msg.sender, "Only Owner can use this function");
        require(campaigns[_campaignID].isCampaignComplete, "Campaign is not yet completed!");
        uint256 contractBalance = address(this).balance;
        campaigns[_campaignID].campaignOwner.transfer(contractBalance);
        emit FundsReleased(campaigns[_campaignID].totalFundsRaised, "Thankyou all for contributing!");
    }

    function getCampaignData(uint _campaignID) public view returns (address, string memory, uint, bool) {
        return (campaigns[_campaignID].campaignOwner, campaigns[_campaignID].title, campaigns[_campaignID].fundingGoal, campaigns[_campaignID].isCampaignComplete) ;
    }
}


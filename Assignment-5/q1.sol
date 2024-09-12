//Crowdfunding Contract

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract CrowdfundingPlatform {
    
    struct Campaign {
        address payable creator;
        uint targetAmount;
        uint deadline;
        uint totalContributions;
        bool finalized;
        mapping(address => uint) contributions;
    }
    
    uint public campaignCount = 0;
    mapping(uint => Campaign) public campaigns;

    event CampaignCreated(uint campaignId, address creator, uint targetAmount, uint deadline);
    event ContributionReceived(uint campaignId, address contributor, uint amount);
    event CampaignFinalized(uint campaignId, bool successful);

    // Function to create a new crowdfunding campaign
    function createCampaign(uint _targetAmount, uint _durationInDays) public {
        require(_targetAmount > 0, "Target amount must be greater than 0");

        uint deadline = block.timestamp + (_durationInDays * 1 days);
        Campaign storage newCampaign = campaigns[campaignCount];
        newCampaign.creator = payable(msg.sender);
        newCampaign.targetAmount = _targetAmount;
        newCampaign.deadline = deadline;
        newCampaign.finalized = false;
        
        emit CampaignCreated(campaignCount, msg.sender, _targetAmount, deadline);

        campaignCount++;
    }

    // Function to contribute to a specific campaign
    function contribute(uint _campaignId) public payable {
        require(_campaignId < campaignCount, "Invalid campaign ID");
        Campaign storage campaign = campaigns[_campaignId];
        require(block.timestamp < campaign.deadline, "Campaign deadline has passed");
        require(msg.value > 0, "Contribution must be greater than 0");

        campaign.contributions[msg.sender] += msg.value;
        campaign.totalContributions += msg.value;

        emit ContributionReceived(_campaignId, msg.sender, msg.value);
    }

    // Function to finalize the campaign: either transfer funds to the creator or allow refunds
    function finalizeCampaign(uint _campaignId) public {
        require(_campaignId < campaignCount, "Invalid campaign ID");
        Campaign storage campaign = campaigns[_campaignId];
        require(block.timestamp >= campaign.deadline, "Campaign is still active");
        require(!campaign.finalized, "Campaign already finalized");

        if (campaign.totalContributions >= campaign.targetAmount) {
            // Target met, transfer funds to the creator
            campaign.creator.transfer(campaign.totalContributions);
            emit CampaignFinalized(_campaignId, true);
        } else {
            // Target not met, contributors can withdraw their funds
            emit CampaignFinalized(_campaignId, false);
        }

        campaign.finalized = true;
    }

    // Function for contributors to withdraw their funds if the campaign failed
    function withdrawFunds(uint _campaignId) public {
        require(_campaignId < campaignCount, "Invalid campaign ID");
        Campaign storage campaign = campaigns[_campaignId];
        require(block.timestamp >= campaign.deadline, "Campaign is still active");
        require(!campaign.finalized || campaign.totalContributions < campaign.targetAmount, "Campaign was successful");

        uint contributedAmount = campaign.contributions[msg.sender];
        require(contributedAmount > 0, "No contributions to withdraw");

        campaign.contributions[msg.sender] = 0;
        payable(msg.sender).transfer(contributedAmount);
    }
}

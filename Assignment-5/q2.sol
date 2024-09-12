//Voting System Contract

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VotingSystem {

    struct Proposal {
        string description;
        uint voteCount;
    }

    struct Voter {
        bool hasVoted;
        uint votedProposal;
    }

    address public admin;
    Proposal[] public proposals;
    mapping(address => Voter) public voters;

    event ProposalCreated(uint proposalId, string description);
    event Voted(address voter, uint proposalId);
    event WinningProposal(uint proposalId, string description, uint voteCount);

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can perform this action");
        _;
    }

    constructor() {
        admin = msg.sender;  // Set the deployer as the admin
    }

    // Function to create a new proposal
    function createProposal(string memory _description) public onlyAdmin {
        proposals.push(Proposal({
            description: _description,
            voteCount: 0
        }));
        emit ProposalCreated(proposals.length - 1, _description);
    }

    // Function to vote for a specific proposal
    function vote(uint _proposalId) public {
        require(_proposalId < proposals.length, "Invalid proposal ID");
        require(!voters[msg.sender].hasVoted, "You have already voted");

        voters[msg.sender] = Voter({
            hasVoted: true,
            votedProposal: _proposalId
        });

        proposals[_proposalId].voteCount++;

        emit Voted(msg.sender, _proposalId);
    }

    // Function to get the total number of proposals
    function getProposalCount() public view returns (uint) {
        return proposals.length;
    }

    // Function to get the details of a specific proposal
    function getProposal(uint _proposalId) public view returns (string memory description, uint voteCount) {
        require(_proposalId < proposals.length, "Invalid proposal ID");
        Proposal storage proposal = proposals[_proposalId];
        return (proposal.description, proposal.voteCount);
    }

    // Function to determine the winning proposal based on the highest number of votes
    function determineWinner() public view returns (uint winningProposalId, string memory winningDescription, uint winningVoteCount) {
        require(proposals.length > 0, "No proposals to vote on");

        uint highestVoteCount = 0;
        uint winningId;

        for (uint i = 0; i < proposals.length; i++) {
            if (proposals[i].voteCount > highestVoteCount) {
                highestVoteCount = proposals[i].voteCount;
                winningId = i;
            }
        }

        return (winningId, proposals[winningId].description, proposals[winningId].voteCount);
    }

    // Admin can declare the winner publicly
    function declareWinner() public onlyAdmin {
        (uint winningId, string memory winningDescription, uint winningVoteCount) = determineWinner();
        emit WinningProposal(winningId, winningDescription, winningVoteCount);
    }
}

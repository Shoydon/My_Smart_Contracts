//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Voting {

    struct Voter{
        address votedCandidate;
        bool hasVoted;
        bool hasRegistered;
    }

    struct Candidate{
        string name;   
        uint votes;
        bool hasRegistered;
    }

    bool public votingStarted = false;
    address winningCandidate;
    mapping(address => Candidate) candidates;
    mapping(address => Voter) voters;

    function addCandidate(string memory name) public {
        require(!votingStarted, "Election has already started");
        candidates[msg.sender] = Candidate({
            name: name,
            votes: 0,
            hasRegistered: true
        });
    }

    function registerVoter() public {
        require(!voters[msg.sender].hasRegistered, "You are already registered");
        voters[msg.sender].hasRegistered = true;
    }

    function vote(address candidateAddr) public {
        if(!votingStarted){
            votingStarted = true;   
            winningCandidate = candidateAddr;
        }
        require(voters[msg.sender].hasRegistered, "You aren't registered as a voter");
        require(candidates[candidateAddr].hasRegistered, "Invalid Candidate address");
        require(!voters[msg.sender].hasVoted, "You have already voted");
        candidates[candidateAddr].votes += 1;
        voters[msg.sender].votedCandidate = candidateAddr;
        voters[msg.sender].hasVoted = true;

        if(candidates[candidateAddr].votes > candidates[winningCandidate].votes){
            winningCandidate = candidateAddr;
        }
    }

    function getWinningCandidate()public view returns(Candidate memory){
        return candidates[winningCandidate];
    }
}
// 1. Voter and Cadidate structs
// 2. votingStarted: bool var to check if the voting has started or not
// 3. winningCandidate: stores the address of the winning candidate
// 4. candidates: mapping to store the candidates' data
// 4. voters: mapping to store the voters' data
// 5. addCandidate() : When the msg.sender wants to register himmself as a candidate 
// 6. registerVoter() : register the msg.sender as a voter in order to vote
// 7. vote(): allows the msg.sender to vote a candidate;
// 8. getWinningCandidate(): returns the data of the winning candidate

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
    address[] candidateAddresses;

    function addCandidate(string memory name) public {
        require(!votingStarted, "Election has already started");
        candidates[msg.sender] = Candidate({
            name: name,
            votes: 0,
            hasRegistered: true
        });
        candidateAddresses.push(msg.sender);
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

    function getCandidates() public view returns (address[] memory){
        return candidateAddresses;
    }

    function getWinningCandidate()public view returns(Candidate memory){
        return candidates[winningCandidate];
    }
}
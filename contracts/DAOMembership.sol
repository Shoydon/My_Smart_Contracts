// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DAOMembership {
    struct Requester{
        uint votes;
        bool requester;
        address[] voters;
    }

    mapping (address => bool) members;     
    mapping (address => Requester) requests;
    uint numberOfMembers;

    constructor(){
        members[msg.sender] = true;     // set the deployer as the first member of the DAO by default
        numberOfMembers++;
    }
    
    modifier onlyMembers(){
        require(members[msg.sender]);
        _;
    }

    //To apply for membership of DAO
    function applyForEntry() public {
        require(!members[msg.sender]);  //check if the msg.sender is already a member or not
        require(!requests[msg.sender].requester);   //check if the msg.sender is already a requester or not
        requests[msg.sender].votes = 0; //initialize the votes for the requester
        requests[msg.sender].requester = true;  
    }
    
    //To approve the applicant for membership of DAO
    function approveEntry(address _applicant) public onlyMembers{
        require(requests[_applicant].requester);    // check if the _applicant is actually a requester or not
        for(uint i = 0; i < requests[_applicant].voters.length; i++){
            require(requests[_applicant].voters[i] != msg.sender);  //check if the msg.sender has already voted
        }
        requests[_applicant].votes++;
        requests[_applicant].voters.push(msg.sender);
        if(requests[_applicant].votes * 10 >= numberOfMembers * 3){ // check if the requester has got votes from atleast 30 % of the current members present
            members[_applicant] = true;     // if enough votes then add the _applicant to members 
            delete requests[_applicant];    // remove _applicant from the requesters list
            numberOfMembers++;
        }
    }

    //To check membership of DAO
    function isMember(address _user) public view onlyMembers returns (bool) {
        return members[_user];
    }

    //To check total number of members of the DAO
    function totalMembers() public view onlyMembers returns (uint) {
        return numberOfMembers;
    }
}

// 1. applyForEntry() : Only accessible to the non-members of the DAO. Using this function they can send the request to join the DAO
// 2. approveEntry(address applicant) : Only accessible only to the members of the DAO. Using this function, members can approve the applicants for the membership. As soon as 30% or more people approve the entry, the applicant becomes the member of the DAO.
// 3. isMember(address participant) : Only accessible to the members of DAO. Using this function, a member can check by passing in the arguments wheather a user corresponding to the address is a member of DAO or not
// 4. totalMembers() : Only accessible to the members of DAO. Using this function, a member can check the total number of current members in the DAO.

// incrementCounter()  : This functions increments the counter for particular announcement ID. It is known that the ID is greater than 0.
// viewCounter() : This function returns the number of counts someone interacted with an announcement for the respective announcement ID.

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract CommunityCounter {

    mapping(uint => uint) announcements;

    function incrementCounter(uint announcement_id) public {
        require(announcement_id > 0);
        announcements[announcement_id]++;
    }

    function viewCounter(uint announcement_id) public view returns(uint) {
        require(announcement_id > 0);
        return announcements[announcement_id];
    }
}

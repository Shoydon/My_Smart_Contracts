// subscribe() : This function is used to subscribe the service for a duration. duration is defined in seconds. The value for activating the service is 1000 wei.
// cancelSubscription() : This function is used to cancel the subscription. There is no refund policy.
// isSubscribed() : This function returns the current status of the subscription for particular user.

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SubscriptionService {

    struct Subscriber {
        bool isSubscribed;
        uint duration;
    }

    mapping (address => Subscriber) subscribers;

    function subscribe(uint256 duration) public payable {
        require(duration > 0);
        require(msg.value == 1000);
        subscribers[msg.sender] = Subscriber(true, duration);
    }

    function isSubscribed(address user) external view returns (bool) {
        require(user != address(0));
        return subscribers[user].isSubscribed;
    }

    function cancelSubscription() external {
        subscribers[msg.sender] = Subscriber(false, 0);
    }
}

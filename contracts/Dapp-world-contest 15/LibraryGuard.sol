// transferOwnership() : This functions is used to update the owner of the smart contract. Only current owner can update transfer the ownership of this contract.
// addAdmin() : This function is used to add new admins and only be called by the current owner of the contract.
// removeAdmin() : This function is used to remove the admin and only be called by the current owner of the contract.
// updateUserRole() :This function is used to assign the role to user and only be called by the admins of the contract.
// contractOwner() : This function returns the current owner of the smart contract.
// isAdmin() : This function returns true if the user is admin otherwise returns false.
// userRole() : This function returns the id of the role of user.


// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract LibraryGuard {
    struct User {
        uint role;
        bool isAdmin;
    }
    address owner;
    mapping (address => User) users;
    constructor() {
        owner = msg.sender;
    }
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }
    function contractOwner() public view returns(address) {
        return owner;
    }
    function transferOwnership(address _newOwner) public onlyOwner {
        require(_newOwner != address(0));
        owner = _newOwner;
    }
    function addAdmin(address _admin) public onlyOwner {
        require(_admin != address(0));
        users[_admin].isAdmin = true;
    }
    function removeAdmin(address _admin) public onlyOwner {
        require(_admin != address(0));
        users[_admin].isAdmin = false;
    }
    function updateUserRole(address _user, uint256 _role) public {
        require(users[msg.sender].isAdmin);
        require(_user != address(0));
        users[_user].role = _role;
    }
    function isAdmin(address _user) public view returns(bool) {
        require(_user != address(0));
	    return users[_user].isAdmin;
    }
    function userRole(address _user) public view returns(uint){
        require(_user != address(0));
        return users[_user].role;
    }
}

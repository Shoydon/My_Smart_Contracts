// 1. grantScholarship() : This function is only accessible to the owner of the contract. The owner can use this function to assign credits to the wallet address of a student.
// 2. registerMerchantAddress() : This function is only accessible to the owner of the contract. The owner can use this function to register a new merchant who can receive credits from students.
// 3. deregisterMerchantAddress() : This function is only accessible to the owner of the contract. The owner can use this function to deregister an existing merchant. After deregistration, the student won't be able to send credits to this merchant until they are registered again.
// 4. revokeScholarship() : This function is only accessible to the owner of the contract. The owner can use this function to revoke the scholarship of a student. After revocation, any unspent credits assigned to the student will be assigned back to the owner, and the student won't have access to spending any credits.
// 5. spend():This function is only accessible to students holding scholarships. Students can use this function to transfer credits only to registered merchants.
// 6. checkBalance() : This function is accessible by scholarship holding students, registered merchants, and the owner. Using this function, they can see the available credits assigned to their address.


// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

contract ScholarshipCreditContract {

    struct Student{
        uint credits;
        bool gotScholarship;
    }

    struct Merchant{
        uint credits;
        bool isRegistered;
    }

    uint  ownerCredits;     // total credits of the owner
    mapping(address => Merchant) merchants; // merchants
    mapping(address => Student) students;   // students
    address owner;

    constructor (){
        owner = msg.sender;
        ownerCredits = 1000000;
    }

    modifier onlyOwner(){
        require(msg.sender == owner);
        _;
    }

    modifier onlyStudents(){
        require(students[msg.sender].gotScholarship);
        _;
    }

    //This function assigns credits to student getting the scholarship
    function grantScholarship(address studentAddress, uint credits) public onlyOwner {
        require(msg.sender != studentAddress);
        require(!merchants[studentAddress].isRegistered);
        require(ownerCredits >= credits);

        ownerCredits -= credits;
        students[studentAddress].credits += credits;
        students[studentAddress].gotScholarship = true;
    }

    //This function is used to register a new merchant who can receive credits from students
    function registerMerchantAddress(address merchantAddress) public onlyOwner {
        require(!merchants[merchantAddress].isRegistered);
        require(!students[merchantAddress].gotScholarship);
        require(msg.sender != merchantAddress);

        merchants[merchantAddress].isRegistered = true;
    }

    //This function is used to deregister an existing merchant
    function deregisterMerchantAddress(address merchantAddress) public onlyOwner{
        require(merchants[merchantAddress].isRegistered);

        ownerCredits += merchants[merchantAddress].credits;
        merchants[merchantAddress].credits = 0;
        merchants[merchantAddress].isRegistered = false;
    }

    //This function is used to revoke the scholarship of a student
    function revokeScholarship(address studentAddress) public onlyOwner{
        require(students[studentAddress].gotScholarship);
        
        ownerCredits += students[studentAddress].credits; 
        students[studentAddress].credits = 0;
        students[studentAddress].gotScholarship = false;
    }

    //Students can use this function to transfer credits only to registered merchants
    function spend(address merchantAddress, uint amount) public onlyStudents{
        require(merchants[merchantAddress].isRegistered);
        require(students[msg.sender].credits >= amount);

        merchants[merchantAddress].credits += amount;
        students[msg.sender].credits -= amount;
    }

    //This function is used to see the available credits assigned.
    function checkBalance() public view returns (uint) {
        if(students[msg.sender].gotScholarship){
            return students[msg.sender].credits;
        }
        else if(merchants[msg.sender].isRegistered){
            return merchants[msg.sender].credits;
        }
        else if(msg.sender == owner){
            return ownerCredits;
        }
        revert();
    }
}
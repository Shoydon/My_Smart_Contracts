// addBook(string title, string author, string publication):  accessible by the owner
// Using this function, the owner can add a book by specifying the title, author, and publication of the book respectively.
// The book should automatically get an ID of type uint assigned to it in the smart contract. The ID of the newly added book should be one greater than the ID of the previously added book, or 1 if no books have been added yet.

// removeBook(uint id): accessible by the owner
// Using this function, owner can make a book unavailable in cases like the book being sold, the book getting damaged, etc.

// updateDetails(uint id, string title, string author, string publication, bool available): This function should only be accessible by owner. Using this function can modify the details of a book whose ID is id. If there is no book with ID id in the database, the transaction must fail. ( Check the explanation of getDetailsById() function below for better understanding).

// The smart contract has a boolean indicating the availability of a book. This boolean value will be true if the book is available and false if the book is not available.

// findBookByTitle(string title) returns (uint[]): accessible by everyone
// Returns an array of book IDs matching the given title. If the owner calls the function, IDs of all books (available and unavailable) are returned. For other addresses, only IDs of available books with the matching title are returned.

// findAllBooksOfPublication(string publication) returns (uint[]): accessible by everyone
// Returns an array of book IDs matching the given publication. If the owner calls the function, IDs of all books (available and unavailable) are returned. For other addresses, only IDs of available books with the matching publication are returned.

// findAllBooksOfAuthor(string author) returns (uint[]): accessible by everyone
// Returns an array of book IDs matching the given author. If the owner calls the function, IDs of all books (available and unavailable) are returned. For other addresses, only IDs of available books with the matching author are returned.

// getDetailsById(uint id) returns (string title, string author, string publication, bool available): accessible by: Everyone
// Returns details (title, author, publication, and availability) of the book with the given ID. If the owner calls the function, details are returned regardless of availability. For other addresses, details are returned only if the book is available; otherwise, the transaction fails. If no book with the given ID exists, the transaction fails.

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

contract Bookstore {

    address owner;

    constructor() {
        owner = msg.sender;
    }

    struct Book{
        uint id;
        string title;
        string author;
        string publication;
        bool available;
    }

    modifier onlyOwner{
        require(msg.sender == owner);
        _;
    }

    uint numberOfBooks = 0;
    Book[] public books;

    // this function can add a book and only accessible by the owner
    function addBook(string memory title, string memory author, string memory publication) public onlyOwner{
        numberOfBooks++;
        Book memory bookToAdd = Book(numberOfBooks, title, author, publication, true);
        books.push(bookToAdd);
    }

    // this function makes book unavailable and only accessible by the owner
    function removeBook(uint id) public onlyOwner {
        require(id > 0 && id <= numberOfBooks);
        bool bookPresent;
        for(uint i = 0; i < numberOfBooks; i++){
            if(books[i].id == id){
                books[i].available = false;
                bookPresent = true;
            }
        }
        if(!bookPresent){
            revert();
        }
    }

    // this function modifies the book details and only accessible by the owner
    function updateDetails(uint id, string memory title, string memory author, string memory publication, bool available) public onlyOwner {
        bool bookPresent;
        for(uint i = 0; i < numberOfBooks; i++){
            if(books[i].id == id){
                Book memory bookToUpdate = Book(id, title, author, publication, available);
                books[i] = bookToUpdate;
                bookPresent = true;
            }
        }
        if(!bookPresent){
            revert();
        }
    }

    // this function returns the ID of all books with given title
    function findBookByTitle(string memory title) public view returns (uint[] memory)  {
        bool all;
        if(msg.sender == owner){
            all = true;
        }
        uint j = 0;
        for(uint i = 0; i < numberOfBooks; i++){
            string memory tempTitle = books[i].title;
            if((keccak256(bytes(tempTitle)) == keccak256(bytes(title))) && (books[i].available || all)){
                j++;
            }
        }
        // uint[] memory bookIDs;  we cant do this so we run a loop to count the matches (done in the abovr loop) and then create an array to store the id's 
        uint[] memory bookIDs = new uint[](j);
        j = 0;
        for(uint i = 0; i < numberOfBooks; i++){
            string memory tempTitle = books[i].title;
            if((keccak256(bytes(tempTitle)) == keccak256(bytes(title))) && (books[i].available || all)){
                bookIDs[j] = books[i].id;
                j++;
            }
        }
        return bookIDs;
    }

    // this function returns the ID of all books with given publication
    function findAllBooksOfPublication (string memory publication) public view returns (uint[] memory)  {
        bool all;
        if(msg.sender == owner){
            all = true;
        }
        uint j = 0;
        for(uint i = 0; i < numberOfBooks; i++){
            string memory pub = books[i].publication;
            if((keccak256(bytes(pub)) == keccak256(bytes(publication))) && (books[i].available || all)){
                j++;
            }
        }
        uint[] memory bookIDs = new uint[](j);
        j = 0;
        for(uint i = 0; i < numberOfBooks; i++){
            string memory pub = books[i].publication;
            if((keccak256(bytes(pub)) == keccak256(bytes(publication))) && (books[i].available || all)){
                bookIDs[j] = books[i].id;
                j++;
            }
        }
        return bookIDs;
    }

    // this function returns the ID of all books with given author
    function findAllBooksOfAuthor (string memory author) public view returns (uint[] memory)  {
        bool isAdmin = (msg.sender == owner);
        uint j = 0;

        for(uint i = 0; i < numberOfBooks; i++){
            string memory tempTitle = books[i].author;
            if((keccak256(bytes(tempTitle)) == keccak256(bytes(author))) && (books[i].available || isAdmin)){
                j++;
            }
        }
        uint[] memory bookIDs = new uint[](j);
        j = 0;
        for(uint i = 0; i < numberOfBooks; i++){
            string memory auth = books[i].author;
            if((keccak256(bytes(auth)) == keccak256(bytes(author))) && (books[i].available || isAdmin)){
                bookIDs[j] = books[i].id;
                j++;
            }
        }
        return bookIDs;
    }

    // this function returns all the details of book with given ID
    function getDetailsById(uint id) public view returns (string memory title, string memory author, string memory publication, bool available)  {
        require(id != 0);
        bool all;
        if(msg.sender == owner){
            all = true;
        }
        for(uint i = 0; i < numberOfBooks; i++){
            if((books[i].id == id) && (all || books[i].available)){
                return (books[i].title, books[i].author, books[i].publication, books[i].available);
            }
        }
        revert();
    }

}
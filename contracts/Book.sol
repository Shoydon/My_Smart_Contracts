// Solidity code to manage Books in a bookstore
// Book struct: structure of a book 
///setBook: takes parameters of book and creates a new book
// resetBook: deletes the book with the particular bookID

//SPDX-License-Identifier:MIT
pragma solidity ^0.8.6;
contract structure{
    struct Book{
        address owner;
        string title;
        string author;
        uint price;
    }
    mapping(uint => Book) books;
    uint[] booksID;
    function setBook(string memory _title, string memory _author, uint _bookID, uint _price) public {
        // books[_bookID] = Book(msg.sender, "Blokchain for beginners","Ineuron",1000);
        require(books[_bookID].owner != address(0), "Book already exists");
        books[_bookID] = Book({
            owner: msg.sender,
            title: _title,
            author: _author,
            price:_price
        });
        booksID.push(_bookID);
    }
    function resetBook(uint _bookID) public {
        delete books[_bookID];
    }
    function getBookIds() public view returns(uint[] memory){
        return booksID;
    }
    function getAuthor(uint _bookID) public view returns(string memory){
        return (books[_bookID].author);
    }
    function getTitle(uint _bookID) public view returns(string memory){
        return (books[_bookID].title);
    }
    function getPrice(uint _bookID) public view returns(uint){
        return (books[_bookID].price);
    }
    function getBookInfo(uint _bookID) public view returns(Book memory){
        return (books[_bookID]);
    }
}
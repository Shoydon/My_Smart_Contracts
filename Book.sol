// Task- provide detailed gas cost report for the following code by using storage ,
// memory and calldata for the different structs and variables used. Use separate
// functions to get title, author, bookId and price for this task
//SPDX-License-Identifier:MIT
pragma solidity 0.8.6;
contract structure{
    struct Book{
        string title;
        string author;
        uint bookID;
        uint price;
    }
// define a struct- name of the struct variable to represent the struct
    Book book;
    function setBook() public {
        book= Book("Blokchain for beginners","Ineuron",4,1000);
    }
    function resetBook() public {
        book= Book("","",0,0);
    }
    function getBookId() public view returns(uint, uint){
        // uint gas = gasleft();
        uint gas = 0; 
        gas = gasleft();
        return (book.bookID, gas);
    }
    function getAuthor() public view returns(string memory, uint){
        // uint gas = gasleft();
        uint gas = 0; 
        gas = gasleft();
        // gas = msg.gas;
        return (book.author, gas);
    }
    function getTitle() public view returns(string memory, uint){
        uint gas = 0; 
        gas = gasleft();
        return (book.title, gas);
    }
    function getPrice() public view returns(uint, uint){
        // uint gas = gasleft();
        uint gas = 0; 
        gas = gasleft();
        return (book.price, gas);
    }
}
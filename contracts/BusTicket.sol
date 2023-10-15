// 1. bookSeats(uint[] seatNumbers): This function takes an array of seat numbers as input. 
// It will then iterate through the array and for each seat number, it will check if that seat is already reserved or not by looking in a mapping
// It will also check if there are any repetitions in the input
// 2. showAvailableSeats() returns (uint[]): This function returns the array of all the seat numbers that are available. 
// 3. checkAvailability(uint seatNumber) returns (bool): Using this function, availability of a seat can be checked. If seat corresponding to seatNumber is available, then the function returns true, else it returns false.
// 4. myTickets() returns (uint[]):This function returns an array consisting of all the seat numbers booked by the msg.sender. In case, there are no seats booked, an empty array will be returned.
// 5. customers: mapping to store the address of customers with the seats booked (as an array of integers)
// 6. seatsBooked[] : array to store the seats that are booked
// 7. maxSeatsPerAddress: max seats that can be booked by an address
// 8. maxSeats: maximum seats in the bus


// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TicketBooking {

    mapping(address => uint[]) customers;
    uint maxSeats = 20;
    uint maxSeatsPerAddress = 4;
    uint[] seatsBooked;

    //To book seats
    function bookSeats(uint[] memory seatNumbers) public {
        uint len = seatNumbers.length;
        //check if the input is empty or not
        require(len > 0);
        //check if 
        require(maxSeatsPerAddress >= customers[msg.sender].length + len);
        //sort the input array in ascending order to make it easier for checking availibility
        for (uint i = 0; i < len - 1; i++) {
            for (uint j = 0; j < len - i - 1; j++) {
                if (seatNumbers[j] > seatNumbers[j + 1]) {
                    (seatNumbers[j], seatNumbers[j + 1]) = (seatNumbers[j + 1], seatNumbers[j]); // Swap
                }
            }
        }
        //check for duplicate values in array
        for(uint i = 0; i < len-1; i ++){
            for(uint j = i+1; j < len; j++){
                if(seatNumbers[i] == seatNumbers[j]){
                    revert();
                }
            }
        }
        //check for availability of each seat
        for(uint i = 0; i < len; i++){
            if(!checkAvailability(seatNumbers[i]) || seatNumbers[i] < 1 || seatNumbers[i] > maxSeats){
                revert();
            }
        }
        //book the seats
        for(uint i = 0; i < len; i++){
            customers[msg.sender].push(seatNumbers[i]);
            seatsBooked.push(seatNumbers[i]);
        }

    }
    
    //To get available seats
    function showAvailableSeats() public view returns (uint[] memory) {
        // since the seats are originally numbered as integers without any gaps, we can find the missing values in the seatsBooked array and append them in the availSeats array
        // im using the "i" iterator to iterate to maxSeats as well as check the available seats 
        uint[] memory availSeats = new uint[](maxSeats - seatsBooked.length);
        uint j = 0; //seatsBooked pointer
        uint k = 0; //availSeats pointer
        bool flag = true;   // to check if the seatsBooked pointer has reached the end
        for(uint i = 1; i <= maxSeats ;i++){
            if (j == seatsBooked.length){   // check if the seatsBooked pointer has reached the end of the array
                flag = false;
            }
            if(flag && i == seatsBooked[j] ){   //if "i" is present in seatsBooked array then pass
                j++;
            }
            else{                               // else append in availSeats
                availSeats[k] = i;
                k++;
            }
        }
        return availSeats;
    }
    
    //To check availability of a seat
    function checkAvailability(uint seatNumber) public view returns (bool) {
        // check if the inputs are valid seat numbers
        if(seatNumber < 1 || seatNumber > maxSeats){
            revert();
        }
        //check if the seat number is booked by iterating through the seatsBooked array
        for(uint i = 0; i < seatsBooked.length; i++){
            if (seatNumber == seatsBooked[i]){
                return false;
            }
        }
        return true;
    }
    
    //To check tickets booked by the user
    function myTickets() public view returns (uint[] memory) {
        return customers[msg.sender];
    }
}

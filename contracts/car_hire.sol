// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract CarHire {

    address owner;

// this runs when the contract gets deployed and sets the deployer to be the owner 
    constructor() { 
        owner = msg.sender;//msg is a global variable
    }

    // Add yourself as a Renter

    struct Renter {
        address payable walletAddress;
        string firstName;
        string lastName;
        bool canHire;
        bool active;
        uint balance;
        uint due;
        uint start;
        uint end;
    }

    mapping (address => Renter) public renters;//this allows us to know a renter via the wallet address

    function addRenter(address payable walletAddress, string memory firstName, string memory lastName, bool canHire, bool active, uint balance, uint due, uint start, uint end) public {
        renters[walletAddress] = Renter(walletAddress, firstName, lastName, canHire, active, balance, due, start, end);
    }
              
    // Checkout car
    function checkOut(address walletAddress) public {
        require(renters[walletAddress].due == 0, "You have an uncleared debt.");
        require(renters[walletAddress].canHire == true, "You cannot Hire at the moment.");
        renters[walletAddress].active = true;
        renters[walletAddress].start = block.timestamp;
        renters[walletAddress].canHire = false;
    }

    // Check in a car
    function checkIn(address walletAddress) public {
        require(renters[walletAddress].active == true, "Please check out a car first.");
        renters[walletAddress].active = false;
        renters[walletAddress].end = block.timestamp;
        setDue(walletAddress);
    }

    // Get total duration of car use
    function renterTimespan(uint start, uint end) internal pure returns(uint) {
        return end - start;
    }

    function getTotalDuration(address walletAddress) public view returns(uint) {
        require(renters[walletAddress].active == false, "Car is currently in use.");
        uint timespan = renterTimespan(renters[walletAddress].start, renters[walletAddress].end);
        uint timespanInMinutes = timespan / 60;
        return timespanInMinutes;
    }

    // Get Contract balance
    function balanceOf() view public returns(uint) {
        return address(this).balance;
    }

    // Get Renter's balance
    function balanceOfRenter(address walletAddress) public view returns(uint) {
        return renters[walletAddress].balance;
    }

    // Set Due amount
    function setDue(address walletAddress) internal {
        uint timespanMinutes = getTotalDuration(walletAddress);
        uint fiveMinuteIncrements = timespanMinutes / 5;
        renters[walletAddress].due = fiveMinuteIncrements * 5000000000000000;//0.005 converted to gwei(18 d.c system)
    }

    function canHireCar(address walletAddress) public view returns(bool) {
        return renters[walletAddress].canHire;
    }

    // Deposit
    function deposit(address walletAddress) payable public {
        renters[walletAddress].balance += msg.value;
    }

    // Make Payment
    function makePayment(address walletAddress) payable public {
        require(renters[walletAddress].due > 0, "You do not have anything due at this time.");
        require(renters[walletAddress].balance > msg.value, "You do not have enough funds to cover payment. Please make a deposit.");
        renters[walletAddress].balance -= msg.value;
        renters[walletAddress].canHire = true;
        renters[walletAddress].due = 0;
        renters[walletAddress].start = 0;
        renters[walletAddress].end = 0;
    }

}//MAKE_D_Great

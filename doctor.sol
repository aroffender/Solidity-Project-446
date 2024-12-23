// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Doctor {
    uint public doctorCount;
    mapping(uint => address) public doctors;

    function registerDoctor(address _doctorAddress) public {
        doctorCount++;
        doctors[doctorCount] = _doctorAddress;
    }

    modifier onlyDoctor(uint _doctorId) {
        require(doctors[_doctorId] == msg.sender, "Only doctor can perform this action.");
        _;
    }
}

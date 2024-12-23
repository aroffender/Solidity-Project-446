// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Admin {
    uint public adminCount;
    mapping(uint => address) public admins;

    constructor() {
        // Initialize with a first admin who deploys the contract
        adminCount = 1;
        admins[adminCount] = msg.sender;
    }

    modifier onlyAdmin(uint _adminId) {
        require(admins[_adminId] == msg.sender, "Only admin can perform this action.");
        _;
    }

    function registerAdmin(uint _adminId, address _newAdminAddress) public onlyAdmin(_adminId) {
        adminCount++;
        admins[adminCount] = _newAdminAddress;
    }
}

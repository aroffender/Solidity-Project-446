pragma solidity ^0.8.0;

import "./admin.sol";

contract Patient is Admin {
    enum VaccineStatus { NotVaccinated, OneDose, TwoDose }
    
    struct PatientData {
        uint id;
        address patientAddress;
        string symptomsDetails;
        VaccineStatus vaccineStatus;
        bool isDead;
    }

    uint public patientCount;
    mapping(address => PatientData) public patients;

    function registerPatient(string memory _symptomsDetails) public {
        patientCount++;
        patients[msg.sender] = PatientData(patientCount, msg.sender, _symptomsDetails, VaccineStatus.NotVaccinated, false);
    }

    function updatePatientData(uint _adminId, address _patientAddress, VaccineStatus _vaccineStatus, bool _isDead) public onlyAdmin(_adminId) {
        PatientData storage patient = patients[_patientAddress];
        if (patient.isDead) {
            revert("Cannot update data of deceased patient.");
        }
        patient.vaccineStatus = _vaccineStatus;
        patient.isDead = _isDead;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./admin.sol";
import "./patient.sol";
import "./doctor.sol";

contract CovidPatientManagement is Admin, Patient, Doctor {
    struct Appointment {
        uint doctorId;
        uint patientId;
        uint timestamp;
    }

    mapping(uint => Appointment[]) public doctorAppointments;

    function bookAppointment(uint _doctorId, uint _patientId, uint _timestamp) public payable {
        require(msg.value >= 0.01 ether, "Insufficient payment.");
        Appointment[] storage appointments = doctorAppointments[_doctorId];
        for (uint i = 0; i < appointments.length; i++) {
            require(_timestamp != appointments[i].timestamp, "Time slot already booked.");
        }
        appointments.push(Appointment(_doctorId, _patientId, _timestamp));
    }

    function getDoctorAppointments(uint _doctorId) public view returns (Appointment[] memory) {
        return doctorAppointments[_doctorId];
    }


    function registerNewDoctor(uint _doctorId, address _doctorAddress) public {
        registerDoctor(_doctorAddress);
    }

    function updatePatientVaccineStatus(uint _adminId, address _patientAddress, VaccineStatus _vaccineStatus) public {
        updatePatientData(_adminId, _patientAddress, _vaccineStatus, patients[_patientAddress].isDead);
    }

    function updatePatientDeathStatus(uint _adminId, address _patientAddress, bool _isDead) public {
        updatePatientData(_adminId, _patientAddress, patients[_patientAddress].vaccineStatus, _isDead);
    }
}

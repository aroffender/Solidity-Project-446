// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2 <0.9.0;


contract patientManagement {
    enum VaccineStatus { NotVaccinated, OneDose, TwoDose }

    struct User {
        uint id;
        address userAddress;
        string name;
        uint age;
        string gender;
        string district;
    }
    
    struct Patient {
        uint id;
        address userAddress;
        string symptomsDetails;
        VaccineStatus vaccineStatus;
        bool isDead;
    }
    
    struct Appointment {
        uint doctorid;
        uint patientid;
        uint timestamp;
        uint charge;
    }

    struct Transaction {
        uint doctorid;
        uint patientid;
        uint timestamp;
    }

    struct AppointmentDetails {
        uint doctorid;
        uint patientid;
        string dateTime; // need to make readable date and time
        uint charge;
    }
    
    struct AppointmentSlot {
        uint startTimestamp;
        uint endTimestamp;
        bool isBooked;
        uint patientid;
    }

    uint public userCount;
    uint private lastAppointmentTime;

    mapping(uint => address) public adminAddresses;
    mapping(uint => bool) public isAdmin;
    mapping(uint => address) public doctorAddresses;
    mapping(uint => bool) public isDoctor;
    mapping(address => User) public users;
    mapping(uint => Patient) public patients;
    mapping(uint => Appointment[]) public doctorAppointments;
    mapping(uint => AppointmentSlot[10]) public appointmentSlots;  // 10 slots for each doctor
    Transaction[] public transactions;

    constructor() {
        adminAddresses[1] = msg.sender;
        isAdmin[1] = true;
        lastAppointmentTime = block.timestamp; // Initialize last appointment time to current block timestamp

        // Initialize appointment slots
        for (uint i = 0; i < 10; i++) {
            uint startTimestamp = lastAppointmentTime + (i * 10 minutes);
            appointmentSlots[1][i] = AppointmentSlot(startTimestamp, startTimestamp + 10 minutes, false, 0);
        }
    }

    modifier onlyAdmin(uint adminid) {
        require(adminAddresses[adminid] == msg.sender, "Only admin can perform this action.");
        require(isAdmin[adminid], "Invalid admin ID.");
        _;
    }

    function registerAdmin(uint masteradminid, uint adminid) public {
        require(masteradminid == 21301302, "Only the master admin can register new admins.");
        isAdmin[adminid] = true;
        adminAddresses[adminid] = msg.sender;
    }
    
    function registerPatients(uint patientid, string memory _name, uint _age, string memory _gender, string memory _district, string memory _symptomsDetails) public {
        userCount++;
        users[msg.sender] = User(userCount, msg.sender, _name, _age, _gender, _district);
        patients[patientid] = Patient(patientid, msg.sender, _symptomsDetails, VaccineStatus.NotVaccinated, false);
    }

    function registerDoctor(uint adminid, uint doctorid) public onlyAdmin(adminid) {
        isDoctor[doctorid] = true;
        doctorAddresses[doctorid] = msg.sender;
        users[msg.sender] = User(userCount, msg.sender, "", 0, "", "");
        
        // 10 for each
        for (uint i = 0; i < 10; i++) {
            uint startTimestamp = lastAppointmentTime + (i * 10 minutes);
            appointmentSlots[doctorid][i] = AppointmentSlot(startTimestamp, startTimestamp + 10 minutes, false, 0);
        }
    }

    function updatePatientData(uint adminid, uint patientid, VaccineStatus _vaccineStatus, bool _isDead) public onlyAdmin(adminid) {
        Patient storage patient = patients[patientid];
        require(!patient.isDead, "Cannot update data of deceased patient.");
        patient.vaccineStatus = _vaccineStatus;
        patient.isDead = _isDead;
    }

    function getVaccineStatusString(VaccineStatus _vaccineStatus) internal pure returns (string memory) {
        if (_vaccineStatus == VaccineStatus.NotVaccinated) return "NotVaccinated";
        if (_vaccineStatus == VaccineStatus.OneDose) return "OneDose";
        if (_vaccineStatus == VaccineStatus.TwoDose) return "TwoDose";
        return "";
    }

    function getReadableDateTime(uint timestamp) internal pure returns (string memory) {
        uint day = timestamp / (60 * 60 * 24);
        uint hour = (timestamp / 60 / 60) % 24;
        uint minute = (timestamp / 60) % 60;
        return string(abi.encodePacked("Day ", uintToString(day), " ", uintToString(hour), ":", uintToString(minute)));
    }

    function uintToString(uint v) internal pure returns (string memory) {
        if (v == 0) {
            return "0";
        }
        uint maxLength = 10;
        bytes memory reversed = new bytes(maxLength);
        uint len = 0;
        while (v != 0) {
            uint remainder = v % 10;
            v = v / 10;
            reversed[len++] = bytes1(uint8(48 + remainder));
        }
        bytes memory s = new bytes(len);
        for (uint i = 0; i < len; i++) {
            s[i] = reversed[len - 1 - i];
        }
        return string(s);
    }

    function getAvailableSlots(uint doctorid) public view returns (string memory) {
        string memory slots;
        for (uint i = 0; i < 10; i++) {
            AppointmentSlot storage slot = appointmentSlots[doctorid][i];
            string memory slotDetails = string(abi.encodePacked(
                "Slot ", uintToString(i + 1), ": ",
                getReadableDateTime(slot.startTimestamp), " - ",
                getReadableDateTime(slot.endTimestamp), ", Booked: ",
                slot.isBooked ? "Yes" : "No", ", PatientID: ",
                uintToString(slot.patientid), "; "
            ));
            slots = string(abi.encodePacked(slots, slotDetails));
        }
        return slots;
    }

    function bookAppointment(uint doctorid, uint slotIndex, uint patientid, uint _charge) public payable {
        require(_charge >= 5, "Minimum charge for an appointment is 5 units.");
        require(isDoctor[doctorid], "Invalid doctor ID.");
        require(slotIndex < 10, "Invalid slot index.");

        AppointmentSlot storage slot = appointmentSlots[doctorid][slotIndex];
        require(!slot.isBooked, "Slot is already booked.");

        slot.isBooked = true;
        slot.patientid = patientid;

        doctorAppointments[doctorid].push(Appointment(doctorid, patientid, slot.startTimestamp, _charge));

        transactions.push(Transaction(doctorid, patientid, slot.startTimestamp));
    }

    function getAppointments(uint doctorid) public view returns (string memory) {
        string memory appointments;
        for (uint i = 0; i < doctorAppointments[doctorid].length; i++) {
            Appointment storage appointment = doctorAppointments[doctorid][i];
            string memory appointmentDetails = string(abi.encodePacked(
                "DoctorID: ", uintToString(appointment.doctorid), 
                ", PatientID: ", uintToString(appointment.patientid), 
                ", DateTime: ", getReadableDateTime(appointment.timestamp), 
                ", Charge: ", uintToString(appointment.charge), "; "
            ));
            appointments = string(abi.encodePacked(appointments, appointmentDetails));
        }
        return appointments;
    }

    function getPatientDetails(uint patientid) public view returns (string memory) {
        Patient storage patient = patients[patientid];
        User storage user = users[patient.userAddress];
        string memory patientDetails = string(abi.encodePacked(
            "ID: ", uintToString(patient.id),
            ", Name: ", user.name,
            ", Age: ", uintToString(user.age),
            ", Gender: ", user.gender,
            ", District: ", user.district,
            ", Symptoms: ", patient.symptomsDetails,
            ", Vaccine Status: ", getVaccineStatusString(patient.vaccineStatus),
            ", Deceased: ", patient.isDead ? "Yes" : "No"
        ));
        return patientDetails;
    }
}

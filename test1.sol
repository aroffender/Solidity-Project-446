
pragma solidity ^0.8.0;

contract CovidPatientManagement {
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
        // Initialize with the first admin who deploys the contract
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
        require(masteradminid == 21301302, "Only the master admin with ID 21301302 can register new admins.");
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
        
        // Initialize appointment slots for this doctor
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

    function getpatient(uint patientid) public view returns (uint, address, string memory, string memory, bool) {
        Patient storage patient = patients[patientid];
        string memory vaccineStatusStr = getVaccineStatusString(patient.vaccineStatus);
        return (patient.id, patient.userAddress, patient.symptomsDetails, vaccineStatusStr, patient.isDead);
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

    function getAvailableSlots(uint doctorid) public view returns (AppointmentSlot[10] memory) {
        return appointmentSlots[doctorid];
    }

    function getAppointments(uint doctorid) public view returns (AppointmentDetails[] memory) {
        uint length = doctorAppointments[doctorid].length;
        AppointmentDetails[] memory appointments = new AppointmentDetails[](length);
        for (uint i = 0; i < length; i++) {
            Appointment storage appointment = doctorAppointments[doctorid][i];
            appointments[i] = AppointmentDetails(
                appointment.doctorid,
                appointment.patientid,
                appointment.timestamp,
                appointment.charge
            );
        }
        return appointments;
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract CovidPatientManagement {
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
        // Initialize with the first admin who deploys the contract
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
        require(masteradminid == 21301302, "Only the master admin with ID 21301302 can register new admins.");
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
        
        // Initialize appointment slots for this doctor
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

    function getpatient(uint patientid) public view returns (uint, address, string memory, string memory, bool) {
        Patient storage patient = patients[patientid];
        string memory vaccineStatusStr = getVaccineStatusString(patient.vaccineStatus);
        return (patient.id, patient.userAddress, patient.symptomsDetails, vaccineStatusStr, patient.isDead);
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

    function getAvailableSlots(uint doctorid) public view returns (AppointmentSlot[10] memory) {
        return appointmentSlots[doctorid];
    }

    function getAppointments(uint doctorid) public view returns (AppointmentDetails[] memory) {
        uint length = doctorAppointments[doctorid].length;
        AppointmentDetails[] memory appointments = new AppointmentDetails[](length);
        for (uint i = 0; i < length; i++) {
            Appointment storage appointment = doctorAppointments[doctorid][i];
            appointments[i] = AppointmentDetails(
                appointment.doctorid,
                appointment.patientid,
                appointment.timestamp,
                appointment.charge
            );
        }
        return appointments;
    }
}

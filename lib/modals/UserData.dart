class UserData {
  final String userID;
  final String profileImageName;
  final String designation;
  final String name;
  final String email;
  final String phoneNumber;
  final String workMode;
  final String role;
  final int empId;
  final String dob;
  final String pan;
  final String bankName;
  final String aadhar;
  final String accNo;
  final String ifscCode;
  final String joiningDate;
  final String houseRentAllowance;
  final String basicSalary;
  final String paconveyanceAllowancen;
  final String dearnessAllowance;
  final String medicalAllowance;
  final String otherAllowance;
  final String pf;
  final String esi;
  final List<Map<String, dynamic>> attendanceLogs;

  UserData({
    required this.userID,
    required this.profileImageName,
    required this.designation,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.workMode,
    required this.role,
    required this.attendanceLogs,
    required this.empId,
    required this.dob,
    required this.pan,
    required this.bankName,
    required this.aadhar,
    required this.accNo,
    required this.ifscCode,
    required this.joiningDate,
    required this.houseRentAllowance,
    required this.basicSalary,
    required this.paconveyanceAllowancen,
    required this.dearnessAllowance,
    required this.medicalAllowance,
    required this.otherAllowance,
    required this.pf,
    required this.esi,
  });

  factory UserData.fromMap(Map<String, dynamic> map) {
    return UserData(
      userID: map['userID'] ?? '',
      profileImageName: map['profileImageName'] ?? '',
      designation: map['designation'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phoneNumber: map['phone'] ?? '',
      workMode: map['work_mode'] ?? '',
      role: map['role'] ?? '',
      empId: map['empId'] ?? 0,
      dob: map['dob'] ?? '',
      pan: map['pan'] ?? '',
      bankName: map['bankName'] ?? '',
      aadhar: map['aadhar'] ?? '',
      accNo: map['accNo'] ?? '',
      ifscCode: map['ifscCode'] ?? '',
      joiningDate: map['joiningDate'] ?? '',
      houseRentAllowance: map['houseRentAllowance'] ?? '',
      basicSalary: map['basicSalary'] ?? '',
      paconveyanceAllowancen: map['paconveyanceAllowancen'] ?? '',
      dearnessAllowance: map['dearnessAllowance'] ?? '',
      medicalAllowance: map['medicalAllowance'] ?? '',
      otherAllowance: map['otherAllowance'] ?? '',
      pf: map['pf'] ?? '',
      esi: map['esi'] ?? '',
      attendanceLogs: List<Map<String, dynamic>>.from(map['attendanceLogs'] ?? []),
    );
  }
}

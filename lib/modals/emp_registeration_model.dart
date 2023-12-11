class EmpRegistrationModel {

  String empId = '';
  String name = '';
  String phone = '';
  String email = '';
  String designation = '';
  String workMode = '';
  String dob = '';
  String pan = '';
  String aadhar = '';
  String bankName = '';
  String accNo = '';
  String ifscCode = '';
  String joiningDate = '';
  String basicSalary = '';
  String houseRentAllowance = '';
  String conveyanceAllowance = '';
  String dearnessAllowance = '';
  String medicalAllowance = '';
  String otherAllowance = '';
  String pf = '';
  String esi = '';

  Map<String, dynamic> toJson() {
    return {
      'empId': empId,
      'name': name,
      'phone': phone,
      'email': email,
      'dob': dob,
      'workMode': workMode,
      'pan': pan,
      'aadhar': aadhar,
      'bankName': bankName,
      'accNo': accNo,
      'ifscCode': ifscCode,
      'joiningDate': joiningDate,
      'designation': designation,
      'basicSalary': basicSalary,
      'houseRentAllowance': houseRentAllowance,
      'conveyanceAllowance': conveyanceAllowance,
      'dearnessAllowance': dearnessAllowance,
      'medicalAllowance': medicalAllowance,
      'otherAllowance': otherAllowance,
      'pf': pf,
      'esi': esi,
    };
  }
}


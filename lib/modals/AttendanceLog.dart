
class AttendanceLog {
  late String checkInTime;
  late String checkOutTime;
  late bool isLeave;
  late String status;
  late String workingHours;

  AttendanceLog({
    required this.checkInTime,
    required this.checkOutTime,
    required this.isLeave,
    required this.status,
    required this.workingHours,
  });

  Map<String, dynamic> toJson() {
    return {
      'checkInTime': checkInTime,
      'checkOutTime': checkOutTime,
      'isLeave': isLeave,
      'status': status,
      'workingHours': workingHours,
    };
  }
}

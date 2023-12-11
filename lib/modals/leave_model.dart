// Hive model representing the leave data
class Leave {
  int leaveId;
  String pathId;
  String user;
  String userPhone;
  String date;
  bool approved;
  bool rejected;
  bool isLeave;
  String month;
  String year;
  String status;

  Leave({
    required this.leaveId,
    required this.pathId,
    required this.user,
    required this.userPhone,
    required this.date,
    required this.approved,
    required this.rejected,
    required this.isLeave,
    required this.month,
    required this.year,
    required this.status,
  });

  factory Leave.fromJson(Map<String, dynamic> json) {
    return Leave(
      pathId: json['id'] ?? '',
      leaveId: json['id'] ?? '',
      user: json['user'] ?? '',
      userPhone: json['userPhone'] ?? '',
      date: json['date'] ?? '',
      approved: json['approved'] ?? false,
      rejected: json['rejected'] ?? false,
      isLeave: json['isLeave'] ?? false,
      month: json['month'] ?? '',
      year: json['year'] ?? '',
      status: json['status'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pathId': pathId,
      'leaveId': leaveId,
      'user': user,
      'userPhone': userPhone,
      'date': date,
      'approved': approved,
      'rejected': rejected,
      'isLeave': isLeave,
      'month': month,
      'year': year,
      'status': status,
    };
  }
}

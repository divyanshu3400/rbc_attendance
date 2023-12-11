import 'package:uuid/uuid.dart';

class AttendanceUserData {
  String year;
  YearData yearData;

  AttendanceUserData({
    required this.year,
    required this.yearData,
  });

  factory AttendanceUserData.fromJson(Map<String, dynamic> json) {
    return AttendanceUserData(
      year: json['year'] ?? '',
      yearData: YearData.fromJson(json['year_data'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'year': year,
      'year_data': yearData.toJson(),
    };
  }
}

class YearData {
  String month;
  MonthData monthData;

  YearData({
    required this.month,
    required this.monthData,
  });

  factory YearData.fromJson(Map<String, dynamic> json) {
    return YearData(
      month: json['month'] ?? '',
      monthData: MonthData.fromJson(json['month_data'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'month': month,
      'month_data': monthData.toJson(),
    };
  }
}

class MonthData {
  String leaveId;
  String leaveDate;
  String checkInTime;
  String checkOutTime;
  bool isLeave;
  bool approved;
  String status;
  String workingHours;

  MonthData({
    required this.leaveId,
    required this.leaveDate,
    required this.checkInTime,
    required this.checkOutTime,
    required this.isLeave,
    required this.status,
    required this.workingHours,
    required this.approved,
  });

  factory MonthData.fromJson(Map<String, dynamic> json) {
    return MonthData(
      leaveId: json['leave_id'] ?? Uuid().v4(),
      leaveDate: json['leave_date'] ?? '',
      checkInTime: json['checkInTime'] ?? '',
      checkOutTime: json['checkOutTime'] ?? '',
      isLeave: json['isLeave'] ?? true,
      approved : json['approved'] ?? false,
      status: json['status'] ?? '',
      workingHours: json['workingHours'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'leave_id': leaveId,
      'leave_date': leaveDate,
      'checkInTime': checkInTime,
      'checkOutTime': checkOutTime,
      'isLeave': isLeave,
      'status': status,
      'workingHours': workingHours,
    };
  }
}

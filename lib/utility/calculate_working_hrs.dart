import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../home_page.dart';

class CalculateWorkingHrs{

  static   String calculateHoursFromMilliseconds(
      int checkInMilliseconds, int checkOutMilliseconds) {
    DateTime checkInTime =
    DateTime.fromMillisecondsSinceEpoch(checkInMilliseconds);
    DateTime checkOutTime =
    DateTime.fromMillisecondsSinceEpoch(checkOutMilliseconds);
    Duration difference = checkOutTime.difference(checkInTime);
    int totalHours = difference.inHours;
    int remainingMinutes = (difference.inMinutes - (totalHours * 60)).abs();
    return '$totalHours Hrs: $remainingMinutes Min';
  }

  static   Future<void> saveAttendanceLog({
    int? checkInTime,
    int? checkOutTime,
    required bool isCheckIn,
    required String phoneNumber,
    required BuildContext context,
    required attendanceImage,
  }) async {
    CollectionReference userCollection =
    FirebaseFirestore.instance.collection('users');
    DocumentReference userDocRef = userCollection.doc(phoneNumber);
    Map<String, dynamic> newAttendanceLog = {
      'isCheckIn': isCheckIn,
      'checkOutTime': checkOutTime,
      'checkInTime': checkInTime,
      'checkin-image':attendanceImage
    };
    DocumentSnapshot userDoc =
    await FirebaseFirestore.instance.collection('users').doc(phoneNumber).get();
    if (userDoc.exists) {
      List<dynamic> currentLogs = List.from(userDoc['attendanceLogs']);
      if (currentLogs.isNotEmpty) {
        currentLogs.removeLast(); // Remove the last log
      }
      currentLogs.add(newAttendanceLog);
      userDocRef.update({'attendanceLogs': currentLogs}).then((_) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }).catchError((error) {
        throw('Error updating attendance logs: $error');
      });
    } else {
      throw('Document does not exist');
    }
  }
}
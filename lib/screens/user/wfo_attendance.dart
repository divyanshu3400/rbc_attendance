import 'dart:math';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:rbc_atted/home_page.dart';
import 'package:rbc_atted/utility/calculate_working_hrs.dart';
import 'package:rbc_atted/utility/show_toast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../utility/Constants.dart';
import '../../utility/shared_preference.dart';

class WFOMarkAttendanceScreen extends StatefulWidget {
  const WFOMarkAttendanceScreen({Key? key}) : super(key: key);

  @override
  MarkAttendanceScreenState createState() => MarkAttendanceScreenState();
}

class MarkAttendanceScreenState extends State<WFOMarkAttendanceScreen> {
  String barcodeResult = 'No scan yet';
  final DatabaseReference _attendanceReference =
      FirebaseDatabase.instance.ref('attendance');
  late SharedPreferences prefs;
  late MySharedPreference myPrefs;
  late Map<String, dynamic>? value;

  late String phoneNumber;
  Random random = Random();

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Navigate to HomeScreen on back button press
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
        return false; // Return false to prevent default back navigation
      },
      child: Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              'assets/images/background_image.jpg',
              fit: BoxFit.cover,
            ),
            // Gradient overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF091E3E).withOpacity(1),
                    // Adjust opacity as needed
                    Colors.transparent,
                    Colors.transparent,
                    const Color(0xFF091E3E).withOpacity(1),
                    // Adjust opacity as needed
                  ],
                ),
              ),
            ),
            const Center(
              child: Text(
                'Scanning...',
                style: TextStyle(fontSize: 18.0, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> fetchData() async {
    try {
      prefs = await SharedPreferences.getInstance();
      myPrefs = MySharedPreference(prefs);
      value = await myPrefs.getUserData(MyConstants.userPhone);
      phoneNumber = value?['phone'];
      String barcode = await FlutterBarcodeScanner.scanBarcode(
        '#ff6666',
        'Cancel',
        true,
        ScanMode.QR,
      );
      if (barcode ==
          "Risebeyond Consultancy | 0123456789abcdefghij0123456789") {
        DateTime currentTime = DateTime.now();
        int timeInMilli = currentTime.millisecondsSinceEpoch;
        int? checkInTimeM;
        int? checkOutTimeM;
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(phoneNumber)
            .get();
        if (userDoc.exists) {
          List<dynamic> attendanceLogs = userDoc['attendanceLogs'];
          Map<String, dynamic> latestLog = attendanceLogs.last;
          bool isCheckIn = latestLog['isCheckIn'];
          if (isCheckIn) {
            isCheckIn = false;
            checkOutTimeM = timeInMilli;
          } else {
            isCheckIn = true;
            checkInTimeM = timeInMilli;
          }
          if (checkOutTimeM != null && latestLog['checkInTime'] != null) {
            String workingHours =
                CalculateWorkingHrs.calculateHoursFromMilliseconds(
                    latestLog['checkInTime'], checkOutTimeM);
            DateTime checkInTime =
                DateTime.fromMillisecondsSinceEpoch(latestLog['checkInTime']);
            DateTime checkOutTime =
                DateTime.fromMillisecondsSinceEpoch(checkOutTimeM);
            String formattedYear = DateFormat('yyyy').format(checkInTime);
            String formattedMonth = DateFormat('MMMM').format(checkInTime);
            String formattedDate = DateFormat('yyyy-MM-dd').format(checkInTime);
            Map<String, dynamic> attendanceLogs = {
              'id': random.nextInt(10000) + 1,
              'checkInTime': checkInTime.toString(),
              'date': formattedDate.toString(),
              'checkOutTime': checkOutTime.toString(),
              'isLeave': false,
              'month': formattedMonth.toString(),
              'year': formattedYear.toString(),
              'status': 'present',
              'workingHours': workingHours,
            };

            try {
              await _attendanceReference
                  .child(phoneNumber)
                  .child('month_data')
                  .push()
                  .set(attendanceLogs);
            } catch (e) {
              setState(() {
                ShowToast.showToast(
                    context, "Error storing leave data for $formattedDate: $e");
              });
              throw ('Error storing leave data for $formattedDate: $e');
            }

            setState(() {
              ShowToast.showToast(context, "checked-Out");
              CalculateWorkingHrs.saveAttendanceLog(
                  checkInTime: latestLog['checkInTime'],
                  checkOutTime: checkOutTimeM,
                  isCheckIn: isCheckIn,
                  phoneNumber: phoneNumber,
                  context: context,
                  attendanceImage: "");
            });
          } else {
            setState(() {
              ShowToast.showToast(context, "checked-In");
              CalculateWorkingHrs.saveAttendanceLog(
                  checkInTime: checkInTimeM,
                  checkOutTime: 0,
                  isCheckIn: isCheckIn,
                  phoneNumber: phoneNumber,
                  context: context,
                  attendanceImage: "");
            });
          }
        } else {
          setState(() {
            ShowToast.showToast(context, "checked-Out");
          });
          // Handle the scenario accordingly
        }
      } else {
        setState(() {
          _showProfileNotFoundErrorDialog(context);
        });
      }
    } catch (e) {
      // Handle exception/error if any
      printMessage(e.toString());
    }
  }

  printMessage(Object msg) {
    debugPrint(msg as String?);
  }

  void _showProfileNotFoundErrorDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Barcode Error'),
          content: const Text('Wrong bar code detected!'),
          actions: <Widget>[
            TextButton(
              child: const Text('Okay'),
              onPressed: () {
                Navigator.pop(context); // This will close the app
              },
            ),
          ],
        );
      },
    );
  }
}

import 'dart:io';
import 'dart:math';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image/image.dart' as img;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rbc_atted/utility/calculate_working_hrs.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../utility/Constants.dart';
import '../../utility/shared_preference.dart';
import '../../utility/show_toast.dart';

class WFHMarkAttendanceScreen extends StatefulWidget {
  const WFHMarkAttendanceScreen({super.key});

  @override
  AttendanceScreenState createState() => AttendanceScreenState();
}

class AttendanceScreenState extends State<WFHMarkAttendanceScreen> {
  final ImagePicker _picker = ImagePicker();
  final DatabaseReference _attendanceReference =
      FirebaseDatabase.instance.ref('attendance');
  late SharedPreferences prefs;
  late MySharedPreference myPrefs;
  late Map<String, dynamic>? value;
  bool _isLoading = false;


  late String phoneNumber;
  Random random = Random();
  XFile? _imageFile;
  Future<void> _captureImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _imageFile = pickedFile;
      });
    }
  }

  Future<void> _markAttendance() async {
    prefs = await SharedPreferences.getInstance();
    myPrefs = MySharedPreference(prefs);
    value = await myPrefs.getUserData(MyConstants.userPhone);
    phoneNumber = value?['phone'];
    final String fileName =
        '$phoneNumber-${DateTime.now().millisecondsSinceEpoch}.png';
    final File image = File(_imageFile!.path);
    final bytes = await image.readAsBytes();
    img.Image originalImage = img.decodeImage(bytes)!;
    img.Image resizedImage = img.copyResize(originalImage, width: 500);
    final tempDir = await getTemporaryDirectory();
    final resizedFile = File('${tempDir.path}/$fileName')
      ..writeAsBytesSync(img.encodePng(resizedImage));
    final ref = FirebaseStorage.instance.ref().child('attendance_images').child(fileName);
    await ref.putFile(resizedFile);
    final imageUrl = await ref.getDownloadURL();
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
          _isLoading = false;
          ShowToast.showToast(context, "checked-Out");
          CalculateWorkingHrs.saveAttendanceLog(
              checkInTime: latestLog['checkInTime'],
              checkOutTime: checkOutTimeM,
              isCheckIn: isCheckIn,
              phoneNumber: phoneNumber,
              context: context,
              attendanceImage: imageUrl);
        });
      } else {
        setState(() {
          _isLoading = false;
          ShowToast.showToast(context, "checked-In");
          CalculateWorkingHrs.saveAttendanceLog(
              checkInTime: checkInTimeM,
              checkOutTime: 0,
              isCheckIn: isCheckIn,
              phoneNumber: phoneNumber,
              context: context,
              attendanceImage: imageUrl);
        });
      }
    } else {
      setState(() {
        ShowToast.showToast(context, "checked-Out");
      });
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/background_image.jpg',
            fit: BoxFit.cover,
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF091E3E).withOpacity(1),
                  Colors.transparent,
                  Colors.transparent,
                  const Color(0xFF091E3E).withOpacity(1),
                ],
              ),
            ),
          ),

          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                _imageFile == null
                    ? const Text('No image Captured.', style: TextStyle(color: Colors.white),)
                    : Image.file(
                  File(_imageFile!.path),
                  height: 300.0,
                  width: 200.0,
                ),
                const SizedBox(height: 20.0),
                ElevatedButton(
                  onPressed: _captureImage,
                  child: const Text('Capture Image'),
                ),
                const SizedBox(height: 20.0),
                ElevatedButton(
                  onPressed: () {
                    if(_imageFile != null){
                      _isLoading = true;
                      _markAttendance();
                    }else{_isLoading == false;
                    ShowToast.showToast(context,"Please Capture Image");}

                  },

                  child: _isLoading ? const CircularProgressIndicator() : const Text('Mark Attendance'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

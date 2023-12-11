import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import 'package:rbc_atted/utility/show_toast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../home_page.dart';
import '../../utility/Constants.dart';
import '../../utility/shared_preference.dart';

class ApplyLeave extends StatefulWidget {
  const ApplyLeave({Key? key}) : super(key: key);

  @override
  ApplyLeaveState createState() => ApplyLeaveState();
}

class ApplyLeaveState extends State<ApplyLeave> {
  Random random = Random();
  final List<String> leaveTypes = ['EL(Earned Leave)', 'CL(Casual Leave)'];
  String selectedLeaveType = 'EL(Earned Leave)';
  DateTime? selectedStartDate;
  DateTime? selectedEndDate;
  final DatabaseReference _attendanceReference =
  FirebaseDatabase.instance.ref('attendance');
  FirebaseAuth auth = FirebaseAuth.instance;
  String? userID;
  bool isLoading = false;
  late SharedPreferences prefs;
  late MySharedPreference myPrefs;
  late Map<String, dynamic>? value;
  late String userName;
  late String phoneNumber;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      FirebaseAuth auth = FirebaseAuth.instance;
      User? user = auth.currentUser;
      userID = user?.uid;
    } catch (e) {
      e.toString();
    }
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    DateTime? initialDate = DateTime.now();
    if (!isStartDate && selectedStartDate != null) {
      initialDate =
          selectedStartDate; // Set initialDate to selectedStartDate for end date selection
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate!,
      firstDate:
      isStartDate ? DateTime.now() : selectedStartDate ?? DateTime.now(),
      lastDate:
      DateTime.now().add(const Duration(days: 365)), // One year from now
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          selectedStartDate = picked;
          if (selectedEndDate != null && picked.isAfter(selectedEndDate!)) {
            selectedEndDate =
            null; // Reset end date if it's before the new start date
          }
        } else {
          User? user = auth.currentUser;
          userID = user?.uid;
          selectedEndDate = picked;
        }
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
              // Replace with your image path
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
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      margin: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                      child: const Text(
                        "Select Leave Type",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                    Container(
                      constraints: const BoxConstraints(maxWidth: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      child: DropdownButtonFormField<String>(
                        value: selectedLeaveType,
                        items: leaveTypes.map((String leaveType) {
                          return DropdownMenuItem<String>(
                            value: leaveType,
                            child: Text(leaveType),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setState(() {
                              selectedLeaveType = newValue;
                            });
                          }
                        },
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      margin: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                      child: const Text(
                        "Select Start Date",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.all(16),
                      child: TextFormField(
                        readOnly: true,
                        onTap: () => _selectDate(context, true),
                        decoration: const InputDecoration(
                          labelText: 'Start Date',
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.white,
                          suffixIcon: Icon(Icons.calendar_month_outlined),
                        ),
                        controller: TextEditingController(
                          text: selectedStartDate != null
                              ? selectedStartDate!
                              .toLocal()
                              .toString()
                              .split(' ')[0]
                              : '',
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      margin: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                      child: const Text(
                        "Select End Date",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.all(16),
                      child: TextFormField(
                        readOnly: true,
                        onTap: () => _selectDate(context, false),
                        decoration: const InputDecoration(
                          labelText: 'End Date',
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.white,
                          suffixIcon: Icon(Icons.calendar_month_outlined),
                        ),
                        controller: TextEditingController(
                          text: selectedEndDate != null
                              ? selectedEndDate!.toLocal().toString().split(
                              ' ')[0]
                              : '',
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () async {
                        if(selectedStartDate != null && selectedEndDate != null){
                          setState(() {
                            isLoading = true;
                          });
                          prefs = await SharedPreferences.getInstance();
                          myPrefs = MySharedPreference(prefs);
                          value = await myPrefs.getUserData(MyConstants.userPhone);
                          Map<String, dynamic>? userData = await myPrefs.getUserData(MyConstants.userName);
                          phoneNumber = value?['phone'];
                          userName = userData?['name'];
                          await storeLeaveDataForDateRange(
                              phoneNumber: phoneNumber,
                              selectedLeaveType: selectedLeaveType,
                              selectedStartDate: selectedStartDate!,
                              selectedEndDate: selectedEndDate);
                          setState(() {
                            ShowToast.showToast(
                                context, "Leave Applied Successfully");
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                  builder: (_) => const HomeScreen()),
                            );
                          });
                        }
                      },
                      child: isLoading
                          ? const CircularProgressIndicator()
                          : const Text('Apply Leave'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ));
  }

// Define your method to store leave data
  Future<void> storeLeaveDataForDateRange(
      {required String phoneNumber, required String selectedLeaveType, required DateTime selectedStartDate, DateTime? selectedEndDate,}) async {
    for (DateTime date = selectedStartDate;
    date.isBefore(selectedEndDate!.add(const Duration(days: 1)));
    date = date.add(const Duration(days: 1))) {
      String formattedYear = DateFormat('yyyy').format(date);
      String formattedMonth = DateFormat('MMMM').format(date);
      String formattedDate = DateFormat('yyyy-MM-dd').format(date);

      Map<String, dynamic> leaveLogs = {
        'id':random.nextInt(10000) + 1,
        'year': formattedYear.toString(),
        'username':userName,
        'month': formattedMonth.toString(),
        'date': formattedDate.toString(),
        'approved': false,
        'rejected': false,
        'isLeave': true,
        'status': selectedLeaveType,
      };

      try {
        await _attendanceReference.child(phoneNumber).child('month_data')
            .push()
            .set(leaveLogs);
      } catch (e) {
        setState(() {
          isLoading = false;
          ShowToast.showToast(
              context, "Error storing leave data for $formattedDate: $e");
        });
        throw ('Error storing leave data for $formattedDate: $e');
      }
    }
  }
}

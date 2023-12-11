import 'dart:math';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rbc_atted/utility/formating.dart';
import 'package:rbc_atted/utility/show_toast.dart';
import '../../modals/leave_model.dart';
import '../../modals/total_employee_modal.dart';
import '../../utility/calculate_working_hrs.dart';
import '../../utility/custom_radio_tile.dart';
import '../../utility/dimens.dart';

class TodayAttendance extends StatefulWidget {
  const TodayAttendance({Key? key}) : super(key: key);

  @override
  TodayAttendanceState createState() => TodayAttendanceState();
}

enum FilterOption { notCheckedIn, checkedIn, onLeave }

class TodayAttendanceState extends State<TodayAttendance> {
  late Future<List<dynamic>> futureEmployees;
  bool isCheckedIn = false;
  bool isOnLeave = false;
  List<dynamic> tempLeaveRequests = [];

  FilterOption? selectedFilterOption = FilterOption.notCheckedIn;

  Future<List<dynamic>> fetchEmployeesFromFirestore() async {
    await fetchLeaveDataFromAnotherDatabase();
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('users').get();
    List<dynamic> employees = [];
    DateTime now = DateTime.now();
    DateTime currentDay7PM = DateTime(now.year, now.month, now.day, 19, 0, 0);
    DateTime nextDay4AM = DateTime(now.year, now.month, now.day + 1, 4, 0, 0);
    int currentDay7PMMillis = currentDay7PM.millisecondsSinceEpoch;
    int nextDay4AMMillis = nextDay4AM.millisecondsSinceEpoch;

    for (var doc in querySnapshot.docs) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      List<dynamic> attendanceLogs = data['attendanceLogs'];
      var log = attendanceLogs.last;
      var userCheckinTimeMillis = log['checkInTime'] as int;
      if (userCheckinTimeMillis >= currentDay7PMMillis &&
          userCheckinTimeMillis <= nextDay4AMMillis) {
        Employee employee = Employee(
            data['name'].toString(),
            data['designation'].toString(),
            data['email'].toString(),
            data['phone'].toString(),
            data['profileImageName'] ?? '',
            log['checkInTime'].toString(),
            log['checkOutTime'].toString(),
            true,
            true);
        employees.add(employee);
      }
      else if (userCheckinTimeMillis < currentDay7PMMillis ||
          userCheckinTimeMillis > nextDay4AMMillis) {
        Employee employee = Employee(
            data['name'].toString(),
            data['designation'].toString(),
            data['email'].toString(),
            data['phone'].toString(),
            data['profileImageName'] ?? '',
            log['checkInTime'].toString(),
            log['checkOutTime'].toString(),
            false,
            false);
        employees.add(employee);
      }
    }

    if (selectedFilterOption == FilterOption.checkedIn) {
      employees = employees.where((emp) => emp.isChecked).toList();
    } else if (selectedFilterOption == FilterOption.notCheckedIn) {
      employees = employees.where((emp) => !emp.isChecked).toList();
    } else if (selectedFilterOption == FilterOption.onLeave) {
      employees.clear();
      employees = tempLeaveRequests;
    }
    return employees;
  }

  Future<List<dynamic>> fetchLeaveDataFromAnotherDatabase() async {
    if (tempLeaveRequests.isNotEmpty) {
      tempLeaveRequests.clear();
    }
    await Future.delayed(const Duration(seconds: 2));
    DatabaseReference dbRef = FirebaseDatabase.instance.ref('attendance');
    dbRef.onValue.listen((DatabaseEvent event) {
      if (event.snapshot.value != null) {
        DateTime currentTime = DateTime.now();
        String formattedDate = DateFormat('yyyy-MM-dd').format(currentTime);
        Map<dynamic, dynamic>? data =
            event.snapshot.value as Map<dynamic, dynamic>?;
        data?.forEach((userPhone, userData) {
          if (userData is Map<Object?, Object?> &&
              userData.containsKey('month_data') &&
              userData['month_data'] is Map<Object?, Object?>) {
            Map<Object?, Object?> monthData =
                userData['month_data'] as Map<Object?, Object?>;
            monthData.forEach((pathId, leaveData) {
              if (leaveData is Map<Object?, Object?> &&
                  leaveData['isLeave'] == true &&
                  leaveData['approved'] == true &&
                  leaveData['date'] == formattedDate &&
                  leaveData['rejected'] == false) {
                Leave formattedLeave = Leave(
                  pathId: pathId.toString(),
                  leaveId: leaveData['id'] as int,
                  user: leaveData['username'].toString(),
                  userPhone: userPhone,
                  date: leaveData['date'].toString(),
                  approved: leaveData['approved'] as bool,
                  rejected: leaveData['rejected'] as bool,
                  isLeave: leaveData['isLeave'] as bool,
                  month: leaveData['month'].toString(),
                  year: leaveData['year'].toString(),
                  status: leaveData['status'].toString(),
                );
                tempLeaveRequests.add(formattedLeave);
              }
            });
          }
        });
      }
    });
    return tempLeaveRequests;
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomRadioListTile<FilterOption>(
                      value: FilterOption.notCheckedIn,
                      groupValue: selectedFilterOption,
                      onChanged: (FilterOption? value) {
                        setState(() {
                          selectedFilterOption = value!;
                        });
                      },
                      text: 'Not Checked-In',
                    ),
                    const SizedBox(
                      width: 4,
                    ),
                    CustomRadioListTile<FilterOption>(
                      value: FilterOption.checkedIn,
                      groupValue: selectedFilterOption,
                      onChanged: (FilterOption? value) {
                        setState(() {
                          selectedFilterOption = value!;
                        });
                      },
                      text: 'Checked-In',
                    ),
                    const SizedBox(
                      width: 4,
                    ),
                    CustomRadioListTile<FilterOption>(
                      value: FilterOption.onLeave,
                      groupValue: selectedFilterOption,
                      onChanged: (FilterOption? value) {
                        setState(() {
                          selectedFilterOption = value!;
                        });
                      },
                      text: 'On Leave',
                    ),
                  ],
                ),
              ),
              Expanded(
                child: FutureBuilder<List<dynamic>>(
                  future: fetchEmployeesFromFirestore(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(
                          child: Text(
                        'Error: ${snapshot.error}',
                        style: const TextStyle(color: Colors.white),
                      ));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(
                          child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white12,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              height: 180,
                              width: 300,
                              child: const Center(
                                child: Text('No data available',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w800)),
                              )));
                    } else {
                      return Builder(
                        builder: (BuildContext context) {
                          List<dynamic> dataList = snapshot.data!;

                          if (dataList.every((obj) => obj is Leave)) {
                            final employeesAttendance = snapshot.data;
                            return ListView.builder(
                              itemCount: employeesAttendance?.length,
                              itemBuilder: (context, index) {
                                return EmployeeLeaveTile(
                                    employee: employeesAttendance?[index]);
                              },
                            );
                          } else {
                            final employeesAttendance = dataList;
                            print("employeesAttendance   : $employeesAttendance");
                            return ListView.builder(
                              itemCount: employeesAttendance.length,
                              itemBuilder: (context, index) {
                                return EmployeeTile(
                                    employee: employeesAttendance[index]);
                              },
                            );
                          }
                        },
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class EmployeeTile extends StatelessWidget {
  final Employee employee;

  const EmployeeTile({Key? key, required this.employee}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white.withOpacity(0.4),
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: employee.profilePic.isNotEmpty
              ? NetworkImage(employee.profilePic) as ImageProvider<Object>?
              : const AssetImage("assets/images/person_icon.png"),
        ),
        title: Text(
          employee.name,
          style: const TextStyle(color: Colors.black, fontSize: 18),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              employee.isPresent
                  ? 'Check-in: ${DateFormat('yyyy-MM-dd hh:mm a').format(DateTime.fromMillisecondsSinceEpoch(int.parse(employee.checkInTime)))}'
                  : 'Not Checked-In yet',
              style: const TextStyle(color: Colors.white70),
            ),
            Text(
              employee.isPresent && employee.checkOutTime != "0"
                  ? 'Check-Out: ${DateFormat('yyyy-MM-dd hh:mm a').format(DateTime.fromMillisecondsSinceEpoch(int.parse(employee.checkOutTime)))}'
                  : '',
              style: const TextStyle(color: Colors.white70),
            ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward),
        onTap: () {
          if(!employee.isPresent) {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              barrierLabel: "Mark Attendance",
              backgroundColor: Colors.white.withOpacity(0.6),
              builder: (BuildContext context) {
                return SingleChildScrollView(
                  child: Container(
                    constraints: BoxConstraints(
                      minHeight: MediaQuery.of(context).size.height *
                          0.4, // Set your minimum height here
                    ),
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom,
                    ),
                    // Your content here
                    child:  Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Container(
                          margin: const EdgeInsets.all(20),
                          width: double.infinity,
                          decoration: const BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.all(Radius.circular(7)),
                          ),
                          child: Column(
                            children: [
                              const SizedBox(height: 20),
                              const Text(
                                'Profile Details ',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Container(
                                height: 1,
                                width: double.infinity,
                                color: Colors.white38,
                                margin:
                                const EdgeInsets.only(left: 8.0), // Adjust margin as needed
                              ),
                              const SizedBox(height: 20),
                              Row(
                                children: [
                                  const Flexible(
                                    flex: 4,
                                    child: Padding(
                                      padding: EdgeInsets.only(left: 20.0),
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          'Name  ->',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: Dimens.subheadingText,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    height: 20,
                                    width: 2,
                                    color: Colors.white38,
                                  ),
                                  Flexible(
                                    flex: 6,
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 20.0),
                                      // Adjust the padding as needed
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          employee.name,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: Dimens.normalText,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  const Flexible(
                                    flex: 4,
                                    child: Padding(
                                      padding: EdgeInsets.only(left: 20.0),
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          'Email  ->',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: Dimens.subheadingText,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    height: 20,
                                    width: 2,
                                    color: Colors.white38,
                                  ),
                                  Flexible(
                                    flex: 6,
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 20.0),
                                      // Adjust the padding as needed
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          employee.email,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: Dimens.normalText,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  const Flexible(
                                    flex: 4,
                                    child: Padding(
                                      padding: EdgeInsets.only(left: 20.0),
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          'Phone ->',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: Dimens.subheadingText,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    height: 20,
                                    width: 2,
                                    color: Colors.white38,
                                  ),
                                  Flexible(
                                    flex: 6,
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 20.0),
                                      // Adjust the padding as needed
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          "+91 ${Formatting.formatMobileNumber(employee.phone)}",
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: Dimens.normalText,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  const Flexible(
                                    flex: 4,
                                    child: Padding(
                                      padding: EdgeInsets.only(left: 20.0),
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          'Designation  ->',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: Dimens.subheadingText,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    height: 20,
                                    width: 2,
                                    color: Colors.white38,
                                  ),
                                  Flexible(
                                    flex: 6,
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 20.0),
                                      // Adjust the padding as needed
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          employee.designation,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: Dimens.normalText,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                        OutlinedButton(
                            onPressed: () async {
                              await markAttendance(employee, context);
                              Navigator.pop(context);
                              ShowToast.showToast(context, "Attendance Updated for ${employee.name}");
                            },
                            child: const Text("Update Attendance"))
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}

Future<void> markAttendance(Employee employee, BuildContext context) async {
  final DatabaseReference attendanceReference =
  FirebaseDatabase.instance.ref('attendance');
  DateTime now = DateTime.now();
  Random random = Random();
  DateTime currentDay7PM = DateTime(now.year, now.month, now.day, 19, 0, 0);
  DateTime nextDay4AM = DateTime(now.year, now.month, now.day + 1, 4, 0, 0);
  int currentDay7PMMillis = currentDay7PM.millisecondsSinceEpoch;
  int nextDay4AMMillis = nextDay4AM.millisecondsSinceEpoch;
  String workingHours = CalculateWorkingHrs.calculateHoursFromMilliseconds(
      currentDay7PMMillis, nextDay4AMMillis);
  String formattedYear = DateFormat('yyyy').format(currentDay7PM);
  String formattedMonth = DateFormat('MMMM').format(currentDay7PM);
  String formattedDate = DateFormat('yyyy-MM-dd').format(currentDay7PM);
  Map<String, dynamic> attendanceLogs = {
    'id': random.nextInt(10000) + 1,
    'checkInTime': currentDay7PM.toString(),
    'date': formattedDate.toString(),
    'checkOutTime': nextDay4AM.toString(),
    'isLeave': false,
    'month': formattedMonth.toString(),
    'year': formattedYear.toString(),
    'status': 'present',
    'workingHours': workingHours,
  };
  try {
    await attendanceReference
        .child(employee.phone)
        .child('month_data')
        .push()
        .set(attendanceLogs);
    await CalculateWorkingHrs.saveAttendanceLog(
        checkInTime:currentDay7PMMillis ,
        checkOutTime: nextDay4AMMillis,
        isCheckIn: false,
        phoneNumber: employee.phone,
        context: context,
        attendanceImage: "");
  } catch (e) {
    throw ('Error:  $formattedDate: $e');
  }
}

Widget showAttendanceDetailsSheet(BuildContext context, Employee employee) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: <Widget>[
      Text("Attendance Details"),
      // Add more widgets if needed
    ],
  );
}


class EmployeeLeaveTile extends StatelessWidget {
  final Leave employee;

  const EmployeeLeaveTile({Key? key, required this.employee}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white.withOpacity(0.4),
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundImage: AssetImage("assets/images/person_icon.png"),
        ),
        title: Text(
          employee.user,
          style: const TextStyle(color: Colors.black, fontSize: 18),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Phone: +91 ${Formatting.formatMobileNumber(employee.userPhone)}",
              style: const TextStyle(color: Colors.white70),
            ),
            Text(
              "On Leave :${Formatting.formatJoiningDate(employee.date)}",
              style: const TextStyle(color: Colors.white70),
            )
          ],
        ),
        trailing: const Icon(Icons.arrow_forward),
        onTap: () {
          showModalBottomSheet(
            context: context,
            builder: (BuildContext context) {
              // You can create a widget here to display detailed information
              return Container(
                // Design your bottom sheet content here
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    ListTile(
                      title: Text('Detail 1: ${employee.userPhone}'),
                      // Add more ListTile or widgets to display detailed info
                    ),
                    // Add more widgets if needed
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

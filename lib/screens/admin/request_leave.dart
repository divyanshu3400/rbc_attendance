import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:rbc_atted/utility/show_toast.dart';
import '../../modals/leave_model.dart';
import 'package:intl/intl.dart';
import '../../utility/custom_radio_button.dart';

class LeaveListScreen extends StatefulWidget {
  const LeaveListScreen({Key? key}) : super(key: key);

  @override
  LeaveListScreenState createState() => LeaveListScreenState();
}

class LeaveListScreenState extends State<LeaveListScreen> {
  List<Leave> leaveRequests = [];
  bool isApproved = false;
  bool isReject = false;
  bool _filteredValue = false;
  int? _tappedIndex;

  @override
  void initState() {
    super.initState();
    fetchUserLeavesData();
  }

  List<Leave> getFilteredLeaves(bool? filterValue) {
    if (filterValue == null) {
      return leaveRequests;
    } else {
      return leaveRequests
          .where((leave) => leave.approved == filterValue)
          .toList();
    }
  }

  Future<void> fetchUserLeavesData() async {
    DatabaseReference dbRef = FirebaseDatabase.instance.ref('attendance');
    dbRef.onValue.listen((DatabaseEvent event) {
      if (event.snapshot.value != null) {
        Map<dynamic, dynamic>? data =
            event.snapshot.value as Map<dynamic, dynamic>?;
        List<Leave> tempLeaveRequests = [];
        data?.forEach((userPhone, userData) {
          if (userData is Map<Object?, Object?> &&
              userData.containsKey('month_data') &&
              userData['month_data'] is Map<Object?, Object?>) {
            Map<Object?, Object?> monthData =
                userData['month_data'] as Map<Object?, Object?>;
            monthData.forEach((pathId, leaveData) {
              if (leaveData is Map<Object?, Object?> &&
                  leaveData['isLeave'] == true) {
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

        setState(() {
          leaveRequests = tempLeaveRequests;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Leave> filteredLeaves = getFilteredLeaves(_filteredValue);
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
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  CustomRadioButton(
                    value: false,
                    groupValue: _filteredValue,
                    onChanged: (value) {
                      setState(() {
                        _filteredValue = value!;
                      });
                    },
                    text: 'Pending',
                  ),

                  CustomRadioButton(
                    value: true,
                    groupValue: _filteredValue,
                    onChanged: (value) {
                      setState(() {
                        _filteredValue = value!;
                      });
                    },
                    text: 'Approved',
                  ),
                ],
              ),
              Expanded(
                child: filteredLeaves.isEmpty
                    ? const Center(child: Text('No Requests to display',style: TextStyle(color: Colors.white),))
                    : Container(
                        margin: const EdgeInsets.all(10),
                        child: ListView.builder(
                          itemCount: filteredLeaves.length,
                          itemBuilder: (BuildContext context, int index) {
                            Leave leave = filteredLeaves[index];
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _tappedIndex = _tappedIndex == index
                                      ? null
                                      : index; // Toggle tapped index
                                });
                              },
                              child: Container(
                                margin: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                                decoration: BoxDecoration(
                                  color: Colors.white12,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Column(
                                  children: [
                                    ListTile(
                                      title: Text(
                                        'Applied By: ${leave.user}',
                                        style: const TextStyle(
                                            color: Colors.white, fontSize: 15),
                                      ),
                                      subtitle: Text(
                                        'Applied For: ${(DateFormat.yMMMMd().format(DateTime.parse(leave.date))).toString()}',
                                        style: const TextStyle(
                                            color: Colors.white),
                                      ),
                                      trailing: Text(
                                        'Leave Type: ${leave.status}',
                                        style: const TextStyle(
                                            color: Colors.white),
                                      ),
                                    ),

                                    if (_tappedIndex == index)
                                      Column(children: [
                                        SizedBox(
                                          width: double.infinity, height: 1,
                                          child: Container(color: Colors.white70),
                                        ),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                          children: [
                                            Expanded(
                                              child: GestureDetector(
                                                onTap: () {
                                                  if(leave.approved && !leave.rejected)
                                                    {
                                                      setState(() {
                                                        ShowToast.showToast(context, "Approved Already");
                                                      });
                                                    }
                                                  else
                                                    {
                                                      setState(() {
                                                        isApproved = true;
                                                        approveLeave(leave);
                                                      });
                                                    }
                                                },
                                                child: Container(
                                                  decoration: const BoxDecoration(
                                                    color: Colors.white54,
                                                    borderRadius: BorderRadius.only(topLeft: Radius.zero,
                                                        topRight: Radius.zero,bottomLeft: Radius.circular(8),
                                                        bottomRight: Radius.zero),
                                                  ),
                                                  height: 40,
                                                  alignment: Alignment.center,

                                                  child: isApproved
                                                      ? const CircularProgressIndicator()
                                                      : Text(
                                                    leave.approved && !leave.rejected ? 'Approved' : 'Approve',
                                                    style: const TextStyle(color: Colors.black),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              child: GestureDetector(
                                                onTap: () {
                                                  if(leave.approved && leave.rejected)
                                                  {
                                                    setState(() {
                                                      ShowToast.showToast(context, "Rejected Already");
                                                    });
                                                  }
                                                  else
                                                  {
                                                    setState(() {
                                                      isApproved = true;
                                                      approveLeave(leave);
                                                    });
                                                  }
                                                  isReject =  true;
                                                  rejectLeave(leave);
                                                },
                                                child: Container(
                                                  decoration: const BoxDecoration(
                                                    color: Colors.black54,
                                                    borderRadius: BorderRadius.only(topLeft: Radius.zero,
                                                        topRight: Radius.zero,bottomLeft: Radius.zero,
                                                        bottomRight: Radius.circular(8)),
                                                  ),
                                                  height: 40,
                                                  alignment: Alignment.center,
                                                  child: isReject
                                                      ? const CircularProgressIndicator()
                                                      : Text(leave.approved && leave.rejected ?
                                                    'Rejected' : 'Reject',
                                                    style: const TextStyle(color: Colors.white),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),

                                      ],)
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void approveLeave(Leave leave) {
    DatabaseReference dbRef = FirebaseDatabase.instance.ref("attendance");
    String path =
        '/${leave.userPhone}/month_data/${leave.pathId}'; // Path to the specific data based on user ID and ID to update
    dbRef.child(path).update({
      'approved': true,
      'rejected': false,
    }).then((_) {
      setState(() {
        isApproved = false;
        ShowToast.showToast(context, "Leave Approved");
      });
    }).catchError((error) {
      setState(() {
        ShowToast.showToast(context, "Leave Approval Failed $error");
      });
    });
  }

  void rejectLeave(Leave leave) {
    DatabaseReference dbRef = FirebaseDatabase.instance.ref("attendance");
    String path =
        '/${leave.userPhone}/month_data/${leave.pathId}'; // Path to the specific data based on user ID and ID to update
    dbRef.child(path).update({
      'rejected': true,
      'approved': true,

    }).then((_) {
      setState(() {
        isReject = false;
        ShowToast.showToast(context, "Leave Rejected");
      });
    }).catchError((error) {
      setState(() {
        ShowToast.showToast(context, "Leave Rejection Failed $error");
      });
    });

  }
}


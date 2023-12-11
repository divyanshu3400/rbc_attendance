import 'package:flutter/material.dart';
import 'package:rbc_atted/utility/custome_calendar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../utility/Constants.dart';
import '../../utility/shared_preference.dart';

class ViewAttendance extends StatefulWidget {
  const ViewAttendance({Key? key}) : super(key: key);

  @override
  ViewAttendanceState createState() => ViewAttendanceState();
}

class ViewAttendanceState extends State<ViewAttendance>{
  late SharedPreferences prefs;
  late MySharedPreference myPrefs;
  late String phoneNumber;

  @override
  void initState() {
    super.initState();
    getPhoneNumber();
  }


  void getPhoneNumber() async {
    var prefs = await SharedPreferences.getInstance();
    var myPrefs = MySharedPreference(prefs);
    Map<String, dynamic>? value = await myPrefs.getUserData(MyConstants.userPhone);
    phoneNumber = value?['phone'];
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
              children: [
                const SizedBox(height: 10),
                const Text("Present", style: TextStyle(color: Colors.white),),
                Row(
                  children: [
                    Flexible(
                      flex: 5,
                      child: Container(
                        height: 30,
                        decoration: BoxDecoration(
                          color: Colors.white38,
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.circular(4)
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 15,vertical:5),
                        margin: const EdgeInsets.fromLTRB(20, 10, 5, 5),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Row(
                            children: [
                              Container(
                                width: 10,
                                height: 10,
                                decoration: const BoxDecoration(
                                  color: Colors.green,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 15),
                              // Add some space between the dot and text
                              const Text(
                                'Present (On-Time)',
                                style: TextStyle(color: Colors.black),
                              ),
                            ],
                          )
                        ),
                      ),
                    ),
                    Flexible(
                      flex: 5,
                      child: Container(
                        height: 30,
                        decoration: BoxDecoration(
                          color: Colors.white38,
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.circular(4)
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 15,vertical:5),
                        margin: const EdgeInsets.fromLTRB(5, 10, 20, 5),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Row(
                            children: [
                              Container(
                                width: 10,
                                height: 10,
                                decoration: const BoxDecoration(
                                  color: Colors.greenAccent,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 15),
                              // Add some space between the dot and text
                              const Text(
                                'Present (Late)',
                                style: TextStyle(color: Colors.black),
                              ),
                            ],
                          )
                        ),
                      ),
                    ),
                  ],
                ),
                const Text("Absent", style: TextStyle(color: Colors.white),),
                Row(
                  children: [
                    Flexible(
                      flex: 5,
                      child: Container(
                        height: 30,
                        decoration: BoxDecoration(
                          color: Colors.white38,
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.circular(4)
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 15,vertical:5),
                        margin: const EdgeInsets.fromLTRB(20, 10, 20, 5),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Row(
                            children: [
                              Container(
                                width: 10,
                                height: 10,
                                decoration: const BoxDecoration(
                                  color: Colors.redAccent,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 15),
                              // Add some space between the dot and text
                              const Text(
                                'Absent',
                                style: TextStyle(color: Colors.black),
                              ),
                            ],
                          )
                        ),
                      ),
                    ),
                  ],
                ),

                const Text("Leaves", style: TextStyle(color: Colors.white),),
                Row(
                  children: [
                    Flexible(
                      flex: 5,
                      child: Container(
                        height: 30,
                        decoration: BoxDecoration(
                            color: Colors.white38,
                            shape: BoxShape.rectangle,
                            borderRadius: BorderRadius.circular(4)
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 15,vertical:5),
                        margin: const EdgeInsets.fromLTRB(20, 10, 5, 5),
                        child: Align(
                            alignment: Alignment.centerLeft,
                            child: Row(
                              children: [
                                Container(
                                  width: 10,
                                  height: 10,
                                  decoration: const BoxDecoration(
                                    color: Colors.yellow,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 15),
                                // Add some space between the dot and text
                                const Text(
                                  'EL (Earned Leaves)',
                                  style: TextStyle(color: Colors.black),
                                ),
                              ],
                            )
                        ),
                      ),
                    ),
                    Flexible(
                      flex: 5,
                      child: Container(
                        height: 30,
                        decoration: BoxDecoration(
                            color: Colors.white38,
                            shape: BoxShape.rectangle,
                            borderRadius: BorderRadius.circular(4)
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 15,vertical:5),
                        margin: const EdgeInsets.fromLTRB(5, 10, 20, 5),
                        child: Align(
                            alignment: Alignment.centerLeft,
                            child: Row(
                              children: [
                                Container(
                                  width: 10,
                                  height: 10,
                                  decoration: const BoxDecoration(
                                    color: Colors.orange,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 15),
                                // Add some space between the dot and text
                                const Text(
                                  'CL (Casual Leaves)',
                                  style: TextStyle(color: Colors.black),
                                ),
                              ],
                            )
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Flexible(
                      flex: 5,
                      child: Container(
                        height: 30,
                        decoration: BoxDecoration(
                            color: Colors.white38,
                            shape: BoxShape.rectangle,
                            borderRadius: BorderRadius.circular(4)
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 15,vertical:5),
                        margin: const EdgeInsets.fromLTRB(20, 10, 5, 5),
                        child: Align(
                            alignment: Alignment.centerLeft,
                            child: Row(
                              children: [
                                Container(
                                  width: 10,
                                  height: 10,
                                  decoration: const BoxDecoration(
                                    color: Colors.deepOrange,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 15),
                                // Add some space between the dot and text
                                const Text(
                                  'Rejected (Leaves)',
                                  style: TextStyle(color: Colors.black),
                                ),
                              ],
                            )
                        ),
                      ),
                    ),
                    Flexible(
                      flex: 5,
                      child: Container(
                        height: 30,
                        decoration: BoxDecoration(
                            color: Colors.white38,
                            shape: BoxShape.rectangle,
                            borderRadius: BorderRadius.circular(4)
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 15,vertical:5),
                        margin: const EdgeInsets.fromLTRB(5, 10, 20, 5),
                        child: Align(
                            alignment: Alignment.centerLeft,
                            child: Row(
                              children: [
                                Container(
                                  width: 10,
                                  height: 10,
                                  decoration: const BoxDecoration(
                                    color: Colors.white60,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 15),
                                // Add some space between the dot and text
                                const Text(
                                  'Company OFF',
                                  style: TextStyle(color: Colors.black),
                                ),
                              ],
                            )
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(
                  child: Expanded(
                    child: Container(
                        margin: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                        height: 1,
                        decoration: const BoxDecoration(color: Colors.black12)),
                  ),
                ),
                CustomCalendar(phoneNumber: phoneNumber,), // Display the custom calendar
                SizedBox(
                  child: Expanded(
                    child: Container(
                        margin: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                        height: 1,
                        decoration: const BoxDecoration(color: Colors.black12)),
                  ),
                ),

              ],
            ),
          ),
        ],
    ),
    );
  }

  printMessage(String msg) {
    debugPrint(msg);
  }

}

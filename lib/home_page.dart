import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rbc_atted/mobile_number_verification.dart';
import 'package:rbc_atted/screens/admin/add_admin.dart';
import 'package:rbc_atted/screens/admin/company/company_detail_screen.dart';
import 'package:rbc_atted/screens/admin/company/shift_list_screen.dart';
import 'package:rbc_atted/screens/admin/register_accountant.dart';
import 'package:rbc_atted/screens/admin/register_employee.dart';
import 'package:rbc_atted/screens/admin/register_hr.dart';
import 'package:rbc_atted/screens/admin/request_leave.dart';
import 'package:rbc_atted/screens/admin/total_attendance.dart';
import 'package:rbc_atted/screens/user/apply_leave.dart';
import 'package:rbc_atted/screens/user/wfh_attendance.dart';
import 'package:rbc_atted/screens/user/wfo_attendance.dart';
import 'package:rbc_atted/screens/user/user_profile.dart';
import 'package:rbc_atted/screens/user/view_attendance.dart';
import 'package:rbc_atted/utility/Constants.dart';
import 'package:rbc_atted/utility/get_data_from_hive.dart';
import 'package:rbc_atted/utility/get_userdata.dart';
import 'package:rbc_atted/utility/internet_checker.dart';
import 'package:rbc_atted/utility/shared_preference.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'modals/drawer_menu_item.dart';
import 'screens/admin/total_emp_list.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<HomeScreen> {
  String currentScreen = '1';
  final UserDataService _userDataService = UserDataService();
  Map<String, dynamic> userData = {};
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late SharedPreferences prefs;
  late MySharedPreference myPrefs;

  @override
  void initState() {
    super.initState();
    const InternetConnectionWidget();
    fetchUserData(context);
  }

  void changeScreen(String newScreen) {
    setState(() {
      currentScreen = newScreen;
    });
    Navigator.pop(context);
  }

  Future<void> fetchUserData(BuildContext context) async {
    try {
      prefs = await SharedPreferences.getInstance();
      myPrefs = MySharedPreference(prefs);
      Map<String, dynamic>? value =
          await myPrefs.getUserData(MyConstants.userPhone);
      Map<String, dynamic> userDataResult = await _userDataService
          .getUserDataByPhoneNumber(value?['phone'], context);
      await UserDataManager.updateUserDataInHive(value?['phone'], context);
      setState(() {
        userData = userDataResult;
        currentScreen = (userData['role'] == 'admin') ? "5" : "1";
      });
      await myPrefs.saveUserData(MyConstants.userName, userData);
    } catch (e) {
      e.toString();
    }
  }

  Widget getScreen() {
    switch (currentScreen) {
      case "1":
        return const ProfileScreen();
      case "2":
        return const ViewAttendance();
      case "3":
        return  userData['workMode'] == "WFO(Work From Office)" ? const WFOMarkAttendanceScreen() : const WFHMarkAttendanceScreen() ;
      case "4":
        return const ApplyLeave();
      case "5":
        return const ProfileScreen();
      case "6":
        return const TodayAttendance();
      case "7":
        return const RegisterEmployee();
      case "8":
        return const RegisterAdmin();
      case "9":
        return const LeaveListScreen();
      case "10":
        return const TotalEmpList();
      case "11":
        return const RegisterHr();
      case "12":
        return const RegisterAccountant();
      case "13":
        return const CompanyDetailsScreen();
      case "15":
        return ShiftListScreen();
      default:
        return const Center(
          child: Text('In Progress'),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Risebeyond Consultancy',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF091E3E),
        actions: [
          IconButton(
            icon: const Icon(Icons.power_settings_new_outlined),
            onPressed: () async {
              // Show the dialog before starting the sign-out process
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext context) {
                  return const Dialog(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                },
              );
              try {
                await _auth.signOut();
                await myPrefs.clearAllSharedPreferences();
                setState(() {
                  Navigator.of(context, rootNavigator: true).pop();
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (_) =>
                              const MobileNumberVerificationPage()));
                });
              } catch (e) {
                rethrow;
              }
            },
          ),
        ],
      ),
      drawer: buildDrawer(),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 700), // Animation duration
        child: getScreen(),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    );
  }

  Widget buildDrawer() {
    List<MenuItem> userMenuItems = [
      MenuItem(title: 'Home', icon: Icons.home, screenNumber: '1'),
      MenuItem(
          title: 'View Attendance',
          icon: Icons.calendar_month,
          screenNumber: '2'),
      MenuItem(title: 'Mark Attendance', icon: Icons.camera, screenNumber: '3'),
      MenuItem(
          title: 'Apply Leave',
          icon: Icons.leave_bags_at_home,
          screenNumber: '4'),
    ];
    List<MenuItem> hrMenuItems = [
      MenuItem(title: 'Home', icon: Icons.home, screenNumber: '1'),
      MenuItem(
          title: 'View Attendance',
          icon: Icons.calendar_month,
          screenNumber: '2'),
      MenuItem(title: 'Mark Attendance', icon: Icons.camera, screenNumber: '3'),
      MenuItem(
          title: 'Apply Leave',
          icon: Icons.leave_bags_at_home,
          screenNumber: '4'),
    ];
    List<MenuItem> accMenuItems = [
      MenuItem(title: 'Home', icon: Icons.home, screenNumber: '1'),
      MenuItem(
          title: 'View Attendance',
          icon: Icons.calendar_month,
          screenNumber: '2'),
      MenuItem(title: 'Mark Attendance', icon: Icons.camera, screenNumber: '3'),
      MenuItem(
          title: 'Apply Leave',
          icon: Icons.leave_bags_at_home,
          screenNumber: '4'),
    ];
    List<MenuItem> adminMenuItems = [
      MenuItem(title: 'Home', icon: Icons.home, screenNumber: '5'),
      MenuItem(
          title: 'Today\'s Attendance',
          icon: Icons.calendar_month,
          screenNumber: '6'),
      MenuItem(
          title: 'Add Employee', icon: Icons.person_add, screenNumber: '7'),
      MenuItem(title: 'Add Admin', icon: Icons.person_add, screenNumber: '8'),
      MenuItem(title: 'Add HR', icon: Icons.person_add, screenNumber: '11'),
      MenuItem(
          title: 'Add Accountant', icon: Icons.person_add, screenNumber: '12'),
      MenuItem(
          title: 'Leave Requests',
          icon: Icons.request_page_rounded,
          screenNumber: '9'),
      MenuItem(title: 'Employees Lists', icon: Icons.list, screenNumber: '10'),
      MenuItem(
          title: 'Company Details', icon: Icons.details, screenNumber: '13'),
      MenuItem(
          title: 'Company Reports', icon: Icons.report, screenNumber: '14'),
      MenuItem(
          title: 'Shift Timings', icon: Icons.timer, screenNumber: '15'),
    ];
    List<MenuItem> currentMenuItems = [];
    if (userData['role'] == 'admin') {
      currentMenuItems = adminMenuItems;
    } else if (userData['role'] == 'user') {
      currentMenuItems = userMenuItems;
    } else if (userData['role'] == 'hr') {
      currentMenuItems = hrMenuItems;
    } else if (userData['role'] == 'accountant') {
      currentMenuItems = accMenuItems;
    }

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Color(0xFF091E3E),
            ),
            child: Column(
              children: [
                CircleAvatar(
                  backgroundImage: userData.isNotEmpty
                      ? NetworkImage('${userData['profileImageName']}')
                          as ImageProvider<Object>?
                      : const AssetImage('assets/images/person_icon.png'),
                  // Placeholder image
                  radius: 30, // Adjust the size as needed
                ),

                const SizedBox(width: 16),
                // Add spacing between the image and text
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${userData['name']}', // Replace with user's name
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                      ),
                    ),
                    Text(
                      '${userData['email']}', // Replace with user's email
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
              ],
            ),
          ),
          for (var item in currentMenuItems)
            buildMenuItem(item, item.screenNumber == currentScreen),
        ],
      ),
    );
  }

  Widget buildMenuItem(MenuItem item, bool isSelected) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(51),
        color: isSelected ? const Color(0xFF091E3E).withOpacity(0.3) : null,
      ),
      child: ListTile(
        leading:
            Icon(item.icon, color: isSelected ? Colors.white : Colors.black),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              item.title,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
              ),
            ),
            Icon(Icons.arrow_forward_ios,
                color: isSelected ? Colors.white : Colors.black),
          ],
        ),
        onTap: () {
          changeScreen(item.screenNumber);
        },
      ),
    );
  }
}

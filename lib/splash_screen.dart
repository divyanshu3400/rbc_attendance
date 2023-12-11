import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rbc_atted/home_page.dart';
import 'package:rbc_atted/modals/UserData.dart';
import 'package:package_info/package_info.dart';
import 'package:rbc_atted/utility/Constants.dart';
import 'package:rbc_atted/utility/get_data_from_hive.dart';
import 'package:rbc_atted/utility/shared_preference.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'mobile_number_verification.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  SplashScreenStateState createState() => SplashScreenStateState();
}

class SplashScreenStateState extends State<SplashScreen> {
  late bool isCheckIn;
  late UserData userData;

  Future<void> fetchUserData() async {
    try {
      UserData? fetchedUserData = await UserDataManager.getUserDataFromHive();
      setState(() {
        userData = fetchedUserData;
      });
        } catch (e) {
      throw ('Error fetching user data: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () async {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        MySharedPreference myPrefs = MySharedPreference(prefs);
        Map<String, dynamic>? value =
            await myPrefs.getUserData(MyConstants.userPhone);
        await UserDataManager.updateUserDataInHive(value?['phone'], context);
        await fetchUserData();
        Map<String, dynamic> latestLog = userData.attendanceLogs.last;
        isCheckIn = latestLog['isCheckIn'];
        setState(() {
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              transitionDuration: const Duration(milliseconds: 400),
              pageBuilder: (_, __, ___) => const HomeScreen(),
              transitionsBuilder: (_, animation, __, child) {
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(1.0, 0.0),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                );
              },
            ),
          );
        });
        // if (isCheckIn) {
        // } else {
        //   setState(() {
        //     Navigator.pushReplacement(
        //       context,
        //       PageRouteBuilder(
        //         transitionDuration: const Duration(milliseconds: 500),
        //         pageBuilder: (_, __, ___) => const MarkAttendanceScreen(),
        //         transitionsBuilder: (_, animation, __, child) {
        //           return SlideTransition(
        //             position: Tween<Offset>(
        //               begin: const Offset(1.0, 0.0),
        //               end: Offset.zero,
        //             ).animate(animation),
        //             child: child,
        //           );
        //         },
        //       ),
        //     );
        //   });
        // }
      } else {
        setState(() {
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              transitionDuration: const Duration(milliseconds: 500),
              pageBuilder: (_, __, ___) => const MobileNumberVerificationPage(),
              transitionsBuilder: (_, animation, __, child) {
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(1.0, 0.0),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                );
              },
            ),
          );
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PackageInfo>(
      future: PackageInfo.fromPlatform(),
      builder: (BuildContext context, AsyncSnapshot<PackageInfo> snapshot) {
        String version = '';
        if (snapshot.hasData) {
          version = snapshot.data!.version;
        }
        return Scaffold(
          body: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                'assets/images/background_image.jpg', // Replace with your image path
                fit: BoxFit.cover,
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      const Color(0xFF091E3E).withOpacity(1), // Adjust opacity as needed
                      Colors.transparent,
                      Colors.transparent,
                      const Color(0xFF091E3E).withOpacity(1), // Adjust opacity as needed
                    ],
                  ),
                ),
              ),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Image.asset(
                      'assets/images/logo_rbc.png',
                      width: 150,
                      height: 150,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Risebeyond Consultancy',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              Positioned(
                bottom: 20.0,
                left: 0,
                right: 0,
                child: Text(
                  'Version: $version',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

}

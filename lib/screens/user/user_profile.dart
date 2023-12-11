import 'package:flutter/material.dart';
import 'package:rbc_atted/utility/dimens.dart';
import 'package:rbc_atted/utility/formating.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../modals/UserData.dart';
import '../../utility/Constants.dart';
import '../../utility/shared_preference.dart';
import '../../utility/get_data_from_hive.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  ProfileScreenState createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen> {
  late Future<UserData?> _userDataFuture;
  late bool isCheckIn;
  late List<Map<String, dynamic>> calendarDataList;

  @override
  void initState() {
    super.initState();
    _userDataFuture = fetchUserData();
  }


  Future<UserData> fetchUserData() async {
    try {
      var prefs = await SharedPreferences.getInstance();
      var myPrefs = MySharedPreference(prefs);
      Map<String, dynamic>? value =
          await myPrefs.getUserData(MyConstants.userPhone);
      await UserDataManager.updateUserDataInHive(value?['phone'], context);
      return await UserDataManager.getUserDataFromHive();
    } catch (e) {
      throw ('Error fetching user data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<UserData?>(
        future: _userDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('No user data found.'));
          } else {
            UserData userData = snapshot.data!;
            Map<String, dynamic> latestLog = userData.attendanceLogs.last;
            isCheckIn = latestLog['isCheckIn'];
            return buildUserProfile(userData, isCheckIn);
          }
        },
      ),
    );
  }

  Widget buildUserProfile(UserData userData, bool isOnline) {
    return Stack(
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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              margin: const EdgeInsets.fromLTRB(15, 30, 10, 0),
              child: Positioned(
                top: 20,
                left: 20,
                child: Stack(
                  alignment: Alignment.topLeft,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(60),
                      child: Image.network(
                        userData.profileImageName,
                        width: 120,
                        height: 120,
                        fit: BoxFit.cover,
                        loadingBuilder: (BuildContext context, Widget child,
                            ImageChunkEvent? loadingProgress) {
                          if (loadingProgress == null) {
                            return child;
                          } else {
                            return const SizedBox(
                              height: 150,
                              width: 150,
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }
                        },
                        errorBuilder: (BuildContext context, Object exception,
                            StackTrace? stackTrace) {
                          return Image.asset(
                            'assets/images/person_icon.png',
                            width: 120,
                            height: 120,
                            fit: BoxFit.cover,
                          );
                        },
                      ),
                    ),
                    if (isOnline)
                      Container(
                        margin: const EdgeInsets.only(top: 8, left: 8),
                        width: 16,
                        height: 16,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.green,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Container(
              margin: const EdgeInsets.all(20),
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white12,
                borderRadius: BorderRadius.all(Radius.circular(7)),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  const Text('Profile Details ',
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
                    margin: const EdgeInsets.only(left: 8.0), // Adjust margin as needed
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
                          padding: const EdgeInsets.only(left: 20.0), // Adjust the padding as needed
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              userData.name,
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
                          padding: const EdgeInsets.only(left: 20.0), // Adjust the padding as needed
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              userData.email,
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
                          padding: const EdgeInsets.only(left: 20.0), // Adjust the padding as needed
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text("+91 ${Formatting.formatMobileNumber(userData.phoneNumber)}",
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
                              'DOB ->',
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
                          padding: const EdgeInsets.only(left: 20.0), // Adjust the padding as needed
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              userData.dob,
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
                          padding: const EdgeInsets.only(left: 20.0), // Adjust the padding as needed
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              userData.designation,
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
            Container(
              margin: const EdgeInsets.all(20),
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white12,
                borderRadius: BorderRadius.all(Radius.circular(7)),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  const Text('Other Details ',
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
                    margin: const EdgeInsets.only(left: 8.0), // Adjust margin as needed
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
                              'Aadhar  ->',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: Dimens.normalText,
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
                          padding: const EdgeInsets.only(left: 20.0), // Adjust the padding as needed
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(Formatting.formatAadharNumber(userData.aadhar),
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
                              'Bank Account  ->',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: Dimens.normalText,
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
                          padding: const EdgeInsets.only(left: 20.0), // Adjust the padding as needed
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              userData.bankName,
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
                              'Acc No ->',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: Dimens.normalText,
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
                          padding: const EdgeInsets.only(left: 20.0), // Adjust the padding as needed
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              userData.accNo,
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
                              'IFSC  ->',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: Dimens.normalText,
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
                          padding: const EdgeInsets.only(left: 20.0), // Adjust the padding as needed
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              userData.ifscCode,
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
                              'Joined On  ->',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: Dimens.normalText,
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
                          padding: const EdgeInsets.only(left: 20.0), // Adjust the padding as needed
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              Formatting.formatJoiningDate(userData.joiningDate),
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
          ],
        ),
      ],
    );
  }

}

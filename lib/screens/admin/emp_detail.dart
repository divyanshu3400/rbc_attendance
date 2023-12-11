import 'package:flutter/material.dart';
import 'package:rbc_atted/modals/total_employee_modal.dart';
import 'package:rbc_atted/utility/custome_calendar.dart';
import 'package:rbc_atted/utility/dimens.dart';
import 'package:rbc_atted/utility/formating.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../modals/UserData.dart';
import '../../utility/Constants.dart';
import '../../utility/shared_preference.dart';
import '../../utility/get_data_from_hive.dart';

class EmployeeDetails extends StatefulWidget {
  final Employee employee;

  const EmployeeDetails({Key? key, required this.employee}) : super(key: key);

  @override
  ProfileScreenState createState() => ProfileScreenState();
}

class ProfileScreenState extends State<EmployeeDetails> {
  late List<Map<String, dynamic>> calendarDataList;

  @override
  void initState() {
    super.initState();
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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                margin: const EdgeInsets.fromLTRB(15, 70, 10, 0),
                child: Positioned(
                  top: 20,
                  left: 20,
                  child: Stack(
                    alignment: Alignment.topLeft,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(60),
                        child: Image.network(
                          widget.employee.profilePic,
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
                                child:
                                    Center(child: CircularProgressIndicator()),
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
                      margin: const EdgeInsets.only(
                          left: 8.0), // Adjust margin as needed
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
                                widget.employee.name,
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
                                widget.employee.email,
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
                                "+91 ${Formatting.formatMobileNumber(widget.employee.phone)}",
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
                                widget.employee.designation,
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
              CustomCalendar(phoneNumber: widget.employee.phone),
            ],
          ),
        ],
      ),
    );
  }
}

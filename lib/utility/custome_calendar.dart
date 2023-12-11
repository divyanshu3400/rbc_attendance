import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'Constants.dart';

class CustomCalendar extends StatefulWidget {
  final String phoneNumber;
  const CustomCalendar({Key? key, required this.phoneNumber}) : super(key: key);

  @override
  CustomCalendarState createState() => CustomCalendarState();
}

class CustomCalendarState extends State<CustomCalendar> {
  CalendarFormat calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  late List<Map<String, dynamic>> _calendarDataList;
  Future<List<Map<String, dynamic>>>? _eventDataListFuture;

  @override
  void initState() {
    super.initState();
    _eventDataListFuture = retrieveLeaveData();
    fetchFirebaseData();

  }

  Future<void> fetchDataAndUpdateCalendar() async{
    DatabaseReference dbRef = FirebaseDatabase.instance.ref('attendance').child(widget.phoneNumber).child('month_data');
    await dbRef.once().then((DatabaseEvent event) {
      if (event.snapshot.value != null) {
        Map<dynamic, dynamic>? monthData = event.snapshot.value as Map<dynamic, dynamic>?;
        if (monthData != null) {
          _calendarDataList = [];
          monthData.forEach((key, value) {
            if (value != null && value is Map<dynamic, dynamic>) {
              String? date = value['date'] as String?;
              if (date != null) {
                _calendarDataList.add({
                  'date': value['date'] as String?,
                  'month': value['month'] as String?,
                  'year': value['year'] as String?,
                  'status': value['status'] as String?,
                  'isLeave': value['isLeave'] as bool?,
                  'approved': value['approved'] ?? false,
                  'rejected': value['rejected'] ?? false,
                  'username': value['username'] ?? ''
                });
              }
            }
          });
          storeLeaveData(_calendarDataList);
        }
      }
    }, onError: (Object? error) {
    });
  }

  Future<void> storeLeaveData(List<Map<String, dynamic>> calendarDataList) async {
    try {
      var box = await Hive.openBox(MyConstants.userBoxName);
      await box.put(MyConstants.userLeaveDataKey, calendarDataList);
      setState(() {
        _eventDataListFuture = retrieveLeaveData();
      });
    } catch (e) {
      throw("Error storing data: $e");
    }
  }


  Future<void> fetchFirebaseData() async {
    await fetchDataAndUpdateCalendar();
  }

  Future<List<Map<String, dynamic>>> retrieveLeaveData() async {
    try {
      var box = await Hive.openBox(MyConstants.userBoxName);
      dynamic storedData = box.get(MyConstants.userLeaveDataKey);
      if (storedData != null && storedData is List) {
        List<dynamic> dataList = storedData;
        List<Map<String, dynamic>> parsedDataList = dataList
            .whereType<Map<String, dynamic>>()
            .cast<Map<String, dynamic>>()
            .toList();
        return parsedDataList;
      }
    } catch (e) {
      throw("Error retrieving data: $e");
    }
    return []; // Return an empty list if data retrieval fails
  }


  List<Map<String, dynamic>> _getEventsForDay(DateTime day,
    List<Map<String, dynamic>> eventDataList,
  ) {
    String formattedDay = DateFormat('yyyy-MM-dd').format(day);
    return eventDataList
        .where((event) => event['date'] == formattedDay)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _eventDataListFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text('Error fetching data'));
        } else {
          List<Map<String, dynamic>> eventDataList = snapshot.data ?? [];

          return Container(
            decoration: const BoxDecoration(
              color: Colors.white12,
              borderRadius: BorderRadius.all(Radius.circular(7)),
            ),
            margin: const EdgeInsets.all(20),
            child: TableCalendar(
              headerStyle: const HeaderStyle(
                titleTextStyle: TextStyle(color: Colors.white), // Month and year text color
                formatButtonShowsNext: false, // Ensure next icon is not displayed
                leftChevronIcon: Icon(Icons.chevron_left, color: Colors.white), // Previous icon color
                rightChevronIcon: Icon(Icons.chevron_right, color: Colors.white), // Next icon color
              ),

              firstDay:
                  DateTime(DateTime.now().year, DateTime.now().month - 1, 1),
              lastDay:
                  DateTime(DateTime.now().year, DateTime.now().month + 1, 0),
              focusedDay: _focusedDay,
              calendarFormat: calendarFormat,
              eventLoader: (day) => _getEventsForDay(day, eventDataList),
              onPageChanged: (focusedDay) {
                setState(() {
                  _focusedDay = focusedDay;
                });
              },
              selectedDayPredicate: (day) {
                return isSameDay(_selectedDay, day);
              },
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              calendarBuilders: CalendarBuilders(
                markerBuilder: markerBuilder,
                dowBuilder: (context, day) {
                  final text = DateFormat.E().format(day);
                  if (day.weekday == DateTime.saturday || day.weekday == DateTime.sunday) {
                    return Center(
                      child: Text(
                        text,
                        style: const TextStyle(color: Colors.redAccent),
                      ),
                    );
                  } else {
                    return Center(
                      child: Text(
                        text,
                        style: const TextStyle(color: Colors.white70),
                      ),
                    );
                  }
                },
                defaultBuilder: (context, date, _) {
                  if (date.weekday == DateTime.saturday || date.weekday == DateTime.sunday) {
                    return Container(
                      margin: const EdgeInsets.all(2),
                      child: Center(
                        child: Text(
                          '${date.day}',
                          style: const TextStyle(color: Colors.redAccent),
                        ),
                      ),
                    );
                  } else {
                    return Container(
                      margin: const EdgeInsets.all(2),
                      child: Center(
                        child: Text(
                          '${date.day}',
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ),
                    );
                  }
                },
              ),
            ),
          );
        }
      },
    );
  }

  MarkerBuilder<dynamic> markerBuilder = (context, date, events) {
    DateTime currentDate = DateTime.now();
    DateTime firstDayOfMonth = DateTime(date.year, date.month, 1);
    if (date.month == currentDate.month &&
        date.isAfter(firstDayOfMonth.subtract(const Duration(days: 1))) &&
        date.isBefore(firstDayOfMonth.add(const Duration(days: 31)))) {
    }
    if (date.weekday != DateTime.saturday &&
        date.weekday != DateTime.sunday) {
      // Check if there are no events for that day
      if (date.isBefore(currentDate) && events.isEmpty) {
        return Center(
          child: Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.redAccent,
            ),
            width: 40,
            height: 40,
            child: Center(
              child: Text(
                ((DateFormat('dd').format(date)).toString()),
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
        );
      }
    }

    if (events.isNotEmpty) {
      var event = events[0];
      var status = event['status'];
      var isLeave = event['isLeave'];
      var approved = event['approved'];
      var rejected = event['rejected'];
      if (isLeave && approved && !rejected) {
        if (status == 'EL(Earned Leave)') {
          return Center(
            child: Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.yellow,
              ),
              width: 40,
              height: 40,
              child: Center(
                child: Text(
                  ((DateFormat('dd').format(date)).toString()),
                  style: const TextStyle(color: Colors.black),
                ),
              ),
            ),
          );
        }
        if (status == 'CL(Casual Leave)') {
          return Center(
            child: Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.orange,
              ),
              width: 40,
              height: 40,
              child: Center(
                child: Text(
                  ((DateFormat('dd').format(date)).toString()),
                  style: const TextStyle(color: Colors.black),
                ),
              ),
            ),
          );
        }
      }
      else if (isLeave && approved) {
        if (rejected) {
          return Center(
            child: Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.deepOrange,
              ),
              width: 40,
              height: 40,
              child: Center(
                child: Text(
                  ((DateFormat('dd').format(date)).toString()),
                  style: const TextStyle(color: Colors.black),
                ),
              ),
            ),
          );
        }
        if (status == 'CL(Casual Leave)') {
          return Center(
            child: Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.orange,
              ),
              width: 40,
              height: 40,
              child: Center(
                child: Text(
                  ((DateFormat('dd').format(date)).toString()),
                  style: const TextStyle(color: Colors.black),
                ),
              ),
            ),
          );
        }
      }
      else if (status == "present") {
        return Center(
          child: Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.green,
            ),
            width: 40,
            height: 40,
            child: Center(
              child: Text(
                ((DateFormat('dd').format(date)).toString()),
                style: const TextStyle(color: Colors.black),
              ),
            ),
          ),
        );
      } else {
        Positioned(
          bottom: 1,
          child: Container(
            height: 5,
            width: 5,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.transparent,
            ),
          ),
        );
      }
    }
    return null;
  };
}

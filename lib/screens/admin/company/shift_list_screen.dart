import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:rbc_atted/screens/admin/company/company_shift_timing.dart';

class ShiftListScreen extends StatefulWidget {
  const ShiftListScreen({super.key});


  @override
  ShiftListScreenState createState() => ShiftListScreenState();
}

class ShiftListScreenState extends State<ShiftListScreen> {
  late DatabaseReference _shiftsRef;
  late List<Map<dynamic, dynamic>> _shifts;

  @override
  void initState() {
    super.initState();
    _shiftsRef = FirebaseDatabase.instance.ref("company").child('shifts');
    _shifts = [];
    fetchShifts();
  }

  void fetchShifts() {
    _shiftsRef.once().then((DatabaseEvent event) {
      setState(() {
        _shifts.clear();
        Map<dynamic, dynamic> values =
            (event.snapshot.value) as Map<dynamic, dynamic>;
        values.forEach((key, value) {
          _shifts.add({
            'key': key,
            'startTime_hour': value['startTime_hour'],
            'startTime_minute': value['startTime_minute'],
            'end_time': value['end_time'],
            'end_minute': value['end_minute'],
            'delay': value['delay'],
          });
        });
      });
    }).catchError((error) {
      throw ('Error fetching shifts: $error');
    });
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
          _shifts.isEmpty
              ? const Center(
                  child: Text(
                  'No shifts available',
                  style: TextStyle(color: Colors.white),
                ))
              : ListView.builder(
                  itemCount: _shifts.length,
                  itemBuilder: (context, index) {
                    return ShiftListTile(shifts: _shifts,index: index,);
                  },
                ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            PageRouteBuilder(
              transitionDuration: const Duration(milliseconds: 400),
              pageBuilder: (_, __, ___) => const AddShiftScreen(),
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
        },
        child: const Icon(Icons.timer),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}


class ShiftListTile extends StatelessWidget {
  final List<Map<dynamic, dynamic>> shifts;
  final int index;

  const ShiftListTile({Key? key, required this.shifts, required this.index}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white12,
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: const CircleAvatar(
          radius: 40,
          backgroundColor: Colors.blue, // Set your desired background color
          child: Icon(
            Icons.timer, // Your icon here
            size: 40,
            color: Colors.white, // Set the color of the icon
          ),
        ),
        title: Text(
        "Shift Starts Time ->  ${shifts[index]['startTime_hour']} : ${shifts[index]['startTime_minute']}",
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
        subtitle: Text(
          "Shift End Time ->  ${shifts[index]['end_time']} : ${shifts[index]['end_minute']}",
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
        onTap: () {
          // Handle onTap action if needed
        },
      ),
    );
  }
}


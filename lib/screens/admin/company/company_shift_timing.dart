import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class AddShiftScreen extends StatefulWidget {
  const AddShiftScreen({super.key});


  @override
  AddShiftScreenState createState() => AddShiftScreenState();
}

class AddShiftScreenState extends State<AddShiftScreen> {
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;
  late int _selectedDelay;
  final DatabaseReference _shiftRef = FirebaseDatabase.instance.ref("company").child('shifts');

  @override
  void initState() {
    super.initState();
    _startTime = TimeOfDay.now();
    _endTime = TimeOfDay.now();
    _selectedDelay = 0; // Initially selected delay (if any)
  }

  Future<void> _selectStartTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _startTime,
    );
    if (picked != null && picked != _startTime) {
      setState(() {
        _startTime = picked;
      });
    }
  }

  Future<void> _selectEndTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _endTime,
    );
    if (picked != null && picked != _endTime) {
      setState(() {
        _endTime = picked;
      });
    }
  }

  void _saveShiftDetails() {
    _shiftRef.push().set({
      'startTime_hour': _startTime.hour,
      'startTime_minute': _startTime.minute,
      'end_time': _endTime.hour,
      'end_minute': _endTime.minute,
      'delay': _selectedDelay,
    }).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Shift details saved successfully')),
      );
      Navigator.of(context).pop();

    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save shift details: $error')),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Shift Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: () => _selectStartTime(context),
              child: Text('Select Start Time: ${_startTime.format(context)}'),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () => _selectEndTime(context),
              child: Text('Select End Time: ${_endTime.format(context)}'),
            ),
            const SizedBox(height: 16.0),
            DropdownButton<int>(
              value: _selectedDelay,
              onChanged: (int? value) {
                setState(() {
                  _selectedDelay = value!;
                });
              },
              items: const [
                DropdownMenuItem(
                  value: 0,
                  child: Text('No Delay'),
                ),
                DropdownMenuItem(
                  value: 10,
                  child: Text('10 min Delay'),
                ),
                DropdownMenuItem(
                  value: 15,
                  child: Text('15 min Delay'),
                ),
              ],
            ),
            const SizedBox(height: 32.0),
            ElevatedButton(
              onPressed: _saveShiftDetails,
              child: const Text('Save Shift Details'),
            ),
          ],
        ),
      ),
    );
  }
}

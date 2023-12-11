import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class WeekCalendar extends StatelessWidget {
  const WeekCalendar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final DateTime now = DateTime.now();
    final DateTime sunday = now.subtract(Duration(days: now.weekday - 1));

    final List<DateTime> weekDays =
        List.generate(7, (index) => sunday.add(Duration(days: index)));

    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey, // Change the color of the bottom border
            width: 1.0, // Adjust the width of the bottom border
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: weekDays.map((day) {
          final bool isCurrentDate = _isSameDay(day, now);
          return Container(
            margin: const EdgeInsets.fromLTRB(0, 0, 0, 20),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey, // Change the color of the bottom border
                  width: 1.0, // Adjust the width of the bottom border
                ),
              ),
            ),
            child: Column(
              children: [
                Text(
                  DateFormat.E().format(day).toUpperCase(),
                  style: TextStyle(
                    color: (day.weekday == DateTime.saturday ||
                            day.weekday == DateTime.sunday
                        ? Colors.red
                        : Colors.white),
                  ),
                ),
                Container(
                  height: 27,
                  width: 27,
                  margin: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                  decoration: BoxDecoration(
                    color: isCurrentDate ? Colors.blueAccent : null,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      day.day.toString(),
                      style: TextStyle(
                        color: (day.weekday == DateTime.saturday ||
                                day.weekday == DateTime.sunday
                            ? Colors.red
                            : Colors.white),
                      ),
                    ),
                  ),
                )
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

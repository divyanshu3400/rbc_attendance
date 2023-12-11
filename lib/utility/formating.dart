import 'package:intl/intl.dart';

class Formatting{
static  String formatAadharNumber(String aadharNumber) {
    if (aadharNumber.length != 12) {
      return aadharNumber; // Return as it is if the Aadhar number doesn't have 12 digits
    }
    return aadharNumber.replaceAllMapped(
      RegExp(r".{4}"),
          (match) => "${match.group(0)}  ",
    );
  }
static  String formatMobileNumber(String mobileNumber) {
    if (mobileNumber.length != 10) {
      return mobileNumber; // Return as it is if the Aadhar number doesn't have 12 digits
    }
    return mobileNumber.replaceAllMapped(
      RegExp(r".{5}"),
          (match) => "${match.group(0)}  ",
    );
  }

static String formatJoiningDate(String date) {
  if (date.isEmpty) {
    return ''; // Return an empty string if the date is empty or null
  }

  final DateTime dateTime = DateTime.parse(date); // Parse the date string to DateTime
  final DateFormat formatter = DateFormat('dd-MMMM-yyyy'); // Define the format

  return formatter.format(dateTime); // Format the date according to the defined format
}

}
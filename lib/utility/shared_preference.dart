import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class MySharedPreference {
  final SharedPreferences _prefs;

  MySharedPreference(this._prefs);

  // Function to save user data
  Future<void> saveUserData(String key, Map<String, dynamic> value) async {
    final String userDataString = json.encode(value);
    await _prefs.setString(key, userDataString);
  }

  // Function to retrieve user data
  Future<Map<String, dynamic>?> getUserData(String key) async {
    final String? userDataString = _prefs.getString(key);
    if (userDataString != null) {
      return json.decode(userDataString) as Map<String, dynamic>;
    }
    return null; // Return null if no data is found
  }

  // Function to clear user data
  Future<void> clearUserData(String key) async {
    await _prefs.remove(key);
  }

  // Function to clear all SharedPreferences data
  Future<void> clearAllSharedPreferences() async {
    await _prefs.clear();
  }
}

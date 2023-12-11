import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserDataService {
  final CollectionReference usersCollection =
  FirebaseFirestore.instance.collection('users');
  Future<Map<String, dynamic>> getUserDataByPhoneNumber(String phoneNumber,
      BuildContext context) async {
    try {
      DocumentSnapshot userData =
      await usersCollection.doc(phoneNumber).get();
      if (userData.exists) {
        Map<String, dynamic> userDataMap =
        userData.data() as Map<String, dynamic>;
        return userDataMap;
      }
      else {
        _showProfileNotFoundErrorDialog(context);
        throw  'Error fetching user data:';
      }
    } catch (e) {
      throw 'Error fetching user data: $e';
    }
  }

  void _showProfileNotFoundErrorDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Profile Not Found'),
          content: const Text(
              'Your profile is not created. Contact your admin for further queries.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Okay'),
              onPressed: () {
                exit(0); // This will close the app
              },
            ),

          ],
        );
      },
    );
  }


  // Function to get current user's data
  Future<Map<String, dynamic>> getCurrentUserData() async {
    try {
      FirebaseAuth auth = FirebaseAuth.instance;
      User? user = auth.currentUser;
      if (user != null) {
        DocumentSnapshot userData =
        await usersCollection.doc(user.uid).get();

        if (userData.exists) {
          Map<String, dynamic> userDataMap = userData.data() as Map<String, dynamic>;
          return userDataMap;
        } else {
          throw 'User data does not exist.';
        }
      } else {
        throw 'User is not signed in.';
      }
    } catch (e) {
      throw 'Error fetching user data: $e';
    }
  }
}

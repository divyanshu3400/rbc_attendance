import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:rbc_atted/utility/Constants.dart';
import '../modals/UserData.dart';

class UserDataManager {

  static CollectionReference usersCollection =
  FirebaseFirestore.instance.collection('users');

 static  Future<Map<String, dynamic>> getUserDataByPhoneNumber(String phoneNumber,
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
        throw  'Error fetching user data:';
      }
    } catch (e) {
      throw 'Error fetching user data: $e';
    }
  }

  static Future<Map<String, dynamic>> getUserDataFromFirebase() async {
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

  static Future<void> updateUserDataInHive(String phoneNumber,
      BuildContext context) async {
    var userBox = await Hive.openBox(MyConstants.userBoxName);
    var userData = await getUserDataByPhoneNumber(phoneNumber, context);
    userBox.put(MyConstants.userDataKey, userData);
    }

  static Future<UserData> getUserDataFromHive() async {
    var userBox = await Hive.openBox(MyConstants.userBoxName);
    Map<String, dynamic>? userDataMap = userBox.get(MyConstants.userDataKey);
    return UserData.fromMap(userDataMap!);
  }

}


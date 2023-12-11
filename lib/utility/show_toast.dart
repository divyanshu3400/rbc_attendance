import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ShowToast {

  static void showToast(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
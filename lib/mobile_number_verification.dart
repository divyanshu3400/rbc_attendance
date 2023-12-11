import 'package:flutter/material.dart';
import 'package:rbc_atted/utility/get_data_from_hive.dart';
import 'package:rbc_atted/utility/get_userdata.dart';
import 'otp_verification.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:toast/toast.dart';

class MobileNumberVerificationPage extends StatefulWidget {
  const MobileNumberVerificationPage({Key? key}) : super(key: key);

  @override
  _MobileNumberVerificationPageState createState() =>
      _MobileNumberVerificationPageState();
}

class _MobileNumberVerificationPageState
    extends State<MobileNumberVerificationPage> {
  final TextEditingController _mobileNumberController = TextEditingController();
  bool _validate = false;
  final UserDataService _userDataService = UserDataService();
  bool _isLoading = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void dispose() {
    _mobileNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF091E3E),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(36.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 50),
                // Set padding around the image
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 10.0),
                  // Set vertical margin
                  child: Image.asset(
                    'assets/images/sendotpimg.png',
                    // Replace with your image URL
                    width: 270, // Set your logo's width
                    height: 270, // Set your logo's height
                    fit: BoxFit.contain, // Adjust the image fit as needed
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.fromLTRB(10, 0, 10, 40),
                child: const Text(
                  "Enter your mobile number to verify. We will send an OTP to this number.",
                  style: TextStyle(
                      color: Colors.white60,
                      fontSize: 14,
                      fontWeight: FontWeight.w600),
                ),
              ),
              Container(
                margin: const EdgeInsets.fromLTRB(0, 30, 0, 60),
                child: TextFormField(
                  controller: _mobileNumberController,
                  keyboardType: TextInputType.phone,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Enter your mobile number',
                    hintText: 'e.g., 1234567890',
                    hintStyle: const TextStyle(color: Colors.white60),
                    errorText: _validate ? 'Please enter a valid number' : null,
                    border: const OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  setState(() {
                    if (_mobileNumberController.text.isEmpty) {
                      _validate = true;
                    } else {
                      _validate = false;
                      _isLoading = true;
                      // Sending OTP to the provided mobile number
                      verifyPhone('+91 ${_mobileNumberController.text.trim()}');
                    }
                  });
                },
                child: _isLoading
                    ? const CircularProgressIndicator() // Show loader if _isLoading is true
                    : const Text('Send OTP'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> verifyPhone(String phoneNumber) async {
    try {
      await _userDataService.getUserDataByPhoneNumber(_mobileNumberController.text.trim(), context);
      await UserDataManager.updateUserDataInHive(_mobileNumberController.text.trim(), context);
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          setState(() {
            printMessage("verificationCompleted");
            _isLoading = false;
          });
        },
        verificationFailed: (FirebaseAuthException e) {
          setState(() {
            printMessage("verificationFailed");
            _isLoading = false;

            // Handle verification failure
          });
        },
        codeSent: (String verificationId, int? resendToken) {
          setState(() {
            _isLoading = false;
            printMessage("codeSent");

            navigateToOTPVerificationPage(verificationId);
          });
        },
        codeAutoRetrievalTimeout: (String verificationId) {
        },
        timeout: const Duration(seconds: 60),
      );
    } catch (e) {
      setState(() {
        printMessage("Error during OTP verification: $e");
      });
    }
  }

  void navigateToOTPVerificationPage(String verificationId) {

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 600),
        pageBuilder: (_, __, ___) => OTPVerificationPage(
          phone: _mobileNumberController.text.trim(),
          verificationId: verificationId,
        ),
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
  }

  printMessage(String msg) {
    debugPrint(msg);
  }
}

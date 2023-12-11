import 'package:flutter/material.dart';
import 'package:rbc_atted/home_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rbc_atted/utility/Constants.dart';
import 'package:rbc_atted/utility/get_userdata.dart';
import 'package:rbc_atted/utility/shared_preference.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OTPVerificationPage extends StatefulWidget {
  final String phone;
  final String verificationId;

  const OTPVerificationPage(
      {Key? key, required this.phone, required this.verificationId})
      : super(key: key);

  @override
  OTPVerificationState createState() => OTPVerificationState();
}

class OTPVerificationState extends State<OTPVerificationPage> {
  final TextEditingController _otpController = TextEditingController();
  bool _validate = false;
  bool _isLoading = false;
  final UserDataService _userDataService = UserDataService();
  Map<String, dynamic> userData = {};

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    fetchUserData(); // Fetch user data on widget initialization
  }

  Future<void> fetchUserData() async {
    try {
      Map<String, dynamic> userDataResult = await _userDataService
          .getUserDataByPhoneNumber(widget.phone, context);
      setState(() {
        userData = userDataResult;
      });
    } catch (e) {
      e.toString();
    }
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
              const SizedBox(
                height: 40,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 20),
                // Set padding around the image
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 0.0),
                  // Set vertical margin
                  child: Image.asset(
                    "assets/images/verifyotpimg.png",
                    // Replace with your image URL
                    width: 250, // Set your logo's width
                    height: 250, // Set your logo's height
                    fit: BoxFit.contain, // Adjust the image fit as needed
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                child: const Text(
                  "We have sent you an OTP to this number",
                  style: TextStyle(
                      color: Colors.white60,
                      fontSize: 18,
                      fontWeight: FontWeight.w600),
                ),
              ),
              Container(
                margin: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                child: Text(
                  " +91 ${widget.phone}",
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600),
                ),
              ),
              Container(
                margin: const EdgeInsets.fromLTRB(0, 30, 0, 30),
                child: TextFormField(
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Enter OTP',
                    hintText: 'e.g., 123456',
                    hintStyle: const TextStyle(color: Colors.white60),
                    errorText: _validate ? 'Please enter a valid OTP' : null,
                    border: const OutlineInputBorder(),
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                // Add horizontal padding
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Didn't receive OTP?",
                      style: TextStyle(
                        color: Colors.white60,
                        fontStyle: FontStyle.italic,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      "Resend OTP",
                      style: TextStyle(
                        color: Colors.yellow,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  setState(() {
                    _otpController.text.isEmpty
                        ? _validate = true
                        : _validate = false;
                    if (!_validate) {
                      _isLoading = true;
                      // Verifying the entered OTP
                      signInWithOTP(_otpController.text.trim());
                    }
                  });
                },
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Verify OTP'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> signInWithOTP(String smsCode) async {
    PhoneAuthCredential phoneAuthCredential = PhoneAuthProvider.credential(
        verificationId: widget.verificationId, smsCode: smsCode);
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(phoneAuthCredential);
      if (userCredential.user != null) {
        _isLoading = false;
        Map<String, dynamic> userData = {
          'phone': widget.phone,
        };
        SharedPreferences prefs = await SharedPreferences.getInstance();
        MySharedPreference myPrefs = MySharedPreference(prefs);
        await myPrefs.saveUserData(MyConstants.userPhone,userData);
        navigateToProfileForm();
      }
    } catch (e) {
      printMessage('Error signing in: ${e.toString()}');
    }
  }

  void navigateToProfileForm() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 600),
        pageBuilder: (_, __, ___) => const HomeScreen(),
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

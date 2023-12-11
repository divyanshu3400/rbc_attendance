import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rbc_atted/home_page.dart';
import 'package:rbc_atted/utility/show_toast.dart';
import 'dart:io';
import 'package:toast/toast.dart';

class EmployeeDetails extends StatefulWidget {
  const EmployeeDetails({Key? key}) : super(key: key);

  @override
  ProfileFormState createState() => ProfileFormState();
}

class ProfileFormState extends State<EmployeeDetails> {
  File? _selectedImage;
  bool _validate = false;
  bool _isLoading = false;

  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController designationController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    designationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF091E3E),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background image
          Image.asset(
            'assets/images/background_image.jpg',
            // Replace with your image path
            fit: BoxFit.cover,
          ),
          // Gradient overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF091E3E).withOpacity(1), // Adjust opacity as needed
                  Colors.transparent,
                  Colors.transparent,
                  const Color(0xFF091E3E).withOpacity(1), // Adjust opacity as needed
                ],
              ),
            ),
          ),
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(30.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const SizedBox(
                    height: 20,
                  ),
                  Container(
                    margin: const EdgeInsets.fromLTRB(0, 0, 0, 40),
                    child: const Text(
                      "Add Employee",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.yellowAccent,
                          fontStyle: FontStyle.italic,
                          fontFamily: 'SatisfyRegular',
                          fontWeight: FontWeight.w800,
                          fontSize: 29),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      _selectProfilePicture();
                    },
                    child: Container(
                      width: 150,
                      height: 150,
                      margin: const EdgeInsets.fromLTRB(0, 0, 0, 30),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey, // Placeholder color
                      ),
                      child: _selectedImage != null
                          ? ClipOval(
                        child: Image.file(
                          _selectedImage!,
                          width: 120,
                          height: 120,
                          fit: BoxFit.cover,
                        ),
                      )
                          : const Icon(
                        Icons.person,
                        size: 80,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 0),
                  TextFormField(
                    controller: nameController,
                    keyboardType: TextInputType.text,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Name',
                      hintText: 'Enter your name here...',
                      hintStyle: const TextStyle(color: Colors.white60),
                      errorText: _validate ? 'Please enter a valid name' : null,
                      border: const OutlineInputBorder(),
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white60),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  TextFormField(
                    controller: phoneController,
                    keyboardType: TextInputType.text,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Phone',
                      hintText: 'Enter phone number here...',
                      hintStyle: const TextStyle(color: Colors.white60),
                      errorText:
                      _validate ? 'Please enter a valid phone' : null,
                      border: const OutlineInputBorder(),
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white60),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                    ),
                    maxLength: 10,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Email',
                      hintText: 'Enter your email here...',
                      hintStyle: const TextStyle(color: Colors.white60),
                      errorText:
                      _validate ? 'Please enter a valid email' : null,
                      border: const OutlineInputBorder(),
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white60),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: designationController,
                    keyboardType: TextInputType.text,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Designation',
                      hintText: 'Enter your designation here...',
                      hintStyle: const TextStyle(color: Colors.white60),
                      errorText:
                      _validate ? 'Please enter a valid designation' : null,
                      border: const OutlineInputBorder(),
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white60),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: () async {
                      // Logic to save the user profile details
                      String name = nameController.text;
                      String email = emailController.text;
                      String designation = designationController.text;
                      String phone = phoneController.text;
                      setState(() {
                        if (name.isEmpty ||
                            designation.isEmpty ||
                            email.isEmpty ||
                            _selectedImage == null) {
                          _validate = true;
                          ToastContext toastContext =
                          ToastContext(); // Creating an instance of ToastContext
                          toastContext.init(context);
                          Toast.show("Please select profile picture",
                              duration: Toast.lengthShort,
                              gravity: Toast.bottom);
                        } else {
                          _validate = false;
                          _isLoading = true;
                          // Sending OTP to the provided mobile number
                          uploadData(name, email, designation, phone);
                        }
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: const Color(0xFF091E3E),
                      backgroundColor: Colors.white,
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator()
                        : const SizedBox(
                      width: double.infinity,
                      child: Text(
                        'Save',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void uploadData(
      String name, String email, String designation, String phone) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String userUid = user.uid;
      Reference ref = FirebaseStorage.instance.ref().child(
          'profile_pictures/${DateTime.now().millisecondsSinceEpoch}.jpg');
      try {
        UploadTask uploadTask = ref.putFile(_selectedImage!);
        TaskSnapshot snapshot =
        await uploadTask; // Wait for the upload to complete
        String downloadURL = await snapshot.ref.getDownloadURL();
        CollectionReference userCollection =
        FirebaseFirestore.instance.collection('users');
        Map<String, dynamic> userData = {
          'userID': userUid,
          // Assuming userID is the auto-generated unique identifier
          'profileImageName': downloadURL,
          // String for profile image URL
          'designation': designation,
          // String for designation
          'name': name,
          // String for designation
          'email': email,
          // String for email
          'phoneNumber': phone,
          // String for phone number (set as unique)
          'work_mode': "",
          // String for phone number (set as unique)
          'attendanceLogs': [
            {
              'isCheckIn': false,
              'checkOutTime': "",
              'checkInTime': "",
            }
          ],
          // Initialize attendanceLogs as an empty array
        };
        await userCollection.doc(phone).set(userData);

        ShowToast.showToast(context, "User Created Successfully!");
        navigateToHomePage();
      } catch (error) {
        error.toString();
      }
    } else {}
  }

  void navigateToHomePage() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const HomeScreen(),
      ),
    );
  }

  void _selectProfilePicture() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedImage =
    await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        _selectedImage = File(pickedImage.path);
      });
    }
  }

  printMessage(String msg) {
    debugPrint(msg);
  }
}

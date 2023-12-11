import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rbc_atted/home_page.dart';
import 'package:rbc_atted/modals/emp_registeration_model.dart';
import 'package:rbc_atted/utility/show_toast.dart';
import 'dart:io';


class RegisterEmployee extends StatefulWidget {
  const RegisterEmployee({super.key});

  @override
  FormSectionsState createState() => FormSectionsState();
}

class FormSectionsState extends State<RegisterEmployee> {
  final _formKey = GlobalKey<FormState>();
  final PageController _pageController = PageController(initialPage: 0);
  int _currentPageIndex = 0;
  EmpRegistrationModel formData = EmpRegistrationModel();
  File? _selectedImage;
  Random random = Random();
  DateTime? selectedStartDate;
  bool _isLoading = false;
  final List<String> workMode = [
    'WFH(Work From Home)',
    'WFO(Work From Office)'
  ];
  String selectedWorkMode = 'WFH(Work From Home)';

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    DateTime? initialDate = DateTime.now();
    if (!isStartDate && selectedStartDate != null) {
      initialDate = selectedStartDate;}
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate!,
      firstDate:
      isStartDate ? DateTime.now() : selectedStartDate ?? DateTime.now(),
      lastDate:
      DateTime.now().add(const Duration(days: 365)), // One year from now
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          selectedStartDate = picked;
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      setState(() {
        _currentPageIndex = _pageController.page?.round() ?? 0;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Image.asset(
            'assets/images/background_image.jpg',
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            fit: BoxFit.cover,
          ),
          // Gradient overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF091E3E).withOpacity(0.7),
                  Colors.transparent,
                  Colors.transparent,
                  const Color(0xFF091E3E).withOpacity(0.7),
                ],
              ),
            ),
          ),
          Form(
            key: _formKey,
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildPersonalDetailsPage(),
                _buildBankDetailsPage(),
                _buildEmploymentDetails(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF091E3E),
        unselectedItemColor: Colors.white,
        selectedItemColor: Colors.yellow,
        items: [
          BottomNavigationBarItem(
            icon: _buildDot(0),
            label: 'Personal Details',
          ),
          BottomNavigationBarItem(
            icon: _buildDot(1),
            label: 'Bank Details',
          ),
          BottomNavigationBarItem(
            icon: _buildDot(2),
            label: 'Employment Details',
          ),
        ],
        currentIndex: _currentPageIndex,
        onTap: (index) {
          _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        },
      ),
    );
  }

  Widget _buildDot(int pageIndex) {
    return Icon(
      Icons.circle,
      color: _currentPageIndex == pageIndex ? Colors.yellow : Colors.white,
    );
  }

  Widget _buildPersonalDetailsPage() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Personal Details',
              style:
              TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            GestureDetector(
              onTap: () {
                _selectProfilePicture();
              },
              child: Container(
                width: 120,
                height: 120,
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
            TextFormField(
              keyboardType: TextInputType.text,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Name',
                labelStyle: TextStyle(color: Colors.white60),
                hintText: 'Enter your name here...',
                hintStyle: TextStyle(color: Colors.white60),
                border: OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white60),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter name';
                }
                return null;
              },
              onSaved: (value) {
                formData.name = value ?? '';
              },
            ),
            const SizedBox(height: 20),
            TextFormField(
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter phone';
                }
                return null;
              },
              onSaved: (value) {
                formData.phone = value ?? '';
              },
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Phone',
                labelStyle: TextStyle(color: Colors.white60),
                hintText: 'Enter phone number here...',
                hintStyle: TextStyle(color: Colors.white60),
                border: OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white60),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
              maxLength: 10,
            ),
            const SizedBox(height: 20),
            TextFormField(
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter email';
                }
                return null;
              },
              onSaved: (value) {
                formData.email = value ?? '';
              },
              keyboardType: TextInputType.emailAddress,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Email',
                labelStyle: TextStyle(color: Colors.white60),
                hintText: 'Enter email here...',
                hintStyle: TextStyle(color: Colors.white60),
                border: OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white60),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter designation';
                }
                return null;
              },
              onSaved: (value) {
                formData.designation = value ?? '';
              },
              keyboardType: TextInputType.text,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Designation',
                labelStyle: TextStyle(color: Colors.white60),
                hintText: 'Enter designation here...',
                hintStyle: TextStyle(color: Colors.white60),
                border: OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white60),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter aadhar number';
                }
                return null;
              },
              onSaved: (value) {
                formData.aadhar = value ?? '';
              },
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Aadhar Number',
                labelStyle: TextStyle(color: Colors.white60),
                hintText: 'Enter aadhar number here...',
                hintStyle: TextStyle(color: Colors.white60),
                border: OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white60),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter IFSC code';
                }
                return null;
              },
              onSaved: (value) {
                formData.pan = value ?? '';
              },
              keyboardType: TextInputType.text,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'PAN Number',
                labelStyle: TextStyle(color: Colors.white60),
                hintText: 'Enter pan number here...',
                hintStyle: TextStyle(color: Colors.white60),
                border: OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white60),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter designation';
                }
                return null;
              },
              onSaved: (value) {
                formData.workMode = selectedWorkMode;
              },
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.transparent,
                hintStyle: TextStyle(color: Colors.white),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white60),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
              value: selectedWorkMode,
              items: workMode.map((String workMode) {
                return DropdownMenuItem<String>(
                  value: workMode,
                  child: Text(
                    workMode,
                    style: TextStyle(
                      color: selectedWorkMode == workMode
                          ? Colors.green
                          : Colors
                              .black, // Set different colors based on selection
                    ),
                  ),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    selectedWorkMode = newValue;
                  });
                }
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                  );
                }
              },
              child: const Text('Next'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBankDetailsPage() {
    // Implement UI for Bank Details form
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Bank Details',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextFormField(
              keyboardType: TextInputType.text,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Bank Name',
                labelStyle: TextStyle(color: Colors.white60),
                hintText: 'Enter bank name here...',
                hintStyle: TextStyle(color: Colors.white60),
                border: OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white60),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter bank name';
                }
                return null;
              },
              onSaved: (value) {
                formData.bankName = value ?? '';
              },
            ),
            const SizedBox(height: 20),
            TextFormField(
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter account number';
                }
                return null;
              },
              onSaved: (value) {
                formData.accNo = value ?? '';
              },
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Account Number',
                labelStyle: TextStyle(color: Colors.white60),
                hintText: 'Enter account number...',
                hintStyle: TextStyle(color: Colors.white60),
                border: OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white60),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter IFSC code';
                }
                return null;
              },
              onSaved: (value) {
                formData.ifscCode = value ?? '';
              },
              keyboardType: TextInputType.text,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'IFSC Code',
                labelStyle: TextStyle(color: Colors.white60),
                hintText: 'Enter IFSC Code here...',
                hintStyle: TextStyle(color: Colors.white60),
                border: OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white60),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                  );
                }
              },
              child: const Text('Next'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmploymentDetails() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Employment Details',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextFormField(
              readOnly: true,
              onTap: () => _selectDate(context, true),
              style: const TextStyle(color: Colors.white),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter basic salary';
                }
                return null;
              },
              onSaved: (value) {
                formData.joiningDate = (value ?? '');
              },
              decoration: const InputDecoration(
                labelText: 'Joining Date',
                labelStyle: TextStyle(color: Colors.white60),

                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.transparent,
                suffixIcon: Icon(Icons.calendar_month_outlined,color: Colors.white,),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white60),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
              controller: TextEditingController(
                text: selectedStartDate != null
                    ? selectedStartDate!
                    .toLocal()
                    .toString()
                    .split(' ')[0]
                    : '',
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter basic salary';
                }
                return null;
              },
              onSaved: (value) {
                formData.basicSalary = (value ?? '');
              },
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Basic Salary',
                labelStyle: TextStyle(color: Colors.white60),
                hintText: 'Enter basic salary here...',
                hintStyle: TextStyle(color: Colors.white60),
                border: OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white60),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter HRA';
                }
                return null;
              },
              onSaved: (value) {
                formData.houseRentAllowance = (value ?? '');
              },
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'HRA(House Rent Allowance)',
                labelStyle: TextStyle(color: Colors.white60),
                hintText: 'Enter HRA here...',
                hintStyle: TextStyle(color: Colors.white60),
                border: OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white60),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter conveyance allowance';
                }
                return null;
              },
              onSaved: (value) {
                formData.conveyanceAllowance = (value ?? '');
              },
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Conveyance Allowance',
                labelStyle: TextStyle(color: Colors.white60),
                hintText: 'Enter conveyance allowance here...',
                hintStyle: TextStyle(color: Colors.white60),
                border: OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white60),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter dearness allowance';
                }
                return null;
              },
              onSaved: (value) {
                formData.dearnessAllowance = (value ?? '');
              },
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Dearness Allowance',
                labelStyle: TextStyle(color: Colors.white60),
                hintText: 'Enter dearness allowance here...',
                hintStyle: TextStyle(color: Colors.white60),
                border: OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white60),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter medical allowance';
                }
                return null;
              },
              onSaved: (value) {
                formData.medicalAllowance = (value ?? '');
              },
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Medical Allowance',
                labelStyle: TextStyle(color: Colors.white60),
                hintText: 'Enter medical allowance here...',
                hintStyle: TextStyle(color: Colors.white60),
                border: OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white60),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter other allowance';
                }
                return null;
              },
              onSaved: (value) {
                formData.otherAllowance = (value ?? '');
              },
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Other Allowance',
                labelStyle: TextStyle(color: Colors.white60),
                hintText: 'Enter other allowance here...',
                hintStyle: TextStyle(color: Colors.white60),
                border: OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white60),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter PF';
                }
                return null;
              },
              onSaved: (value) {
                formData.pf = (value ?? '');
              },
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'PF',
                labelStyle: TextStyle(color: Colors.white60),
                hintText: 'Enter PF here...',
                hintStyle: TextStyle(color: Colors.white60),
                border: OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white60),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter ESI';
                }
                return null;
              },
              onSaved: (value) {
                formData.esi = (value ?? '');
              },
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'ESI',
                labelStyle: TextStyle(color: Colors.white60),
                hintText: 'Enter ESI here...',
                hintStyle: TextStyle(color: Colors.white60),
                border: OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white60),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _isLoading = true;
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  uploadData(formData);
                }
              },
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Register'),
            ),
          ],
        ),
      ),
    );
  }

  void uploadData(EmpRegistrationModel formData) async {
    Reference ref = FirebaseStorage.instance
        .ref()
        .child('profile_pictures/${DateTime.now().millisecondsSinceEpoch}.jpg');
    try {
      String downloadURL = "";
      if (_selectedImage != null) {
        UploadTask uploadTask = ref.putFile(_selectedImage!);
        TaskSnapshot snapshot = await uploadTask;
        downloadURL = await snapshot.ref.getDownloadURL();
      }
      CollectionReference userCollection =
          FirebaseFirestore.instance.collection('users');
      Map<String, dynamic> userData = {
        'empId': random.nextInt(10000)+1,
        'name': formData.name,
        'profileImageName': downloadURL,
        'phone': formData.phone,
        'email': formData.email,
        'dob': formData.dob,
        'role': 'user',
        'workMode': selectedWorkMode,
        'pan': formData.pan,
        'aadhar': formData.aadhar,
        'bankName': formData.bankName,
        'accNo': formData.accNo,
        'ifscCode': formData.ifscCode,
        'joiningDate': formData.joiningDate,
        'designation': formData.designation,
        'basicSalary': formData.basicSalary,
        'houseRentAllowance': formData.houseRentAllowance,
        'conveyanceAllowance': formData.conveyanceAllowance,
        'dearnessAllowance': formData.dearnessAllowance,
        'medicalAllowance': formData.medicalAllowance,
        'otherAllowance': formData.otherAllowance,
        'pf': formData.pf,
        'esi': formData.esi,
        'attendanceLogs': [
          {
            'isCheckIn': false,
            'checkOutTime': 0,
            'checkInTime': 0,
          }
        ],
      };
      await userCollection.doc(formData.phone).set(userData);
      setState(() {
        _isLoading = false;
        ShowToast.showToast(context, "User registered Successfully!");
      });
      navigateToHomePage();
    } catch (error) {
      error.toString();
    }
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
}

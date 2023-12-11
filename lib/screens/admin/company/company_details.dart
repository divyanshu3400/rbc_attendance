import 'dart:io';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rbc_atted/screens/admin/company/company_detail_model.dart';
import '../../../utility/show_toast.dart';

class CompanyDetails extends StatefulWidget {
  const CompanyDetails({super.key});

  @override
  CompanyDetailsState createState() => CompanyDetailsState();
}

class CompanyDetailsState extends State<CompanyDetails> {
  File? _selectedImage;
  final _formKey = GlobalKey<FormState>();
  CompanyDetailsModel modal = CompanyDetailsModel();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  Future<CompanyDetailsModel?> fetchDetails() async {
    try {
      DatabaseReference dbRef = FirebaseDatabase.instance.ref('company').child('company_details');
      DatabaseEvent  event = await dbRef.once();
      if (event.snapshot.value != null) {
        Map<dynamic, dynamic> data = event.snapshot.value as Map<dynamic, dynamic>;
        CompanyDetailsModel fetchedModel = CompanyDetailsModel();
        fetchedModel.companyName = data['companyName'] as String? ?? '';
        fetchedModel.companyProfileImg = data['companyProfileImg'] as String? ?? '';
        fetchedModel.udayamRegNum = data['udayamRegNum'] as String? ?? '';
        fetchedModel.businessType = data['businessType'] as String? ?? '';
        fetchedModel.companyId = data['companyId'] as String? ?? '';
        fetchedModel.companyAddress = data['companyAddress'] as String? ?? '';
        fetchedModel.gstNumber = data['gstNumber'] as String? ?? '';

        return fetchedModel;
      } else {
        return null;
      }
    } catch (error) {
      return null;
    }
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
                  const Color(0xFF091E3E).withOpacity(1),
                  // Adjust opacity as needed
                  Colors.transparent,
                  Colors.transparent,
                  const Color(0xFF091E3E).withOpacity(1),
                  // Adjust opacity as needed
                ],
              ),
            ),
          ),
          Form(
            key: _formKey,
            child: PageView(
              physics: const NeverScrollableScrollPhysics(),
              children: [
                FutureBuilder<CompanyDetailsModel?>(
                  future: fetchDetails(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    } else if (snapshot.hasData && snapshot.data != null) {
                      CompanyDetailsModel fetchedModel = snapshot.data!;
                      return _buildPCompanyDetailsPage(fetchedModel);
                    } else {
                      return _buildPCompanyDetailsPage(CompanyDetailsModel());
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPCompanyDetailsPage(CompanyDetailsModel modal) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Company Details',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
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
                    : modal.companyProfileImg.isNotEmpty
                        ? ClipOval(
                            child: Image.network(
                              modal.companyProfileImg,
                              width: 120,
                              height: 120,
                              fit: BoxFit.cover,
                            ),
                          )
                        : const Icon(
                            Icons.business,
                            size: 80,
                            color: Colors.white,
                          ),
              ),
            ),
            TextFormField(
              initialValue: modal.companyName,
              keyboardType: TextInputType.text,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Company Name',
                labelStyle: TextStyle(color: Colors.white60),
                hintText: 'Enter company name here...',
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
                  return 'Please enter company name';
                }
                return null;
              },
              onSaved: (value) {
                modal.companyName = value ?? '';
              },
            ),
            const SizedBox(height: 20),
            TextFormField(
              initialValue: modal.businessType,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter business type';
                }
                return null;
              },
              onSaved: (value) {
                modal.businessType = value ?? '';
              },
              keyboardType: TextInputType.text,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Business Type',
                labelStyle: TextStyle(color: Colors.white60),
                hintText: 'Enter business type here...',
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
              initialValue: modal.companyAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please company address';
                }
                return null;
              },
              onSaved: (value) {
                modal.companyAddress = value ?? '';
              },
              keyboardType: TextInputType.emailAddress,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Company Address',
                labelStyle: TextStyle(color: Colors.white60),
                hintText: 'Enter company address here...',
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
              initialValue: modal.gstNumber,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter GST ';
                }
                return null;
              },
              onSaved: (value) {
                modal.gstNumber = value ?? '';
              },
              keyboardType: TextInputType.text,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'GST Number',
                labelStyle: TextStyle(color: Colors.white60),
                hintText: 'Enter GST here...',
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
              initialValue: modal.udayamRegNum,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter udyam register number';
                }
                return null;
              },
              onSaved: (value) {
                modal.udayamRegNum = value ?? '';
              },
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Udyam Register Number',
                labelStyle: TextStyle(color: Colors.white60),
                hintText: 'Enter udyam register number here...',
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () {},
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    _isLoading = true;
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      uploadData(modal);
                    } else {
                      _isLoading = false;
                    }
                  },
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Save'),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  void uploadData(CompanyDetailsModel modal) async {
    final DatabaseReference attendanceReference =
        FirebaseDatabase.instance.ref('company');
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
      modal.companyProfileImg = downloadURL;
      await attendanceReference.child("company_details").set(modal.toJson());
      setState(() {
        _isLoading = false;
        ShowToast.showToast(context, "Company Details Saved!");
      });
    } catch (error) {
      error.toString();
    }
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

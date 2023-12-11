import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:rbc_atted/modals/add_branch_modal.dart';
import 'package:geolocator/geolocator.dart';
import '../../../utility/show_toast.dart';

class AddBranchForm extends StatefulWidget {
  const AddBranchForm({super.key});

  @override
  AddBranchFormState createState() => AddBranchFormState();
}

class AddBranchFormState extends State<AddBranchForm> {
  AddBranchModel model = AddBranchModel();

  bool _isLoading = false;

  final _formKey = GlobalKey<FormState>();
  String title = '';
  double latitude = 0.0;
  double longitude = 0.0;
  double selectedRange = 100.0;
  final List<double> ranges = [50.0, 100.0, 150.0, 200.0];


  @override
  void initState() {
    super.initState();
    getLocation();
  }


  Future<Position> getLocation() async {
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    print("current position of the device is : $position");
    return position;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
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
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    keyboardType: TextInputType.text,
                    cursorColor: Colors.white70,
                    style: const TextStyle(color: Colors.white),

                    decoration: InputDecoration(
                        labelText: 'Title',
                        labelStyle: const TextStyle(color: Colors.white70),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(7),
                        ),
                        hintText: "Enter title here",
                        hintStyle: const TextStyle(color: Colors.white70),
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white60),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a title';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      model.title = value!;
                    },
                  ),
                 const SizedBox(height: 20,),
                  TextFormField(
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                        labelText: 'Latitude',
                        labelStyle: const TextStyle(color: Colors.white70),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(7),
                        ),
                        hintText: "Enter latitude here",
                        hintStyle: const TextStyle(color: Colors.white70),
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white60),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter latitude';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      model.latitude = double.parse(value!);
                    },
                  ),
                 const SizedBox(height: 20,),

                  TextFormField(
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                        labelText: 'Longitude',
                        labelStyle: const TextStyle(color: Colors.white70),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(7),
                        ),
                        hintText: "Enter longitude here",
                        hintStyle: const TextStyle(color: Colors.white70),
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white60),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter longitude';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      model.longitude = double.parse(value!);
                    },
                  ),
                  const SizedBox(height: 20,),

                  DropdownButtonFormField<double>(
                    value: selectedRange,
                    onChanged: (value) {
                      setState(() {
                        selectedRange = value!;
                      });
                    },
                    onSaved: (value) {
                      model.selectedRange = value!;
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

                    items: ranges.map((range) {
                      return DropdownMenuItem<double>(
                        value: range,
                        child: Text('$range meters',
                          style: TextStyle(
                            color: selectedRange == range ? Colors.deepPurple : Colors.black, // Set different colors based on selection
                          ),),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      _isLoading = true;
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        saveBranch(model);
                        // print(model.toJson());
                      }
                      else{
                        _isLoading = false;
                      }
                    },
                    child: _isLoading ?const CircularProgressIndicator() : const Text('Save Branch'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void saveBranch(AddBranchModel model) async{
    final DatabaseReference branchRef =
    FirebaseDatabase.instance.ref('company');

      await branchRef.child("branch_details").push().set(model.toJson());
      setState(() {
        _isLoading = false;
        ShowToast.showToast(context, "Branch Details Saved!");
      });
  }
}

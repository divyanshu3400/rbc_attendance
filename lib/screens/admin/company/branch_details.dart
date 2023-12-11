import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class AddBranchMapForm extends StatefulWidget {
  const AddBranchMapForm({super.key});

  @override
  _AddBranchMapFormState createState() => _AddBranchMapFormState();
}

class _AddBranchMapFormState extends State<AddBranchMapForm> {
  final _formKey = GlobalKey<FormState>();
  String title = '';
  LatLng selectedLocation = LatLng(0.0, 0.0); // Default location

  GoogleMapController? mapController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: GoogleMap(
              initialCameraPosition: const CameraPosition(
                target: LatLng(0.0, 0.0), // Initial map location
                zoom: 15.0,
              ),
              onMapCreated: (controller) {
                setState(() {
                  mapController = controller;
                });
              },
              onTap: (LatLng location) {
                setState(() {
                  selectedLocation = location;
                });
                _updateMapLocation(location);
              },
              markers: {
                Marker(
                  markerId: const MarkerId('branch_location'),
                  position: selectedLocation,
                  draggable: true,
                  onDragEnd: (newLocation) {
                    setState(() {
                      selectedLocation = newLocation;
                    });
                  },
                ),
              },
            ),
          ),
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Title'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a title';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        title = value!;
                      },
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Latitude: ${selectedLocation.latitude}',
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Longitude: ${selectedLocation.longitude}',
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();
                          // Save branch details to Firebase Realtime Database
                          // Example: FirebaseDatabase.instance.reference().child('branches').push().set({...});
                        }
                      },
                      child: const Text('Save'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _updateMapLocation(LatLng location) {
    mapController?.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(
        target: location,
        zoom: 15.0,
      ),
    ));
  }
}

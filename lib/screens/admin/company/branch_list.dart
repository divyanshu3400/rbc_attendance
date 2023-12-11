import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:rbc_atted/modals/add_branch_modal.dart';
import 'package:rbc_atted/screens/admin/company/add_branch.dart';


class BranchList extends StatelessWidget {
  const BranchList({Key? key}) : super(key: key);


  Future<List<AddBranchModel>> _fetchBranches() async {
    DatabaseReference dbRef = FirebaseDatabase.instance.ref('company').child('branch_details');
    List<AddBranchModel> branches = [];
    try {
      DatabaseEvent event = await dbRef.once();
      Map<dynamic, dynamic>? values = event.snapshot.value as Map<dynamic, dynamic>?;

      if (values != null) {
        values.forEach((key, value) {
          AddBranchModel model = AddBranchModel();
          model.title = value['title'];
          model.latitude = (value['lat'] as num).toDouble(); // Cast 'lat' to double
          model.longitude = (value['lon'] as num).toDouble(); // Cast 'lon' to double
          model.selectedRange = (value['range'] as num).toDouble(); // Cast 'range' to double
          branches.add(model);
        });
      }
    } catch (e) {
      // Handle errors if any
      throw('Error fetching branches: $e');
    }

    return branches;
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

          FutureBuilder<List<AddBranchModel>>(
            future: _fetchBranches(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No employees found.', style: TextStyle(color: Colors.white),));
              } else {
                List<AddBranchModel>? branches = snapshot.data;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        'Total Branches',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: branches!.length,
                        itemBuilder: (context, index) {
                          return AddBranchModelTile(modal: branches[index]);
                        },
                      ),
                    ),
                  ],
                );
              }
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            PageRouteBuilder(
              transitionDuration: const Duration(milliseconds: 500),
              pageBuilder: (_, __, ___) =>  const AddBranchForm(),
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

        },
        child: Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

class AddBranchModelTile extends StatelessWidget {
  final AddBranchModel modal;

  const AddBranchModelTile({Key? key, required this.modal}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white12,
      elevation: 5,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: Container(
          width: 100,
          child: Column(
            children: [
              Text(
                "${modal.selectedRange}",
                style: const TextStyle(color: Colors.white, fontSize: 18),
                overflow: TextOverflow.ellipsis, // Handle overflow text if necessary
              ),
              const Text(
                "meters radius",
                style: TextStyle(color: Colors.white, fontSize: 14),
                overflow: TextOverflow.ellipsis, // Handle overflow text if necessary
              ),
            ],
          )
        ),

        title: Text(
          modal.title,
          style: const TextStyle(color: Colors.white, fontSize: 18),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Latitude: ${modal.latitude}',
              style: const TextStyle(color: Colors.white70),
            ),
            Text(
              'Longitude: ${modal.longitude}',
              style: const TextStyle(color: Colors.white70),
            ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward, color: Colors.white70),
        onTap: () {
          // Handle onTap action if needed
        },
      ),
    );
  }
}

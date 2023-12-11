import 'package:flutter/material.dart';
import 'add_branch.dart';
import 'branch_details.dart';
import 'branch_list.dart';
import 'company_details.dart';


class CompanyDetailsScreen extends StatefulWidget {
  const CompanyDetailsScreen({super.key});

  @override
  CompanyDetailsScreenState createState() => CompanyDetailsScreenState();
}

class CompanyDetailsScreenState extends State<CompanyDetailsScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _currentIndex == 0
          ? const CompanyDetails() // Display CompanyDetails widget
          : const BranchList(), // Display BranchDetails widget
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF091E3E),
        unselectedItemColor: Colors.white,
        selectedItemColor: Colors.yellow,
        currentIndex: _currentIndex,
        onTap: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.business),
            label: 'Company',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.location_on),
            label: 'Branches',
          ),
        ],
      ),
    );
  }
}


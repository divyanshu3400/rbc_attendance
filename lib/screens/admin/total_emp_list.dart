import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../modals/total_employee_modal.dart';
import 'emp_detail.dart';

class TotalEmpList extends StatelessWidget {
  const TotalEmpList({Key? key}) : super(key: key);

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

          FutureBuilder<List<Employee>>(
            future: fetchEmployeesFromFirestore(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No employees found.'));
              } else {
                List<Employee>? employees = snapshot.data;
                return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          'Total Employees',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: employees!.length,
                          itemBuilder: (context, index) {
                            return EmployeeTile(employee: employees[index]);
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
    );
  }

  Future<List<Employee>> fetchEmployeesFromFirestore() async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('users').get();
    List<Employee> employees = [];
    for (var doc in querySnapshot.docs) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      List<dynamic> attendanceLogs = data['attendanceLogs'];
      var log = attendanceLogs.last;
      var checkOut = log['checkOutTime'].toString();
      var checkIn = log['checkInTime'].toString();

      Employee employee =  Employee(
          data['name'] ?? '',
          data['designation'] ?? '',
          data['email'] ?? '',
          data['phone'] ?? '',
          data['profileImageName'] ?? '',
          checkIn,
          checkOut,
          log['isCheckIn'],
        false,
      );
      employees.add(employee);
    }
    return employees;
  }
}

class EmployeeTile extends StatelessWidget {
  final Employee employee;

  const EmployeeTile({Key? key, required this.employee}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white12,
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          radius: 40,
          backgroundImage: NetworkImage(employee.profilePic)
        ),
        title: Text(
          employee.name,
          style: const TextStyle(color: Colors.white, fontSize: 18),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Designation: ${employee.designation}',
              style: const TextStyle(color: Colors.white70),
            ),
            Text(
              'Email: ${employee.email}',
              style: const TextStyle(color: Colors.white70),
            ),
            Text(
              'Phone: ${employee.phone}',
              style: const TextStyle(color: Colors.white70),
            ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward, color: Colors.white70),
        onTap: () {
          Navigator.push(
            context,
            PageRouteBuilder(
              transitionDuration: const Duration(milliseconds: 400),
              pageBuilder: (_, __, ___) => EmployeeDetails(employee: employee,),
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
      ),
    );
  }
}

import 'package:attandance/screen/attendance_screen.dart';
import 'package:attandance/screen/student_detail.dart';
import 'package:flutter/material.dart';
import 'registration_screen.dart';
// Import your Attendance screen as well

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        backgroundColor: Colors.blue[300],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: GridView.count(
            crossAxisCount: 3, // 3 columns in the grid
            crossAxisSpacing: 10.0,
            mainAxisSpacing: 10.0,
            children: [
              _buildGridButton(
                context,
                icon: Icons.people,
                label: 'Student Details',
                screen: const StudentDetailScreen(),
              ),
              _buildGridButton(
                context,
                icon: Icons.app_registration,
                label: 'Register',
                screen: const RegistrationScreen(),
              ),
              _buildGridButton(
                context,
                icon: Icons.access_time,
                label: 'Attendance',
                screen: const AttendanceScreen(), // Add your Attendance Screen
              ),
              // Add more buttons if needed
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to create grid buttons
  Widget _buildGridButton(BuildContext context,
      {required IconData icon, required String label, required Widget screen}) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => screen),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.blue[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.blue, width: 2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.blue[700]),
            const SizedBox(height: 10),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.blue,
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

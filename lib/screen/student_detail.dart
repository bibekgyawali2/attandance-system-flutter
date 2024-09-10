import 'dart:io';

import 'package:flutter/material.dart';

import '../databse/student_database.dart';

class StudentDetailScreen extends StatefulWidget {
  const StudentDetailScreen({super.key});

  @override
  State<StudentDetailScreen> createState() => _StudentDetailScreenState();
}

class _StudentDetailScreenState extends State<StudentDetailScreen> {
  List<Student> _students = [];

  @override
  void initState() {
    super.initState();
    _fetchStudents(); // Fetch students when the screen loads
  }

  // Method to fetch students from the database
  Future<void> _fetchStudents() async {
    final List<Student> students =
        await StudentDatabase.instance.getAllStudents();
    setState(() {
      _students = students;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registered Students'),
      ),
      body: _students.isEmpty
          ? const Center(
              child: Text('No students registered yet.'),
            )
          : ListView.builder(
              itemCount: _students.length,
              itemBuilder: (context, index) {
                final student = _students[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  elevation: 3,
                  child: ListTile(
                    leading: student.faceImagePath.isNotEmpty
                        ? CircleAvatar(
                            radius: 30,
                            backgroundImage:
                                FileImage(File(student.faceImagePath)),
                          )
                        : const CircleAvatar(
                            radius: 30,
                            child: Icon(Icons.person),
                          ),
                    title: Text(student.name),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Student ID: ${student.studentId}'),
                        Text('Email: ${student.email}'),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

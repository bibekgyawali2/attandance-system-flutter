import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

import '../databse/student_database.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final TextEditingController _studentIdController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  XFile? _pickedImage;
  FaceDetector? faceDetector;
  List<Face>? _detectedFaces;

  @override
  void initState() {
    super.initState();
    faceDetector = FaceDetector(
      options: FaceDetectorOptions(
        performanceMode: FaceDetectorMode.accurate,
        enableLandmarks: true,
        enableContours: true,
      ),
    );
  }

  @override
  void dispose() {
    faceDetector?.close();
    super.dispose();
  }

  // Method to pick image from the camera
  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);

    if (image != null) {
      setState(() {
        _pickedImage = image;
      });
      _detectFaces(image);
    }
  }

  // Detect faces in the selected image
  Future<void> _detectFaces(XFile image) async {
    final inputImage = InputImage.fromFile(File(image.path));
    final faces = await faceDetector!.processImage(inputImage);

    setState(() {
      _detectedFaces = faces;
    });

    if (faces.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No faces detected. Please try again.')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Face detected successfully!')),
      );
    }
  }

  // Method to submit the form and store the student details
  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate() &&
        _pickedImage != null &&
        _detectedFaces != null &&
        _detectedFaces!.isNotEmpty) {
      // Convert facial landmarks from Offset to Point<int>
      List<Point<int>> landmarks = _detectedFaces!.first.landmarks.values
          .map((landmark) => Point<int>(
                landmark!.position.x.round(),
                landmark.position.y.round(),
              ))
          .toList();

      // Create Student object
      Student newStudent = Student(
        studentId: _studentIdController.text,
        name: _nameController.text,
        email: _emailController.text,
        faceImagePath: _pickedImage!.path,
        facialLandmarks: landmarks, // Pass the converted landmarks here
      );

      // Save to database
      await StudentDatabase.instance.addStudent(newStudent);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registration Successful!')),
      );

      // Clear the form and image after successful registration
      _formKey.currentState!.reset();
      setState(() {
        _pickedImage = null;
        _detectedFaces = null;
      });
    } else if (_pickedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload your face image.')),
      );
    } else if (_detectedFaces == null || _detectedFaces!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No faces detected in the image.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Registration'),
        backgroundColor: Colors.blue[300],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Text(
                'Register Your Details',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 20),

              // Student ID Input Field
              TextFormField(
                controller: _studentIdController,
                decoration: const InputDecoration(
                  labelText: 'Student ID',
                  prefixIcon: Icon(Icons.badge),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your Student ID';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Email Input Field
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Name Input Field
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Face Image Input Section
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.blue[300]!,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: _pickedImage == null
                        ? Icon(
                            Icons.camera_alt,
                            size: 50,
                            color: Colors.blue[300],
                          )
                        : Image.file(
                            File(_pickedImage!.path),
                            fit: BoxFit.cover,
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitForm,
                  child: const Text('Submit'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

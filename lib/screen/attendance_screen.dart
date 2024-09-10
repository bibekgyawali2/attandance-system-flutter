import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:intl/intl.dart';

import '../helper/database_helper.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  XFile? _pickedImage;
  FaceDetector? _faceDetector;
  List<Face>? _detectedFaces;
  bool _isFaceMatched = false;
  String _studentDetail = '';
  String _checkInTime = '';

  @override
  void initState() {
    super.initState();
    _faceDetector = FaceDetector(
      options: FaceDetectorOptions(
        performanceMode: FaceDetectorMode.accurate,
        enableLandmarks: true,
        enableContours: true,
      ),
    );
  }

  @override
  void dispose() {
    _faceDetector?.close();
    super.dispose();
  }

  // Method to pick an image from the camera
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);

    if (image != null) {
      setState(() {
        _pickedImage = image;
      });
      _detectFaces(image);
    }
  }

  // Method to detect faces in the picked image
  Future<void> _detectFaces(XFile image) async {
    final inputImage = InputImage.fromFile(File(image.path));
    try {
      final faces = await _faceDetector!.processImage(inputImage);
      setState(() {
        _detectedFaces = faces;
      });

      if (faces.isEmpty) {
        _showSnackBar('No faces detected. Please try again.');
      } else {
        _matchFaceWithRegisteredUser();
      }
    } catch (e) {
      _showSnackBar('Error detecting faces. Please try again.');
    }
  }

  // Face matching logic (to be replaced with actual implementation)
  void _matchFaceWithRegisteredUser() async {
    if (_detectedFaces != null && _detectedFaces!.isNotEmpty) {
      final detectedFace = _detectedFaces!.first;

      try {
        // Replace with actual face comparison logic
        final registeredStudent =
            await DatabaseHelper.getMatchingStudent(detectedFace);

        if (registeredStudent != null) {
          setState(() {
            _isFaceMatched = true;
            _studentDetail =
                '${registeredStudent['name']} (ID: ${registeredStudent['studentId']})';
            _checkInTime = DateFormat('hh:mm a').format(DateTime.now());
          });
          _showSnackBar('Face matched! Check-in successful.');
        } else {
          setState(() {
            _isFaceMatched = false;
          });
          _showSnackBar('No matching user found.');
        }
      } catch (e) {
        setState(() {
          _isFaceMatched = false;
        });
        _showSnackBar('Error matching face. Please try again.');
      }
    } else {
      _showSnackBar('No face detected for matching.');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Face Recognition Demo'),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Display the picked image or face icon
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.blue, width: 4),
                ),
                child: _pickedImage == null
                    ? Icon(
                        Icons.face,
                        size: 100,
                        color: Colors.blue[300],
                      )
                    : ClipOval(
                        child: Image.file(
                          File(_pickedImage!.path),
                          fit: BoxFit.cover,
                        ),
                      ),
              ),
              const SizedBox(height: 30),
              // Button to trigger face recognition
              ElevatedButton.icon(
                icon: const Icon(Icons.camera_alt),
                label: const Text('Check In'),
                onPressed: _pickImage,
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // Display matching result
              if (_isFaceMatched)
                Column(
                  children: [
                    Text(
                      'Student Detail: $_studentDetail',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Check-in Time: $_checkInTime',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

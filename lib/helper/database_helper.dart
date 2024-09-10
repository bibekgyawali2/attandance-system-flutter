import 'dart:math';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

import '../databse/student_database.dart';

class DatabaseHelper {
  // This method compares the detected face's landmarks to the stored landmarks in the database
  static Future<Map<String, String>?> getMatchingStudent(
      Face detectedFace) async {
    // Retrieve all students from the database
    List<Student> students = await StudentDatabase.instance.getAllStudents();

    // Loop through each stored student and compare their facial landmarks
    for (Student student in students) {
      if (_compareFacialLandmarks(detectedFace, student.facialLandmarks)) {
        // If a match is found, return the student's data
        return {
          'studentId': student.studentId,
          'name': student.name,
          'email': student.email,
        };
      }
    }
    return null; // No match found
  }

  // Improved comparison method using Euclidean distance
  static bool _compareFacialLandmarks(
      Face detectedFace, List<Point<int>> storedLandmarks) {
    // Extract the detected face's landmarks
    List<Point<int>> detectedLandmarks = detectedFace.landmarks.values
        .map((landmark) => Point<int>(
              landmark!.position.x.round(),
              landmark.position.y.round(),
            ))
        .toList();

    // Check if both have the same number of landmarks
    if (detectedLandmarks.length != storedLandmarks.length) {
      print(":::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::");
      print(detectedLandmarks);
      return false;
    }

    // Define a threshold for Euclidean distance (tolerance for "similar" points)
    const double distanceThreshold = 400.0;

    // Compare each corresponding landmark by calculating the Euclidean distance
    for (int i = 0; i < detectedLandmarks.length; i++) {
      double distance =
          _calculateEuclideanDistance(detectedLandmarks[i], storedLandmarks[i]);

      // If the distance between landmarks exceeds the threshold, return false
      if (distance > distanceThreshold) {
        print("====================================");
        print(detectedLandmarks);
        print("====================================");
        print(storedLandmarks);
        return false;
      }
    }

    return true; // Landmarks are considered similar if all distances are within the threshold
  }

  // Method to calculate Euclidean distance between two points
  static double _calculateEuclideanDistance(
      Point<int> point1, Point<int> point2) {
    return sqrt(pow(point1.x - point2.x, 2) + pow(point1.y - point2.y, 2));
  }
}

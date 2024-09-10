import 'dart:math';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import '../databse/student_database.dart';

class DatabaseHelper {
  // This method compares the detected face's landmarks to the stored landmarks in the database
  static Future<Map<String, String>?> getMatchingStudent(
      Face detectedFace) async {
    // Retrieve all students from the database
    List<Student> students = await StudentDatabase.instance.getAllStudents();

    // For simplicity, this example compares facial landmarks. You may want to use a more advanced method.
    for (Student student in students) {
      if (_compareFacialLandmarks(detectedFace, student.facialLandmarks)) {
        // If the face matches, return the student's data
        return {
          'studentId': student.studentId,
          'name': student.name,
          'email': student.email,
        };
      }
    }
    return null; // No match found
  }

  // Simple landmark comparison method (this can be enhanced)
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
      return false;
    }

    // Compare landmarks (this is just a basic comparison, improve as needed)
    for (int i = 0; i < detectedLandmarks.length; i++) {
      if (detectedLandmarks[i] != storedLandmarks[i]) {
        return false;
      }
    }

    return true; // The landmarks match
  }
}

import 'dart:io';
import 'dart:convert';
import 'dart:math'; // Import dart:math to use Point<int>
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class Student {
  final int? id;
  final String studentId;
  final String name;
  final String email;
  final String faceImagePath;
  final List<Point<int>> facialLandmarks;

  Student({
    this.id,
    required this.studentId,
    required this.name,
    required this.email,
    required this.faceImagePath,
    required this.facialLandmarks,
  });

  // Convert Student object to a Map for database insertion
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'studentId': studentId,
      'name': name,
      'email': email,
      'faceImagePath': faceImagePath,
      'facialLandmarks': jsonEncode(facialLandmarks
          .map((p) => {'x': p.x, 'y': p.y})
          .toList()), // Serialize landmarks
    };
  }

  // Create Student object from database Map
  factory Student.fromMap(Map<String, dynamic> map) {
    return Student(
      id: map['id'],
      studentId: map['studentId'],
      name: map['name'],
      email: map['email'],
      faceImagePath: map['faceImagePath'],
      facialLandmarks: (jsonDecode(map['facialLandmarks']) as List<dynamic>)
          .map((point) => Point<int>(point['x'], point['y']))
          .toList(), // Deserialize landmarks
    );
  }
}

// Helper function to convert facial landmarks from Offset to Point<int>
List<Point<int>> convertLandmarksToPoints(List<FaceLandmark> landmarks) {
  return landmarks
      .map((landmark) => Point<int>(
            landmark.position.x.round(), // Convert dx to int
            landmark.position.y.round(), // Convert dy to int
          ))
      .toList();
}

// Database Helper class
class StudentDatabase {
  static final StudentDatabase instance = StudentDatabase._init();
  static Database? _database;

  StudentDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('students.db');
    return _database!;
  }

  // Initialize the database
  Future<Database> _initDB(String fileName) async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, fileName);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  // Create students table
  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE students (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        studentId TEXT NOT NULL,
        name TEXT NOT NULL,
        email TEXT NOT NULL,
        faceImagePath TEXT NOT NULL,
        facialLandmarks TEXT NOT NULL
      )
    ''');
  }

  // Insert student into database
  Future<void> addStudent(Student student) async {
    final db = await instance.database;
    await db.insert('students', student.toMap());
  }

  // Get all students
  Future<List<Student>> getAllStudents() async {
    final db = await instance.database;
    final List<Map<String, dynamic>> result = await db.query('students');
    return result.map((map) => Student.fromMap(map)).toList();
  }

  // Close the database connection
  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}

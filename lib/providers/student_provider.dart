import 'package:flutter/material.dart';
import '../database_helper.dart';
import '../student_model.dart';

class StudentProvider with ChangeNotifier {
  List<Student> _students = [];
  bool _isLoading = false; // Add isLoading property

  final DatabaseHelper _dbHelper; // Made private and final

  // Constructor to allow injecting DatabaseHelper for testing
  StudentProvider({DatabaseHelper? databaseHelper})
    : _dbHelper = databaseHelper ?? DatabaseHelper();

  List<Student> get students => _students;
  bool get isLoading => _isLoading; // Getter for isLoading

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<List<Student>> fetchStudents() async {
    _setLoading(true);
    _students = await _dbHelper.getStudents();
    _setLoading(false);
    return _students;
  }

  Future<void> searchStudents(String query, {String? classId}) async {
    _setLoading(true);
    final int? classIdInt = classId == null ? null : int.tryParse(classId);
    _students = await _dbHelper.searchStudents(query, classId: classIdInt);
    _setLoading(false);
  }

  Future<bool> addStudent(Student student) async {
    _setLoading(true);
    // Check for email uniqueness before adding
    if (student.email != null && student.email!.isNotEmpty) {
      final existingStudent = await _dbHelper.getStudentByEmail(student.email!);
      if (existingStudent != null) {
        _setLoading(false);
        throw Exception('البريد الإلكتروني موجود بالفعل.');
      }
    }
    await _dbHelper.createStudent(student);
    await fetchStudents(); // Refresh the list
    _setLoading(false);
    return true;
  }

  Future<bool> updateStudent(Student student) async {
    _setLoading(true);
    // Check for email uniqueness before updating, excluding the current student
    if (student.email != null && student.email!.isNotEmpty) {
      final existingStudent = await _dbHelper.getStudentByEmail(student.email!);
      if (existingStudent != null && existingStudent.id != student.id) {
        _setLoading(false);
        throw Exception('البريد الإلكتروني موجود بالفعل.');
      }
    }
    await _dbHelper.updateStudent(student);
    await fetchStudents(); // Refresh the list
    _setLoading(false);
    return true;
  }

  Future<void> deleteStudent(int id) async {
    _setLoading(true);
    await _dbHelper.deleteStudent(id);
    await fetchStudents(); // Refresh the list
    _setLoading(false);
  }

  Future<void> fetchStudentsByParent(int parentUserId) async {
    _setLoading(true);
    _students = await _dbHelper.getStudentsByParentUserId(parentUserId);
    _setLoading(false);
  }
  
  Future<void> clearStudents() async {
    _setLoading(true);
    _students = [];
    _setLoading(false);
  }

  // New method to check email uniqueness (can be used by UI directly)
  Future<bool> checkEmailUnique(String email, [int? currentStudentId]) async {
    _setLoading(true);
    final existingStudent = await _dbHelper.getStudentByEmail(email);
    _setLoading(false);
    if (existingStudent == null) {
      return true; // Email is unique
    }
    // If editing, allow the current student to keep their email
    return existingStudent.id == currentStudentId;
  }

  Future<Student?> getStudentByUserId(int userId) async {
    _setLoading(true);
    final result = await _dbHelper.getStudentByUserId(userId);
    _setLoading(false);
    return result;
  }
}

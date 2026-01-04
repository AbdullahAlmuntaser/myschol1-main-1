import 'package:flutter/material.dart';
import '../database_helper.dart';
import '../student_model.dart';
import '../services/local_auth_service.dart'; // Import auth service

class StudentProvider with ChangeNotifier {
  List<Student> _students = [];
  bool _isLoading = false;

  final DatabaseHelper _dbHelper;
  final LocalAuthService _authService; // Add auth service instance

  StudentProvider({
    DatabaseHelper? databaseHelper,
    required LocalAuthService authService, // Make auth service required
  })
    : _dbHelper = databaseHelper ?? DatabaseHelper(),
      _authService = authService;

  List<Student> get students => _students;
  bool get isLoading => _isLoading;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // Private method to check for admin authorization
  void _checkAdminAuthorization() {
    final userRole = _authService.currentUser?.role;
    if (userRole != 'admin') {
      throw Exception('Unauthorized: Only admins can perform this action.');
    }
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
    _checkAdminAuthorization(); // Check permissions
    _setLoading(true);
    if (student.email != null && student.email!.isNotEmpty) {
      final existingStudent = await _dbHelper.getStudentByEmail(student.email!);
      if (existingStudent != null) {
        _setLoading(false);
        throw Exception('البريد الإلكتروني موجود بالفعل.');
      }
    }
    await _dbHelper.createStudent(student);
    await fetchStudents();
    _setLoading(false);
    return true;
  }

  Future<bool> updateStudent(Student student) async {
    _checkAdminAuthorization(); // Check permissions
    _setLoading(true);
    if (student.email != null && student.email!.isNotEmpty) {
      final existingStudent = await _dbHelper.getStudentByEmail(student.email!);
      if (existingStudent != null && existingStudent.id != student.id) {
        _setLoading(false);
        throw Exception('البريد الإلكتروني موجود بالفعل.');
      }
    }
    await _dbHelper.updateStudent(student);
    await fetchStudents();
    _setLoading(false);
    return true;
  }

  Future<void> deleteStudent(int id) async {
    _checkAdminAuthorization(); // Check permissions
    _setLoading(true);
    await _dbHelper.deleteStudent(id);
    await fetchStudents();
    _setLoading(false);
  }

  // Read-only methods do not need authorization checks

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

  Future<bool> checkEmailUnique(String email, [int? currentStudentId]) async {
    _setLoading(true);
    final existingStudent = await _dbHelper.getStudentByEmail(email);
    _setLoading(false);
    if (existingStudent == null) {
      return true;
    }
    return existingStudent.id == currentStudentId;
  }

  Future<Student?> getStudentByUserId(int userId) async {
    _setLoading(true);
    final result = await _dbHelper.getStudentByUserId(userId);
    _setLoading(false);
    return result;
  }
}

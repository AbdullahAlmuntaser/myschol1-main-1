import 'package:flutter/material.dart';
import '../database_helper.dart';
import '../teacher_model.dart';
import '../services/local_auth_service.dart'; // Import auth service

class TeacherProvider with ChangeNotifier {
  List<Teacher> _teachers = [];
  final DatabaseHelper _dbHelper;
  final LocalAuthService _authService; // Add auth service

  TeacherProvider({
    DatabaseHelper? databaseHelper,
    required LocalAuthService authService, // Require auth service
  }) : _dbHelper = databaseHelper ?? DatabaseHelper(),
       _authService = authService;


  List<Teacher> get teachers => _teachers;

  // Private method to check for admin authorization
  void _checkAdminAuthorization() {
    final userRole = _authService.currentUser?.role;
    if (userRole != 'admin') {
      throw Exception('Unauthorized: Only admins can perform this action.');
    }
  }

  Future<void> fetchTeachers() async {
    _teachers = await _dbHelper.getTeachers();
    notifyListeners();
  }

  Future<void> addTeacher(Teacher teacher) async {
    _checkAdminAuthorization(); // Check permissions
    await _dbHelper.createTeacher(teacher);
    await fetchTeachers();
  }

  Future<void> updateTeacher(Teacher teacher) async {
    _checkAdminAuthorization(); // Check permissions
    await _dbHelper.updateTeacher(teacher);
    await fetchTeachers();
  }

  Future<void> deleteTeacher(int id) async {
    _checkAdminAuthorization(); // Check permissions
    await _dbHelper.deleteTeacher(id);
    await fetchTeachers();
  }

  // Read-only methods do not need authorization checks

  Future<void> searchTeachers(String name, {String? subject}) async {
    _teachers = await _dbHelper.searchTeachers(name, subject: subject);
    notifyListeners();
  }

  Future<void> fetchTeachersForClass(int classId) async {
    _teachers = await _dbHelper.getTeachersForClass(classId);
    notifyListeners();
  }

  void clearTeachers() {
    _teachers = [];
    notifyListeners();
  }

  Future<Teacher?> getTeacherByUserId(int userId) async {
    return await _dbHelper.getTeacherByUserId(userId);
  }
}

import 'package:flutter/material.dart';
import '../database_helper.dart';
import '../class_model.dart';
import '../custom_exception.dart';
import '../services/local_auth_service.dart'; // Import auth service

class ClassProvider with ChangeNotifier {
  List<SchoolClass> _classes = [];
  bool _isLoading = false;
  final DatabaseHelper _dbHelper;
  final LocalAuthService _authService; // Add auth service

  ClassProvider({
    DatabaseHelper? databaseHelper,
    required LocalAuthService authService, // Require auth service
  }) : _dbHelper = databaseHelper ?? DatabaseHelper(),
       _authService = authService;

  List<SchoolClass> get classes => _classes;
  bool get isLoading => _isLoading;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _checkAdminAuthorization() {
    final userRole = _authService.currentUser?.role;
    if (userRole != 'admin') {
      throw Exception('Unauthorized: Only admins can perform this action.');
    }
  }

  Future<void> fetchClasses() async {
    _setLoading(true);
    _classes = await _dbHelper.getClasses();
    _setLoading(false);
  }

  Future<void> searchClasses(String query) async {
    _setLoading(true);
    if (query.isEmpty) {
      await fetchClasses();
    } else {
      _classes = await _dbHelper.searchClasses(query);
      notifyListeners();
    }
    _setLoading(false);
  }

  Future<void> addClass(SchoolClass schoolClass) async {
    _checkAdminAuthorization(); // Check permissions
    _setLoading(true);
    final existingClass = await _dbHelper.getClassByClassIdString(schoolClass.classId);
    if (existingClass != null) {
      _setLoading(false);
      throw CustomException('معرف الفصل موجود بالفعل. الرجاء إدخال معرف فريد.');
    }
    await _dbHelper.createClass(schoolClass);
    await fetchClasses();
    _setLoading(false);
  }

  Future<void> updateClass(SchoolClass schoolClass) async {
    _checkAdminAuthorization(); // Check permissions
    _setLoading(true);
    await _dbHelper.updateClass(schoolClass);
    await fetchClasses();
    _setLoading(false);
  }

  Future<void> deleteClass(int id) async {
    _checkAdminAuthorization(); // Check permissions
    _setLoading(true);
    await _dbHelper.deleteClass(id);
    await fetchClasses();
    _setLoading(false);
  }

  Future<SchoolClass?> getClassByClassIdString(String classId) async {
    _setLoading(true);
    final result = await _dbHelper.getClassByClassIdString(classId);
    _setLoading(false);
    return result;
  }
}

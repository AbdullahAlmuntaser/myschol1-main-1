import 'package:flutter/material.dart';
import '../database_helper.dart';
import '../class_model.dart';
import '../custom_exception.dart';

class ClassProvider with ChangeNotifier {
  List<SchoolClass> _classes = [];
  bool _isLoading = false; // Add isLoading property
  final DatabaseHelper _dbHelper;

  ClassProvider({DatabaseHelper? databaseHelper})
      : _dbHelper = databaseHelper ?? DatabaseHelper();

  List<SchoolClass> get classes => _classes;
  bool get isLoading => _isLoading; // Getter for isLoading

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
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
    _setLoading(true);
    final existingClass =
        await _dbHelper.getClassByClassIdString(schoolClass.classId);
    if (existingClass != null) {
      _setLoading(false);
      throw CustomException('معرف الفصل موجود بالفعل. الرجاء إدخال معرف فريد.');
    }
    await _dbHelper.createClass(schoolClass);
    await fetchClasses();
    _setLoading(false);
  }

  Future<void> updateClass(SchoolClass schoolClass) async {
    _setLoading(true);
    await _dbHelper.updateClass(schoolClass);
    await fetchClasses();
    _setLoading(false);
  }

  Future<void> deleteClass(int id) async {
    _setLoading(true);
    await _dbHelper.deleteClass(id);
    await fetchClasses();
    _setLoading(false);
  }

  Future<SchoolClass?> getClassByClassIdString(String classId) async {
    _setLoading(true);
    // Assuming DatabaseHelper has a method to get a class by its string classId
    final result = await _dbHelper.getClassByClassIdString(classId);
    _setLoading(false);
    return result;
  }
}

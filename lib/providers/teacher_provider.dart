import 'package:flutter/material.dart';
import '../database_helper.dart';
import '../teacher_model.dart';

class TeacherProvider with ChangeNotifier {
  List<Teacher> _teachers = [];
  final DatabaseHelper _dbHelper = DatabaseHelper();

  List<Teacher> get teachers => _teachers;

  Future<void> fetchTeachers() async {
    _teachers = await _dbHelper.getTeachers();
    notifyListeners();
  }

  Future<void> addTeacher(Teacher teacher) async {
    await _dbHelper.createTeacher(teacher);
    await fetchTeachers();
  }

  Future<void> updateTeacher(Teacher teacher) async {
    await _dbHelper.updateTeacher(teacher);
    await fetchTeachers();
  }

  Future<void> deleteTeacher(int id) async {
    await _dbHelper.deleteTeacher(id);
    await fetchTeachers();
  }

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

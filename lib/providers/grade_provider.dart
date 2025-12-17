import 'package:flutter/material.dart';
import '../grade_model.dart';
import '../database_helper.dart';

class GradeProvider with ChangeNotifier {
  List<Grade> _grades = [];
  bool _isLoading = false; // Add isLoading property
  late DatabaseHelper dbHelper;

  GradeProvider({DatabaseHelper? databaseHelper}) {
    dbHelper = databaseHelper ?? DatabaseHelper();
  }

  List<Grade> get grades => _grades;
  bool get isLoading => _isLoading; // Getter for isLoading

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> initialize() async {
    _setLoading(true);
    await fetchGrades();
    _setLoading(false);
  }

  Future<void> fetchGrades() async {
    _setLoading(true);
    _grades = await dbHelper.getGrades();
    _setLoading(false);
  }

  Future<void> addGrade(Grade grade) async {
    _setLoading(true);
    await dbHelper.createGrade(grade);
    await fetchGrades();
    _setLoading(false);
  }

  Future<void> updateGrade(Grade grade) async {
    _setLoading(true);
    await dbHelper.updateGrade(grade);
    await fetchGrades();
    _setLoading(false);
  }

  Future<void> deleteGrade(int id) async {
    _setLoading(true);
    await dbHelper.deleteGrade(id);
    await fetchGrades();
    _setLoading(false);
  }

  Future<List<Grade>> getGradesByStudent(int studentId) async {
    _setLoading(true);
    final result = await dbHelper.getGradesByStudent(studentId);
    _setLoading(false);
    return result;
  }

  Future<List<Grade>> getGradesByClass(int classId) async {
    _setLoading(true);
    final result = await dbHelper.getGradesByClass(classId);
    _setLoading(false);
    return result;
  }

  Future<List<Grade>> getGradesBySubject(int subjectId) async {
    _setLoading(true);
    final result = await dbHelper.getGradesBySubject(subjectId);
    _setLoading(false);
    return result;
  }

  Future<List<Grade>> getGradesByClassAndSubject(
      int classId, int subjectId) async {
    _setLoading(true);
    final result = await dbHelper.getGradesByClassAndSubject(classId, subjectId);
    _setLoading(false);
    return result;
  }

  Future<void> upsertGrades(List<Grade> grades) async {
    _setLoading(true);
    await dbHelper.upsertGrades(grades);
    await fetchGrades(); // Refresh the list after upserting
    _setLoading(false);
  }

  Future<List<Map<String, dynamic>>> getAverageGradesBySubject() async {
    _setLoading(true);
    final result = await dbHelper.getAverageGradesBySubject();
    _setLoading(false);
    return result;
  }

  Future<List<Map<String, dynamic>>> getAverageGradesForClass(int classId) async {
    _setLoading(true);
    final result = await dbHelper.getAverageGradesForClass(classId);
    _setLoading(false);
    return result;
  }
}

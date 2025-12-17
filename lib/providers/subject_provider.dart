import 'package:flutter/material.dart';
import '../custom_exception.dart';
import '../database_helper.dart';
import '../subject_model.dart';

class SubjectProvider with ChangeNotifier {
  List<Subject> _subjects = [];
  bool _isLoading = false; // Add isLoading property
  final DatabaseHelper _dbHelper;

  SubjectProvider({DatabaseHelper? databaseHelper})
    : _dbHelper = databaseHelper ?? DatabaseHelper();

  List<Subject> get subjects => _subjects;
  bool get isLoading => _isLoading; // Getter for isLoading

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> fetchSubjects() async {
    _setLoading(true);
    _subjects = await _dbHelper.getSubjects();
    _setLoading(false);
  }

  Future<void> searchSubjects(String query) async {
    _setLoading(true);
    if (query.isEmpty) {
      await fetchSubjects();
    } else {
      _subjects = await _dbHelper.searchSubjects(query);
      notifyListeners();
    }
    _setLoading(false);
  }

  Future<void> addSubject(Subject subject) async {
    _setLoading(true);
    final existingSubjectByName = await _dbHelper.getSubjectByName(
      subject.name,
    );
    if (existingSubjectByName != null) {
      _setLoading(false);
      throw CustomException('اسم المادة موجود بالفعل.');
    }

    final existingSubjectById = await _dbHelper.getSubjectBySubjectId(
      subject.subjectId,
    );
    if (existingSubjectById != null) {
      _setLoading(false);
      throw CustomException('معرف المادة موجود بالفعل.');
    }

    await _dbHelper.createSubject(subject);
    await fetchSubjects();
    _setLoading(false);
  }

  Future<void> updateSubject(Subject subject) async {
    _setLoading(true);
    // Check for name uniqueness, excluding the current subject
    final existingSubjectByName = await _dbHelper.getSubjectByName(
      subject.name,
    );
    if (existingSubjectByName != null &&
        existingSubjectByName.id != subject.id) {
      _setLoading(false);
      throw CustomException('اسم المادة موجود بالفعل.');
    }

    // Check for subjectId uniqueness, excluding the current subject
    final existingSubjectById = await _dbHelper.getSubjectBySubjectId(
      subject.subjectId,
    );
    if (existingSubjectById != null && existingSubjectById.id != subject.id) {
      _setLoading(false);
      throw CustomException('معرف المادة موجود بالفعل.');
    }

    await _dbHelper.updateSubject(subject);
    await fetchSubjects();
    _setLoading(false);
  }

  Future<void> deleteSubject(int id) async {
    _setLoading(true);
    await _dbHelper.deleteSubject(id);
    await fetchSubjects();
    _setLoading(false);
  }

  Future<void> fetchSubjectsForClass(int classId) async {
    _setLoading(true);
    _subjects = await _dbHelper.getSubjectsForClass(classId);
    _setLoading(false);
  }

  void clearSubjects() {
    _setLoading(true);
    _subjects = [];
    _setLoading(false);
  }

  // New method to get a subject by ID
  Future<Subject?> getSubjectById(int id) async {
    _setLoading(true);
    final result = await _dbHelper.getSubjectById(id);
    _setLoading(false);
    return result;
  }
}

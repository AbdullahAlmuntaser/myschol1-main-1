import 'package:flutter/material.dart';
import '../academic_year_model.dart';
import '../database_helper.dart';

class AcademicYearProvider with ChangeNotifier {
  List<AcademicYear> _academicYears = [];
  AcademicYear? _activeAcademicYear;

  List<AcademicYear> get academicYears => _academicYears;
  AcademicYear? get activeAcademicYear => _activeAcademicYear;

  Future<void> fetchAcademicYears() async {
    final dbHelper = DatabaseHelper();
    _academicYears = await dbHelper.getAcademicYears();
    try {
      _activeAcademicYear = _academicYears.firstWhere((year) => year.isActive);
    } catch (e) {
      _activeAcademicYear = null;
    }
    notifyListeners();
  }

  Future<void> addAcademicYear(AcademicYear academicYear) async {
    final dbHelper = DatabaseHelper();
    await dbHelper.createAcademicYear(academicYear);
    await fetchAcademicYears();
  }

  Future<void> updateAcademicYear(AcademicYear academicYear) async {
    final dbHelper = DatabaseHelper();
    await dbHelper.updateAcademicYear(academicYear);
    await fetchAcademicYears();
  }

  Future<void> deleteAcademicYear(int id) async {
    final dbHelper = DatabaseHelper();
    await dbHelper.deleteAcademicYear(id);
    await fetchAcademicYears();
  }

  Future<void> setActiveAcademicYear(AcademicYear academicYear) async {
    final dbHelper = DatabaseHelper();
    await dbHelper.setActiveAcademicYear(academicYear);
    await fetchAcademicYears();
  }
}

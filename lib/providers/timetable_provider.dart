import 'package:flutter/material.dart';
import '../timetable_model.dart';
import '../database_helper.dart';

class TimetableProvider with ChangeNotifier {
  final DatabaseHelper _databaseHelper =
      DatabaseHelper(); // Corrected instantiation
  List<TimetableEntry> _timetableEntries = [];

  List<TimetableEntry> get timetableEntries => _timetableEntries;

  // Fetch all timetable entries
  Future<void> fetchTimetableEntries() async {
    _timetableEntries = await _databaseHelper.getTimetableEntries();
    notifyListeners();
  }

  Future<List<TimetableEntry>> getTimetableByClassId(int classId) async {
    return await _databaseHelper.getTimetableByClassId(classId);
  }

  // Fetch timetable entries by class ID
  Future<void> fetchTimetableEntriesByClass(int classId) async {
    _timetableEntries = await _databaseHelper.getTimetableByClassId(classId);
    notifyListeners();
  }

  // Fetch timetable entries by teacher ID
  Future<void> fetchTimetableEntriesByTeacher(int teacherId) async {
    _timetableEntries = await _databaseHelper.getTimetableEntriesByTeacher(teacherId);
    notifyListeners();
  }

  // Add a new timetable entry
  Future<void> addTimetableEntry(TimetableEntry entry) async {
    await _databaseHelper.insertTimetableEntry(entry.toMap());
    await fetchTimetableEntries(); // Refresh the list by calling the renamed method
  }

  // Update an existing timetable entry
  Future<void> updateTimetableEntry(TimetableEntry entry) async {
    await _databaseHelper.updateTimetableEntry(entry.toMap());
    await fetchTimetableEntries(); // Refresh the list by calling the renamed method
  }

  // Delete a timetable entry
  Future<void> deleteTimetableEntry(int id) async {
    await _databaseHelper.deleteTimetableEntry(id);
    await fetchTimetableEntries(); // Refresh the list by calling the renamed method
  }
}

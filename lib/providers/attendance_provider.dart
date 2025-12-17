import 'package:flutter/material.dart';
import '../attendance_model.dart';
import '../database_helper.dart';

class AttendanceProvider with ChangeNotifier {
  List<Attendance> _attendances = [];
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final Map<int, Map<String, int>> _studentStats = {};

  List<Attendance> get attendances => _attendances;
  Map<int, Map<String, int>> get studentStats => _studentStats;

  // Remove fetchAttendances() from constructor
  // AttendanceProvider() {
  //   fetchAttendances();
  // }

  Future<void> initialize() async {
    await fetchAttendances();
  }

  Future<void> fetchAttendances({
    String? date,
    int? classId,
    int? subjectId,
    int? teacherId,
    int? studentId,
    int? lessonNumber,
  }) async {
    _attendances = await _dbHelper.getAttendancesByFilters(
      date: date,
      classId: classId,
      subjectId: subjectId,
      teacherId: teacherId,
      studentId: studentId,
      lessonNumber: lessonNumber,
    );
    notifyListeners();
  }

  Future<void> addAttendance(Attendance attendance) async {
    await _dbHelper.createAttendance(attendance);
    fetchAttendances(); // Refresh the list
  }

  Future<void> updateAttendance(Attendance attendance) async {
    await _dbHelper.updateAttendance(attendance);
    fetchAttendances(); // Refresh the list
  }

  Future<void> deleteAttendance(int id) async {
    await _dbHelper.deleteAttendance(id);
    fetchAttendances(); // Refresh the list
  }

  Future<void> fetchStudentAttendanceStats(int studentId, int classId) async {
    final allStudentAttendances = await _dbHelper.getAttendancesByFilters(
      studentId: studentId,
      classId: classId,
    );
    final stats = <String, int>{
      'present': 0,
      'absent': 0,
      'late': 0,
      'excused': 0,
    };
    for (var att in allStudentAttendances) {
      if (stats.containsKey(att.status)) {
        stats[att.status] = stats[att.status]! + 1;
      }
    }
    _studentStats[studentId] = stats;
    notifyListeners();
  }

  Future<void> setBulkAttendance(
    Map<String, String> changes,
    int classId,
    int subjectId,
    int teacherId,
    String date,
    int lessonNumber,
  ) async {
    final List<Attendance> toUpdate = [];
    final List<Attendance> toInsert = [];

    for (var entry in changes.entries) {
      final studentId = int.parse(entry.key);
      final status = entry.value;

      final existingRecord = _attendances.firstWhere(
        (att) =>
            att.studentId == studentId &&
            att.date == date &&
            att.lessonNumber == lessonNumber,
        orElse: () => Attendance(
          id: null,
          studentId: -1,
          classId: -1,
          subjectId: -1,
          teacherId: -1,
          date: '',
          lessonNumber: -1,
          status: '',
        ),
      );

      if (existingRecord.id != null) {
        // Record exists, needs update
        toUpdate.add(existingRecord.copyWith(status: status));
      } else {
        // New record
        toInsert.add(
          Attendance(
            studentId: studentId,
            classId: classId,
            subjectId: subjectId,
            teacherId: teacherId,
            date: date,
            lessonNumber: lessonNumber,
            status: status,
          ),
        );
      }
    }

    await _dbHelper.bulkUpsertAttendances(toUpdate, toInsert);

    // Refresh data for the specific context
    await fetchAttendances(
      date: date,
      classId: classId,
      subjectId: subjectId,
      teacherId: teacherId,
      lessonNumber: lessonNumber,
    );
  }

  // Method to get attendance status for a specific student, date, and lesson
  String getAttendanceStatus(int studentId, String date, int lessonNumber) {
    final attendanceRecord = _attendances.firstWhere(
      (att) =>
          att.studentId == studentId &&
          att.date == date &&
          att.lessonNumber == lessonNumber,
      orElse: () => Attendance(
        studentId: studentId,
        classId: -1, // Dummy values as orElse must return a complete object
        subjectId: -1,
        teacherId: -1,
        date: date,
        lessonNumber: lessonNumber,
        status: 'unknown',
      ), // Return a dummy attendance if not found
    );
    return attendanceRecord.status;
  }

  // New method to fetch all attendances for a single student
  Future<List<Attendance>> getAttendancesByStudent(int studentId) async {
    return await _dbHelper.getAttendancesByFilters(studentId: studentId);
  }

  // Helper method to set attendance for a student, date, and lesson
  Future<void> setAttendanceStatus(
    int studentId,
    int classId,
    int subjectId,
    int teacherId,
    String date,
    int lessonNumber,
    String status,
  ) async {
    final existingAttendance = _attendances.firstWhere(
      (att) =>
          att.studentId == studentId &&
          att.date == date &&
          att.lessonNumber == lessonNumber,
      orElse: () => Attendance(
        studentId: -1,
        classId: -1,
        subjectId: -1,
        teacherId: -1,
        date: '',
        lessonNumber: -1,
        status: '',
      ), // Return a dummy if not found
    );

    if (existingAttendance.studentId != -1) {
      // Update existing record
      existingAttendance.status = status;
      await updateAttendance(existingAttendance);
    } else {
      // Create new record
      final newAttendance = Attendance(
        studentId: studentId,
        classId: classId,
        subjectId: subjectId,
        teacherId: teacherId,
        date: date,
        lessonNumber: lessonNumber,
        status: status,
      );
      await addAttendance(newAttendance);
    }
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/student_provider.dart';
import '../providers/grade_provider.dart';
import '../providers/attendance_provider.dart';
import '../providers/timetable_provider.dart';
import '../services/local_auth_service.dart';
import '../student_model.dart';
import '../grade_model.dart';
import '../attendance_model.dart';
import '../timetable_model.dart';

class StudentPortalScreen extends StatefulWidget {
  const StudentPortalScreen({super.key});

  @override
  State<StudentPortalScreen> createState() => _StudentPortalScreenState();
}

class _StudentPortalScreenState extends State<StudentPortalScreen> {
  Future<Map<String, dynamic>>? _studentData;

  @override
  void initState() {
    super.initState();
    _studentData = _fetchStudentData();
  }

  Future<Map<String, dynamic>> _fetchStudentData() async {
    final authService = Provider.of<LocalAuthService>(context, listen: false);
    final studentProvider = Provider.of<StudentProvider>(context, listen: false);
    final gradeProvider = Provider.of<GradeProvider>(context, listen: false);
    final attendanceProvider = Provider.of<AttendanceProvider>(context, listen: false);
    final timetableProvider = Provider.of<TimetableProvider>(context, listen: false);

    final currentUser = authService.currentUser;
    if (currentUser == null) {
      throw Exception('No user logged in');
    }

    final student = await studentProvider.getStudentByUserId(currentUser.id!);
    if (student == null) {
      throw Exception('Student not found');
    }

    final grades = await gradeProvider.getGradesByStudent(student.id!);
    final attendance = await attendanceProvider.getAttendancesByStudent(student.id!);
    final timetable = await timetableProvider.getTimetableByClassId(int.tryParse(student.classId ?? '0') ?? 0);

    return {
      'student': student,
      'grades': grades,
      'attendance': attendance,
      'timetable': timetable,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('بوابة الطالب'),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _studentData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('No data found.'));
          }

          final student = snapshot.data!['student'] as Student;
          final grades = snapshot.data!['grades'] as List<Grade>;
          final attendance = snapshot.data!['attendance'] as List<Attendance>;
          final timetable = snapshot.data!['timetable'] as List<TimetableEntry>;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Welcome, ${student.name}', style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 20),
                _buildGradesSection(grades),
                const SizedBox(height: 20),
                _buildAttendanceSection(attendance),
                const SizedBox(height: 20),
                _buildTimetableSection(timetable),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildGradesSection(List<Grade> grades) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('My Grades', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 10),
        grades.isEmpty
            ? const Text('You have no grades yet.')
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: grades.length,
                itemBuilder: (context, index) {
                  final grade = grades[index];
                  return Card(
                    child: ListTile(
                      title: Text('Subject ID: ${grade.subjectId}'),
                      subtitle: Text('Grade: ${grade.gradeValue}'),
                    ),
                  );
                },
              ),
      ],
    );
  }

  Widget _buildAttendanceSection(List<Attendance> attendance) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('My Attendance', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 10),
        attendance.isEmpty
            ? const Text('No attendance records found.')
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: attendance.length,
                itemBuilder: (context, index) {
                  final record = attendance[index];
                  return Card(
                    child: ListTile(
                      title: Text('Date: ${record.date}'),
                      subtitle: Text('Status: ${record.status}'),
                    ),
                  );
                },
              ),
      ],
    );
  }

  Widget _buildTimetableSection(List<TimetableEntry> timetable) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('My Timetable', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 10),
        timetable.isEmpty
            ? const Text('Your timetable is empty.')
            : Table(
                border: TableBorder.all(),
                children: [
                  const TableRow(
                    children: [
                      TableCell(child: Center(child: Text('Day'))),
                      TableCell(child: Center(child: Text('Time'))),
                      TableCell(child: Center(child: Text('Subject'))),
                    ],
                  ),
                  ...timetable.map((entry) {
                    return TableRow(
                      children: [
                        TableCell(child: Center(child: Text(entry.dayOfWeek))),
                        TableCell(child: Center(child: Text('${entry.startTime} - ${entry.endTime}'))),
                        TableCell(child: Center(child: Text(entry.subjectId.toString()))),
                      ],
                    );
                  }),
                ],
              ),
      ],
    );
  }
}

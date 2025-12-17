import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/teacher_provider.dart';
import '../providers/class_provider.dart';
import '../providers/timetable_provider.dart';
import '../services/local_auth_service.dart';
import '../teacher_model.dart';
import '../class_model.dart';
import '../timetable_model.dart';

class TeacherPortalScreen extends StatefulWidget {
  const TeacherPortalScreen({super.key});

  @override
  State<TeacherPortalScreen> createState() => _TeacherPortalScreenState();
}

class _TeacherPortalScreenState extends State<TeacherPortalScreen> {
  Future<Map<String, dynamic>>? _teacherData;

  @override
  void initState() {
    super.initState();
    _teacherData = _fetchTeacherData();
  }

  Future<Map<String, dynamic>> _fetchTeacherData() async {
    final authService = Provider.of<LocalAuthService>(context, listen: false);
    final teacherProvider = Provider.of<TeacherProvider>(context, listen: false);
    final classProvider = Provider.of<ClassProvider>(context, listen: false);
    final timetableProvider = Provider.of<TimetableProvider>(context, listen: false);

    final currentUser = authService.currentUser;
    if (currentUser == null) {
      throw Exception('No user logged in');
    }

    final teacher = await teacherProvider.getTeacherByUserId(currentUser.id!);
    if (teacher == null) {
      throw Exception('Teacher not found');
    }

    await classProvider.fetchClasses();
    final classes = classProvider.classes
        .where((c) => c.teacherId != null && int.tryParse(c.teacherId!) == teacher.id)
        .toList();

    await timetableProvider.fetchTimetableEntries();
    final timetable = timetableProvider.timetableEntries
        .where((t) => t.teacherId == teacher.id)
        .toList();

    return {
      'teacher': teacher,
      'classes': classes,
      'timetable': timetable,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('بوابة المعلم'),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _teacherData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('No data found.'));
          }

          final teacher = snapshot.data!['teacher'] as Teacher;
          final classes = snapshot.data!['classes'] as List<SchoolClass>;
          final timetable = snapshot.data!['timetable'] as List<TimetableEntry>;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Welcome, ${teacher.name}', style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 20),
                _buildClassesSection(classes),
                const SizedBox(height: 20),
                _buildTimetableSection(timetable),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildClassesSection(List<SchoolClass> classes) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('My Classes', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 10),
        classes.isEmpty
            ? const Text('You are not assigned to any classes.')
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: classes.length,
                itemBuilder: (context, index) {
                  final schoolClass = classes[index];
                  return Card(
                    child: ListTile(
                      title: Text(schoolClass.name),
                      subtitle: Text('Class ID: ${schoolClass.classId}'),
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
                      TableCell(child: Center(child: Text('Class'))),
                      TableCell(child: Center(child: Text('Subject'))),
                    ],
                  ),
                  ...timetable.map((entry) {
                    return TableRow(
                      children: [
                        TableCell(child: Center(child: Text(entry.dayOfWeek))),
                        TableCell(child: Center(child: Text('${entry.startTime} - ${entry.endTime}'))),
                        TableCell(child: Center(child: Text(entry.classId.toString()))),
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

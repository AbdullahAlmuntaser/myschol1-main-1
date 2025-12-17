import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../student_model.dart';
import '../grade_model.dart'; // Added
import '../attendance_model.dart'; // Added
import '../timetable_model.dart'; // Added
import '../user_model.dart'; // Added
import '../database_helper.dart'; // Added
import '../providers/grade_provider.dart';
import '../providers/attendance_provider.dart';
import '../providers/timetable_provider.dart';
import '../providers/subject_provider.dart'; // For subject names
import '../providers/class_provider.dart'; // Added for class ID resolution
import '../subject_model.dart'; // Added for Subject type

class StudentDetailForParentScreen extends StatefulWidget {
  final Student student;

  const StudentDetailForParentScreen({super.key, required this.student});

  @override
  State<StudentDetailForParentScreen> createState() =>
      _StudentDetailForParentScreenState();
}

class _StudentDetailForParentScreenState
    extends State<StudentDetailForParentScreen> {
  bool _isLoading = true;
  String? _errorMessage;

  List<Grade> _grades = [];
  List<Attendance> _attendances = [];
  List<TimetableEntry> _timetable = [];

  @override
  void initState() {
    super.initState();
    _fetchStudentDetails();
  }

  Future<void> _fetchStudentDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final gradeProvider = Provider.of<GradeProvider>(context, listen: false);
      final attendanceProvider = Provider.of<AttendanceProvider>(
        context,
        listen: false,
      );
      final timetableProvider = Provider.of<TimetableProvider>(
        context,
        listen: false,
      );
      final classProvider = Provider.of<ClassProvider>(
        context,
        listen: false,
      ); // Added

      // Fetch grades
      final fetchedGrades = await gradeProvider.getGradesByStudent(
        widget.student.id!,
      ); // Assuming student.id is not null

      // Fetch attendance
      await attendanceProvider.fetchAttendances(
        studentId: widget.student.id!,
      ); // Fetch for specific student
      final fetchedAttendances =
          attendanceProvider.attendances; // Get the fetched list

      // Resolve classId (String) to int class.id for Timetable fetching
      List<TimetableEntry> fetchedTimetable = [];
      if (widget.student.classId != null &&
          widget.student.classId!.isNotEmpty) {
        final schoolClass = await classProvider.getClassByClassIdString(
          widget.student.classId!,
        ); // Assuming this method exists
        if (schoolClass != null && schoolClass.id != null) {
          await timetableProvider.fetchTimetableEntriesByClass(
            schoolClass.id!,
          ); // Use integer class ID
          fetchedTimetable =
              timetableProvider.timetableEntries; // Get the fetched list
        }
      }

      if (mounted) {
        setState(() {
          _grades = fetchedGrades;
          _attendances = fetchedAttendances;
          _timetable = fetchedTimetable;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'حدث خطأ أثناء جلب تفاصيل الطالب: $e';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Helper to build a section with a title and content
  Widget _buildSection({required String title, required Widget content}) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.headlineSmall),
            const Divider(),
            const SizedBox(height: 10),
            content,
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('تفاصيل الطالب: ${widget.student.name}')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Basic Student Information
                  _buildSection(
                    title: 'معلومات الطالب الأساسية',
                    content: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'الرقم الأكاديمي: ${widget.student.academicNumber ?? 'N/A'}',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        Text(
                          'الصف: ${widget.student.grade}',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        Text(
                          'البريد الإلكتروني: ${widget.student.email ?? 'N/A'}',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        Text(
                          'رقم الهاتف: ${widget.student.phone}',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        Text(
                          'تاريخ الميلاد: ${widget.student.dob}',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        Text(
                          'القسم: ${widget.student.section ?? 'N/A'}',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        Text(
                          'حالة الطالب: ${widget.student.status ? 'نشط' : 'غير نشط'}',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        // Display parent username if available
                        if (widget.student.parentUserId != null)
                          FutureBuilder<User?>(
                            future: DatabaseHelper().getUserById(
                              widget.student.parentUserId!,
                            ), // Access DatabaseHelper directly
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Text('ولي الأمر: جاري التحميل...');
                              } else if (snapshot.hasError) {
                                return Text(
                                  'ولي الأمر: خطأ في التحميل (${snapshot.error})',
                                );
                              } else if (snapshot.hasData &&
                                  snapshot.data != null) {
                                return Text(
                                  'ولي الأمر: ${snapshot.data!.username}',
                                  style: Theme.of(context).textTheme.bodyLarge,
                                );
                              } else {
                                return const SizedBox.shrink();
                              }
                            },
                          ),
                      ],
                    ),
                  ),
                  // Grades Section
                  _buildSection(
                    title: 'الدرجات',
                    content: _grades.isEmpty
                        ? const Text('لا توجد درجات مسجلة لهذا الطالب.')
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _grades.length,
                            itemBuilder: (context, index) {
                              final grade = _grades[index];
                              return ListTile(
                                title: Consumer<SubjectProvider>(
                                  builder: (context, subjectProvider, child) {
                                    return FutureBuilder<Subject?>(
                                      future: subjectProvider.getSubjectById(
                                        grade.subjectId,
                                      ),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return const Text(
                                            'المادة: جاري التحميل...',
                                          );
                                        } else if (snapshot.hasData &&
                                            snapshot.data != null) {
                                          return Text(
                                            'المادة: ${snapshot.data!.name}',
                                          );
                                        } else {
                                          return Text(
                                            'المادة: غير معروفة (${grade.subjectId})',
                                          );
                                        }
                                      },
                                    );
                                  },
                                ),
                                subtitle: Text(
                                  'التقييم: ${grade.assessmentType} - الدرجة: ${grade.gradeValue} (الوزن: ${grade.weight})',
                                ),
                                trailing: Text(
                                  'الصف: ${grade.classId}',
                                ), // Might need to resolve class name
                              );
                            },
                          ),
                  ),

                  // Attendance Section
                  _buildSection(
                    title: 'الحضور',
                    content: _attendances.isEmpty
                        ? const Text('لا توجد سجلات حضور لهذا الطالب.')
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _attendances.length,
                            itemBuilder: (context, index) {
                              final attendance = _attendances[index];
                              return ListTile(
                                title: Text('التاريخ: ${attendance.date}'),
                                subtitle: Text(
                                  'الحالة: ${attendance.status} - الدرس: ${attendance.lessonNumber}',
                                ),
                                trailing: Consumer<SubjectProvider>(
                                  builder: (context, subjectProvider, child) {
                                    return FutureBuilder<Subject?>(
                                      future: subjectProvider.getSubjectById(
                                        attendance.subjectId,
                                      ),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return const Text('جاري التحميل...');
                                        } else if (snapshot.hasData &&
                                            snapshot.data != null) {
                                          return Text(snapshot.data!.name);
                                        } else {
                                          return const Text('مادة غير معروفة');
                                        }
                                      },
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                  ),

                  // Timetable Section (requires classId resolution)
                  _buildSection(
                    title: 'الجدول الزمني',
                    content: _timetable.isEmpty
                        ? const Text(
                            'لا يوجد جدول زمني لهذا الطالب (يتطلب ربط الطالب بصف).',
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _timetable.length,
                            itemBuilder: (context, index) {
                              final entry = _timetable[index];
                              return ListTile(
                                title: Text(
                                  '${entry.dayOfWeek}: الدرس ${entry.lessonNumber}',
                                ),
                                subtitle: Text(
                                  'من ${entry.startTime} إلى ${entry.endTime}',
                                ),
                                trailing: Consumer<SubjectProvider>(
                                  builder: (context, subjectProvider, child) {
                                    return FutureBuilder<Subject?>(
                                      future: subjectProvider.getSubjectById(
                                        entry.subjectId,
                                      ),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return const Text('جاري التحميل...');
                                        } else if (snapshot.hasData &&
                                            snapshot.data != null) {
                                          return Text(
                                            'المادة: ${snapshot.data!.name}',
                                          );
                                        } else {
                                          return const Text('مادة غير معروفة');
                                        }
                                      },
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
    );
  }
}

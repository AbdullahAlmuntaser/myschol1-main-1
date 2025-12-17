import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../student_model.dart';
import '../class_model.dart';
import '../subject_model.dart';
import '../teacher_model.dart';
import '../providers/attendance_provider.dart';
import '../providers/student_provider.dart';
import '../providers/class_provider.dart';
import '../providers/subject_provider.dart';
import '../providers/teacher_provider.dart';

class AttendanceScreen extends StatefulWidget {
  static const routeName = '/attendance-screen';
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  String _selectedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
  SchoolClass? _selectedClass;
  Subject? _selectedSubject;
  Teacher? _selectedTeacher;
  int? _selectedLessonNumber;
  bool _isLoading = false;

  // Local map to store attendance changes before saving
  final Map<String, String> _localAttendanceChanges = {};

  @override
  void initState() {
    super.initState();
    // Fetch only classes initially
    Provider.of<ClassProvider>(context, listen: false).fetchClasses();
  }

  Future<void> _loadAttendanceData() async {
    _localAttendanceChanges.clear(); // Clear local changes on every reload
    if (!_isLoading) {
      setState(() {
        _isLoading = true;
      });
    }

    if (_selectedClass == null ||
        _selectedSubject == null ||
        _selectedTeacher == null ||
        _selectedLessonNumber == null) {
      // Clear student list if filters are not fully selected
      await Provider.of<StudentProvider>(context, listen: false).clearStudents();
      setState(() {
        _isLoading = false;
      });
      return;
    }

    final studentProvider = Provider.of<StudentProvider>(
      context,
      listen: false,
    );
    await studentProvider.searchStudents(
      '',
      classId: _selectedClass!.id.toString(),
    );
    if (!mounted) return;

    final attendanceProvider = Provider.of<AttendanceProvider>(
      context,
      listen: false,
    );
    await attendanceProvider.fetchAttendances(
      date: _selectedDate,
      classId: _selectedClass!.id,
      subjectId: _selectedSubject!.id,
      teacherId: _selectedTeacher!.id,
      lessonNumber: _selectedLessonNumber,
    );
    if (!mounted) return;

    // Fetch total attendance stats
    for (var student in studentProvider.students) {
      await attendanceProvider.fetchStudentAttendanceStats(
        student.id!,
        _selectedClass!.id!,
      );
      if (!mounted) return;
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.parse(_selectedDate),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null &&
        DateFormat('yyyy-MM-dd').format(picked) != _selectedDate) {
      setState(() {
        _selectedDate = DateFormat('yyyy-MM-dd').format(picked);
      });
      _loadAttendanceData();
    }
  }

  void _handleAttendanceChange(Student student, String status) {
    setState(() {
      _localAttendanceChanges[student.id.toString()] = status;
    });
  }

  Future<void> _saveAllChanges() async {
    if (_localAttendanceChanges.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('لا توجد تغييرات لحفظها.'),
          backgroundColor: Colors.amber,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final attendanceProvider = Provider.of<AttendanceProvider>(
        context,
        listen: false,
      );
      await attendanceProvider.setBulkAttendance(
        _localAttendanceChanges,
        _selectedClass!.id!,
        _selectedSubject!.id!,
        _selectedTeacher!.id!,
        _selectedDate,
        _selectedLessonNumber!,
      );

      _localAttendanceChanges.clear();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم حفظ الحضور بنجاح!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('فشل حفظ الحضور: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تسجيل الحضور والغياب')),
      body: Column(
        children: [
          _buildFilterSection(),
          Expanded(child: _buildStudentList()),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isLoading || _localAttendanceChanges.isEmpty
            ? null
            : _saveAllChanges,
        label: const Text('حفظ الكل'),
        icon: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Icon(Icons.save),
        backgroundColor: _localAttendanceChanges.isEmpty
            ? Colors.grey
            : Theme.of(context).primaryColor,
      ),
    );
  }

  Widget _buildFilterSection() {
    // Use Consumer to rebuild dropdowns when provider data changes
    return Consumer4<ClassProvider, SubjectProvider, TeacherProvider, StudentProvider>(
      builder: (context, classProvider, subjectProvider, teacherProvider, studentProvider, child) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _selectDate(context),
                          icon: const Icon(Icons.calendar_today),
                          label: Text(_selectedDate),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: DropdownButtonFormField<int>(
                          initialValue: _selectedLessonNumber,
                          hint: const Text('الحصة'),
                          onChanged: (newValue) {
                            setState(() {
                              _selectedLessonNumber = newValue;
                            });
                            _loadAttendanceData();
                          },
                          items: List.generate(6, (index) => index + 1).map((
                            lessonNum,
                          ) {
                            return DropdownMenuItem(
                              value: lessonNum,
                              child: Text('الحصة $lessonNum'),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<SchoolClass>(
                          initialValue: _selectedClass,
                          hint: const Text('الفصل'),
                          isExpanded: true,
                          onChanged: (newValue) async {
                            if (newValue == null) return;
                            setState(() {
                              _selectedClass = newValue;
                              _selectedSubject = null;
                              _selectedTeacher = null;
                            });
                            // Clear previous lists and load new ones
                            await subjectProvider.fetchSubjectsForClass(newValue.id!);
                            await teacherProvider.fetchTeachersForClass(newValue.id!);
                            // Clear student list when class changes
                            await studentProvider.clearStudents();
                          },
                          items: classProvider.classes.map((c) {
                            return DropdownMenuItem(
                              value: c,
                              child: Text(c.name, overflow: TextOverflow.ellipsis),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: DropdownButtonFormField<Subject>(
                          initialValue: _selectedSubject,
                          hint: const Text('المادة'),
                          isExpanded: true,
                          onChanged: (newValue) {
                            setState(() {
                              _selectedSubject = newValue;
                            });
                            _loadAttendanceData();
                          },
                          items: subjectProvider.subjects.map((s) {
                            return DropdownMenuItem(
                              value: s,
                              child: Text(s.name, overflow: TextOverflow.ellipsis),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<Teacher>(
                          initialValue: _selectedTeacher,
                          hint: const Text('المعلم'),
                          isExpanded: true,
                          onChanged: (newValue) {
                            setState(() {
                              _selectedTeacher = newValue;
                            });
                            _loadAttendanceData();
                          },
                          items: teacherProvider.teachers.map((t) {
                            return DropdownMenuItem(
                              value: t,
                              child: Text(t.name, overflow: TextOverflow.ellipsis),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStudentList() {
    final studentProvider = Provider.of<StudentProvider>(context);
    final attendanceProvider = Provider.of<AttendanceProvider>(context);
    final bool allFiltersSelected =
        _selectedClass != null &&
        _selectedSubject != null &&
        _selectedTeacher != null &&
        _selectedLessonNumber != null;

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (!allFiltersSelected) {
      return const Center(
        child: Text(
          'الرجاء تحديد جميع الفلاتر لعرض قائمة الطلاب.',
          style: TextStyle(fontSize: 16, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      );
    }

    if (studentProvider.students.isEmpty) {
      return const Center(
        child: Text(
          'لا يوجد طلاب في هذا الفصل.',
          style: TextStyle(fontSize: 16, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: studentProvider.students.length,
      itemBuilder: (context, index) {
        final student = studentProvider.students[index];
        final localStatus = _localAttendanceChanges[student.id.toString()];
        final currentStatus =
            localStatus ??
            attendanceProvider.getAttendanceStatus(
              student.id!,
              _selectedDate,
              _selectedLessonNumber!,
            );
        final stats = attendanceProvider.studentStats[student.id];

        return Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        student.name,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (stats != null)
                      Text(
                        'حضور: ${stats['present'] ?? 0} | غياب: ${stats['present'] ?? 0}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                  ],
                ),
                const Divider(height: 20),
                _buildAttendanceToggle(student, currentStatus),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAttendanceToggle(Student student, String currentStatus) {
    final List<bool> isSelected = [
      currentStatus == 'present',
      currentStatus == 'absent',
      currentStatus == 'late',
      currentStatus == 'excused',
    ];

    return ToggleButtons(
      isSelected: isSelected,
      onPressed: (int index) {
        final status = ['present', 'absent', 'late', 'excused'][index];
        _handleAttendanceChange(student, status);
      },
      borderRadius: BorderRadius.circular(8),
      selectedColor: Colors.white,
      fillColor: Theme.of(context).primaryColor,
      color: Theme.of(context).primaryColor,
      constraints: BoxConstraints(
        minWidth: (MediaQuery.of(context).size.width - 100) / 4,
        minHeight: 40,
      ),
      children: const [
        Tooltip(message: 'حاضر', child: Icon(Icons.check_circle)),
        Tooltip(message: 'غائب', child: Icon(Icons.cancel)),
        Tooltip(message: 'متأخر', child: Icon(Icons.watch_later)),
        Tooltip(message: 'معذور', child: Icon(Icons.receipt)),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/timetable_provider.dart';
import '../../timetable_model.dart';
import '../../class_model.dart';
import '../../teacher_model.dart';
import '../../subject_model.dart';
import '../../providers/class_provider.dart';
import '../../providers/teacher_provider.dart';
import '../../providers/subject_provider.dart';

class AddEditTimetableScreen extends StatefulWidget {
  final TimetableEntry? entry;

  const AddEditTimetableScreen({super.key, this.entry});

  @override
  State<AddEditTimetableScreen> createState() => _AddEditTimetableScreenState();
}

class _AddEditTimetableScreenState extends State<AddEditTimetableScreen> {
  final _formKey = GlobalKey<FormState>();
  SchoolClass? _selectedClass;
  Subject? _selectedSubject;
  Teacher? _selectedTeacher;
  String? _selectedDayOfWeek;
  int? _selectedLessonNumber;
  final TextEditingController _startTimeController = TextEditingController();
  final TextEditingController _endTimeController = TextEditingController();

  final List<String> _daysOfWeek = [
    'الأحد',
    'الاثنين',
    'الثلاثاء',
    'الأربعاء',
    'الخميس',
  ];
  final List<int> _lessonNumbers = List.generate(6, (index) => index + 1);

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
  }

  Future<void> _fetchInitialData() async {
    setState(() {
      _isLoading = true;
    });

    final classProvider = Provider.of<ClassProvider>(context, listen: false);
    final teacherProvider = Provider.of<TeacherProvider>(
      context,
      listen: false,
    );
    final subjectProvider = Provider.of<SubjectProvider>(
      context,
      listen: false,
    );

    await classProvider.fetchClasses();
    if (!mounted) return;
    await teacherProvider.fetchTeachers();
    if (!mounted) return;
    await subjectProvider.fetchSubjects();
    if (!mounted) return;

    if (widget.entry != null) {
      // Editing existing entry, pre-fill fields
      _selectedClass = classProvider.classes.firstWhere(
        (c) => c.id == widget.entry!.classId,
      );
      _selectedSubject = subjectProvider.subjects.firstWhere(
        (s) => s.id == widget.entry!.subjectId,
      );
      _selectedTeacher = teacherProvider.teachers.firstWhere(
        (t) => t.id != null && t.id == widget.entry!.teacherId,
      );
      _selectedDayOfWeek = _daysOfWeek[widget.entry!.dayOfWeek - 1];
      _selectedLessonNumber = widget.entry!.lessonNumber;
      _startTimeController.text = widget.entry!.startTime;
      _endTimeController.text = widget.entry!.endTime;
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _selectTime(
    BuildContext context,
    TextEditingController controller,
  ) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );
    if (picked != null) {
      final now = DateTime.now();
      final dt = DateTime(
        now.year,
        now.month,
        now.day,
        picked.hour,
        picked.minute,
      );
      final format = DateFormat('HH:mm');
      setState(() {
        controller.text = format.format(dt);
      });
    }
  }

  Future<void> _saveTimetableEntry() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedClass == null ||
        _selectedSubject == null ||
        _selectedTeacher == null ||
        _selectedDayOfWeek == null ||
        _selectedLessonNumber == null ||
        _startTimeController.text.isEmpty ||
        _endTimeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('الرجاء ملء جميع الحقول المطلوبة.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final timetableEntry = TimetableEntry(
      id: widget.entry?.id, // Will be null for new entries
      classId: _selectedClass!.id!,
      subjectId: _selectedSubject!.id!,
      teacherId: _selectedTeacher!.id!,
      dayOfWeek: _daysOfWeek.indexOf(_selectedDayOfWeek!) + 1,
      lessonNumber: _selectedLessonNumber!,
      startTime: _startTimeController.text,
      endTime: _endTimeController.text,
    );

    try {
      final timetableProvider = Provider.of<TimetableProvider>(
        context,
        listen: false,
      );
      if (widget.entry == null) {
        await timetableProvider.addTimetableEntry(timetableEntry);
      } else {
        await timetableProvider.updateTimetableEntry(timetableEntry);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.entry == null
                ? 'تمت إضافة الحصة بنجاح.'
                : 'تم تحديث الحصة بنجاح.',
          ),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('فشل حفظ الحصة: $e'),
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
    final classProvider = Provider.of<ClassProvider>(context);
    final teacherProvider = Provider.of<TeacherProvider>(context);
    final subjectProvider = Provider.of<SubjectProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.entry == null ? 'إضافة حصة جديدة' : 'تعديل حصة'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    // Class Dropdown
                    DropdownButtonFormField<SchoolClass>(
                      initialValue: _selectedClass,
                      hint: const Text('اختر الفصل'),
                      onChanged: classProvider.classes.isEmpty
                          ? null
                          : (newValue) {
                              setState(() {
                                _selectedClass = newValue;
                              });
                            },
                      items: classProvider.classes.map((c) {
                        return DropdownMenuItem(value: c, child: Text(c.name));
                      }).toList(),
                      validator: (value) =>
                          value == null ? 'الرجاء اختيار فصل' : null,
                    ),
                    const SizedBox(height: 16),
                    // Subject Dropdown
                    DropdownButtonFormField<Subject>(
                      initialValue: _selectedSubject,
                      hint: const Text('اختر المادة'),
                      onChanged: subjectProvider.subjects.isEmpty
                          ? null
                          : (newValue) {
                              setState(() {
                                _selectedSubject = newValue;
                              });
                            },
                      items: subjectProvider.subjects.map((s) {
                        return DropdownMenuItem(value: s, child: Text(s.name));
                      }).toList(),
                      validator: (value) =>
                          value == null ? 'الرجاء اختيار مادة' : null,
                    ),
                    const SizedBox(height: 16),
                    // Teacher Dropdown
                    DropdownButtonFormField<Teacher>(
                      initialValue: _selectedTeacher,
                      hint: const Text('اختر المعلم'),
                      onChanged: teacherProvider.teachers.isEmpty
                          ? null
                          : (newValue) {
                              setState(() {
                                _selectedTeacher = newValue;
                              });
                            },
                      items: teacherProvider.teachers.map((t) {
                        return DropdownMenuItem(value: t, child: Text(t.name));
                      }).toList(),
                      validator: (value) =>
                          value == null ? 'الرجاء اختيار معلم' : null,
                    ),
                    const SizedBox(height: 16),
                    // Day of Week Dropdown
                    DropdownButtonFormField<String>(
                      initialValue: _selectedDayOfWeek,
                      hint: const Text('اختر اليوم'),
                      onChanged: (newValue) {
                        setState(() {
                          _selectedDayOfWeek = newValue;
                        });
                      },
                      items: _daysOfWeek.map((day) {
                        return DropdownMenuItem(value: day, child: Text(day));
                      }).toList(),
                      validator: (value) =>
                          value == null ? 'الرجاء اختيار يوم' : null,
                    ),
                    const SizedBox(height: 16),
                    // Lesson Number Dropdown
                    DropdownButtonFormField<int>(
                      initialValue: _selectedLessonNumber,
                      hint: const Text('اختر رقم الحصة'),
                      onChanged: (newValue) {
                        setState(() {
                          _selectedLessonNumber = newValue;
                        });
                      },
                      items: _lessonNumbers.map((lessonNum) {
                        return DropdownMenuItem(
                          value: lessonNum,
                          child: Text('الحصة $lessonNum'),
                        );
                      }).toList(),
                      validator: (value) =>
                          value == null ? 'الرجاء اختيار رقم الحصة' : null,
                    ),
                    const SizedBox(height: 16),
                    // Start Time Text Field
                    GestureDetector(
                      onTap: () => _selectTime(context, _startTimeController),
                      child: AbsorbPointer(
                        child: TextFormField(
                          controller: _startTimeController,
                          decoration: const InputDecoration(
                            labelText: 'وقت البدء',
                            prefixIcon: Icon(Icons.access_time),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(12),
                              ),
                            ),
                          ),
                          validator: (value) => value == null || value.isEmpty
                              ? 'الرجاء تحديد وقت البدء'
                              : null,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // End Time Text Field
                    GestureDetector(
                      onTap: () => _selectTime(context, _endTimeController),
                      child: AbsorbPointer(
                        child: TextFormField(
                          controller: _endTimeController,
                          decoration: const InputDecoration(
                            labelText: 'وقت الانتهاء',
                            prefixIcon: Icon(Icons.access_time),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(12),
                              ),
                            ),
                          ),
                          validator: (value) => value == null || value.isEmpty
                              ? 'الرجاء تحديد وقت الانتهاء'
                              : null,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _saveTimetableEntry,
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              widget.entry == null
                                  ? 'إضافة حصة'
                                  : 'تحديث الحصة',
                            ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

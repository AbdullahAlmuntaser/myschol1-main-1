import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/timetable_provider.dart';
import '../../providers/class_provider.dart';
import '../../providers/teacher_provider.dart';
import '../../timetable_model.dart';
import '../../class_model.dart';
import '../../teacher_model.dart';
import '../../subject_model.dart';
import '../../providers/subject_provider.dart';
import 'add_edit_timetable_screen.dart'; // Import AddEditTimetableScreen

class TimetableScreen extends StatefulWidget {
  static const routeName = '/timetable-screen';
  const TimetableScreen({super.key});

  @override
  State<TimetableScreen> createState() => _TimetableScreenState();
}

class _TimetableScreenState extends State<TimetableScreen> {
  SchoolClass? _selectedClass;
  Teacher? _selectedTeacher;
  bool _isLoading = false;

  final List<String> _daysOfWeek = [
    'الأحد',
    'الاثنين',
    'الثلاثاء',
    'الأربعاء',
    'الخميس',
  ];
  final int _maxLessonNumber = 6;

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
    final timetableProvider = Provider.of<TimetableProvider>(
      context,
      listen: false,
    );

    await classProvider.fetchClasses();
    if (!mounted) return;
    await teacherProvider.fetchTeachers();
    if (!mounted) return;
    await subjectProvider.fetchSubjects();
    if (!mounted) return;

    if (classProvider.classes.isNotEmpty) {
      _selectedClass = classProvider.classes.first;
    }
    if (teacherProvider.teachers.isNotEmpty) {
      _selectedTeacher = teacherProvider.teachers.first;
    }

    if (_selectedClass != null) {
      await timetableProvider.fetchTimetableEntriesByClass(_selectedClass!.id!);
    } else if (_selectedTeacher != null) {
      await timetableProvider.fetchTimetableEntriesByTeacher(
        _selectedTeacher!.id!,
      );
    } else {
      await timetableProvider.fetchTimetableEntries();
    }
    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _loadTimetableData() async {
    if (!_isLoading) {
      setState(() {
        _isLoading = true;
      });
    }

    final timetableProvider = Provider.of<TimetableProvider>(
      context,
      listen: false,
    );

    if (_selectedClass != null && _selectedTeacher != null) {
      await timetableProvider.fetchTimetableEntriesByClass(_selectedClass!.id!);
    } else if (_selectedClass != null) {
      await timetableProvider.fetchTimetableEntriesByClass(_selectedClass!.id!);
    } else if (_selectedTeacher != null) {
      await timetableProvider.fetchTimetableEntriesByTeacher(
        _selectedTeacher!.id!,
      );
    } else {
      await timetableProvider.fetchTimetableEntries();
    }
    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final classProvider = Provider.of<ClassProvider>(context);
    final teacherProvider = Provider.of<TeacherProvider>(context);
    final subjectProvider = Provider.of<SubjectProvider>(context);
    final timetableProvider = Provider.of<TimetableProvider>(context);

    final Map<String, TimetableEntry> timetableMap = {};
    for (var entry in timetableProvider.timetableEntries) {
      timetableMap['${entry.dayOfWeek}_${entry.lessonNumber}'] = entry;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('الجدول الدراسي')),
      body: Column(
        children: [
          _buildFilterSection(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : timetableProvider.timetableEntries.isEmpty &&
                      (_selectedClass != null || _selectedTeacher != null)
                ? const Center(child: Text('لا توجد بيانات لهذا الاختيار.'))
                : _buildTimetableGrid(
                    timetableMap,
                    subjectProvider,
                    teacherProvider,
                    classProvider,
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddEditTimetableEntry(),
        tooltip: 'إضافة حصة جديدة',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildFilterSection() {
    final classProvider = Provider.of<ClassProvider>(context, listen: false);
    final teacherProvider = Provider.of<TeacherProvider>(
      context,
      listen: false,
    );

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: DropdownButton<SchoolClass>(
                  value: _selectedClass,
                  hint: const Text('الفصل'),
                  isExpanded: true,
                  underline: const SizedBox(),
                  onChanged: (newValue) {
                    setState(() {
                      _selectedClass = newValue;
                      _selectedTeacher = null;
                    });
                    _loadTimetableData();
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
                child: DropdownButton<Teacher>(
                  value: _selectedTeacher,
                  hint: const Text('المعلم'),
                  isExpanded: true,
                  underline: const SizedBox(),
                  onChanged: (newValue) {
                    setState(() {
                      _selectedTeacher = newValue;
                      _selectedClass = null;
                    });
                    _loadTimetableData();
                  },
                  items: teacherProvider.teachers.map((t) {
                    return DropdownMenuItem(
                      value: t,
                      child: Text(t.name, overflow: TextOverflow.ellipsis),
                    );
                  }).toList(),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.clear, color: Colors.red),
                tooltip: 'مسح الفلاتر',
                onPressed: () {
                  setState(() {
                    _selectedClass = null;
                    _selectedTeacher = null;
                  });
                  _loadTimetableData();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCell(String text) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      alignment: Alignment.center,
      color: Theme.of(context).primaryColor.withAlpha((255 * 0.1).round()),
      child: Text(
        text,
        style: Theme.of(
          context,
        ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildTimetableGrid(
    Map<String, TimetableEntry> timetableMap,
    SubjectProvider subjectProvider,
    TeacherProvider teacherProvider,
    ClassProvider classProvider,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Table(
        border: TableBorder.all(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(12),
        ),
        columnWidths: const {0: IntrinsicColumnWidth()},
        children: [
          TableRow(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withAlpha(25),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            children: [
              _buildHeaderCell('الوقت'),
              ..._daysOfWeek.map((day) => _buildHeaderCell(day)),
            ],
          ),
          ...List.generate(_maxLessonNumber, (lessonIndex) {
            final lessonNum = lessonIndex + 1;
            return TableRow(
              children: [
                _buildHeaderCell('الحصة $lessonNum'),
                ..._daysOfWeek.map((day) {
                  final entry = timetableMap['${day}_$lessonNum'];
                  return _buildTimetableCell(
                    entry,
                    subjectProvider.subjects,
                    teacherProvider.teachers,
                    classProvider.classes,
                  );
                }),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTimetableCell(
    TimetableEntry? entry,
    List<Subject> allSubjects,
    List<Teacher> allTeachers,
    List<SchoolClass> allClasses,
  ) {
    return GestureDetector(
      onTap: entry != null
          ? () => _navigateToAddEditTimetableEntry(entry: entry)
          : null,
      onLongPress: entry != null ? () => _showEntryActions(entry) : null,
      child: Card(
        elevation: entry != null ? 2 : 0,
        margin: const EdgeInsets.all(4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        color: entry != null
            ? Theme.of(context).colorScheme.primary.withAlpha(12)
            : Colors.grey.shade50,
        child: Container(
          padding: const EdgeInsets.all(6.0),
          alignment: Alignment.center,
          child: _buildCellContent(entry, allSubjects, allTeachers, allClasses),
        ),
      ),
    );
  }

  Widget _buildCellContent(
    TimetableEntry? entry,
    List<Subject> allSubjects,
    List<Teacher> allTeachers,
    List<SchoolClass> allClasses,
  ) {
    if (entry == null) {
      return const Text('-', style: TextStyle(color: Colors.grey));
    }

    final subject = allSubjects.firstWhere(
      (s) => s.id == entry.subjectId,
      orElse: () => Subject(name: 'مادة غير معروفة', subjectId: ''),
    );

    String line1 = subject.name;
    String line2 = '';
    String time = '${entry.startTime} - ${entry.endTime}';

    if (_selectedClass != null) {
      final teacher = allTeachers.firstWhere(
        (t) => t.id == entry.teacherId,
        orElse: () => Teacher(
          id: null,
          name: 'معلم غير معروف',
          subject: '',
          email: '',
          phone: '',
        ),
      );
      line2 = teacher.name;
    } else if (_selectedTeacher != null) {
      final schoolClass = allClasses.firstWhere(
        (c) => c.id == entry.classId,
        orElse: () => SchoolClass(id: null, name: 'فصل غير معروف', classId: ''),
      );
      line2 = schoolClass.name;
    } else {
      final schoolClass = allClasses.firstWhere(
        (c) => c.id == entry.classId,
        orElse: () => SchoolClass(id: null, name: 'فصل غير معروف', classId: ''),
      );
      final teacher = allTeachers.firstWhere(
        (t) => t.id == entry.teacherId,
        orElse: () => Teacher(
          id: null,
          name: 'معلم غير معروف',
          subject: '',
          email: '',
          phone: '',
        ),
      );
      line1 = schoolClass.name;
      line2 = teacher.name;
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          line1,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Text(
          line2,
          style: Theme.of(context).textTheme.bodySmall,
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          time,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).primaryColor,
          ),
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  void _showEntryActions(TimetableEntry entry) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Wrap(
        children: <Widget>[
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('تعديل'),
            onTap: () {
              Navigator.of(ctx).pop();
              _navigateToAddEditTimetableEntry(entry: entry);
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title: const Text('حذف', style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.of(ctx).pop();
              _confirmDelete(entry);
            },
          ),
        ],
      ),
    );
  }

  void _confirmDelete(TimetableEntry entry) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: const Text('هل أنت متأكد من رغبتك في حذف هذه الحصة؟'),
        actions: <Widget>[
          TextButton(
            child: const Text('إلغاء'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          ),
          TextButton(
            child: const Text('حذف', style: TextStyle(color: Colors.red)),
            onPressed: () {
              Navigator.of(ctx).pop();
              _deleteEntry(entry);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _deleteEntry(TimetableEntry entry) async {
    try {
      final timetableProvider = Provider.of<TimetableProvider>(
        context,
        listen: false,
      );
      await timetableProvider.deleteTimetableEntry(entry.id!);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم حذف الحصة بنجاح.'),
          backgroundColor: Colors.green,
        ),
      );
      _loadTimetableData(); // Refresh the data
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('فشل حذف الحصة: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _navigateToAddEditTimetableEntry({TimetableEntry? entry}) async {
    // Make the function async
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddEditTimetableScreen(entry: entry),
      ),
    );
    if (!mounted) return; // Check mounted after push
    _loadTimetableData(); // Reload data after returning from add/edit screen
  }
}

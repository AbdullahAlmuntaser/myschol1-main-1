import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../grade_model.dart';
import '../../student_model.dart';
import '../../class_model.dart';
import '../../subject_model.dart';
import '../../providers/grade_provider.dart';
import '../../providers/student_provider.dart';
import '../../providers/class_provider.dart';
import '../../providers/subject_provider.dart';

class GradesBulkEntryTab extends StatefulWidget {
  const GradesBulkEntryTab({super.key});

  @override
  State<GradesBulkEntryTab> createState() => _GradesBulkEntryTabState();
}

class _GradesBulkEntryTabState extends State<GradesBulkEntryTab> {
  SchoolClass? _selectedClass;
  Subject? _selectedSubject;
  String? _selectedAssessmentType;

  // State Management
  bool _isLoading = false;
  List<Student> _studentsInClass = [];
  Map<String, Grade> _gradesMap = {}; // Key: "{studentId}-{assessmentType}"
  final Map<int, TextEditingController> _semester1Controllers = {};
  final Map<int, TextEditingController> _semester2Controllers = {};
  final Set<int> _dirtyStudentIds = {};

  final List<String> _assessmentTypes = ['واجب', 'اختبار', 'مشروع', 'مشاركة'];

  @override
  void dispose() {
    for (var controller in _semester1Controllers.values) {
      controller.dispose();
    }
    for (var controller in _semester2Controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  String _getGradeMapKey(int studentId, String assessmentType) {
    return '$studentId-$assessmentType';
  }

  Future<void> _loadData() async {
    if (_selectedClass == null ||
        _selectedSubject == null ||
        _selectedAssessmentType == null) {
      if (mounted) {
        setState(() {
          _studentsInClass = [];
          _gradesMap = {};
        });
      }
      return;
    }

    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }
    final StudentProvider studentProvider = context.read<StudentProvider>();
    final GradeProvider gradeProvider = context.read<GradeProvider>();

    // 1. Fetch students for the class
    final allStudents = await studentProvider.fetchStudents();
    if (!mounted) return; // Check mounted after await

    _studentsInClass = allStudents
        .where((s) => s.classId == _selectedClass!.classId)
        .toList();

    // 2. Fetch all grades for the class and subject in one go
    final grades = await gradeProvider.getGradesByClassAndSubject(
        _selectedClass!.id!, _selectedSubject!.id!);
    if (!mounted) return; // Check mounted after await

    // 3. Populate the grades map for quick lookup
    _gradesMap = {
      for (var grade in grades)
        _getGradeMapKey(grade.studentId, grade.assessmentType): grade
    };

    // 4. Initialize or update controllers
    for (var student in _studentsInClass) {
      _semester1Controllers
          .putIfAbsent(student.id!, () => TextEditingController());
      _semester2Controllers
          .putIfAbsent(student.id!, () => TextEditingController());

      final grade =
          _gradesMap[_getGradeMapKey(student.id!, _selectedAssessmentType!)];
      _semester1Controllers[student.id]!.text =
          grade?.semester1Grade?.toString() ?? '';
      _semester2Controllers[student.id]!.text =
          grade?.semester2Grade?.toString() ?? '';
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveGrades() async {
    if (_selectedClass == null ||
        _selectedSubject == null ||
        _selectedAssessmentType == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('الرجاء اختيار الفصل والمادة ونوع التقييم.')));
      }
      return;
    }

    if (_dirtyStudentIds.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('لا توجد تغييرات لحفظها.')));
      }
      return;
    }

    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    final GradeProvider gradeProvider = context.read<GradeProvider>();
    final List<Grade> gradesToUpsert = [];

    for (final studentId in _dirtyStudentIds) {
      final key = _getGradeMapKey(studentId, _selectedAssessmentType!);
      final existingGrade = _gradesMap[key];

      final semester1Grade =
          double.tryParse(_semester1Controllers[studentId]!.text);
      final semester2Grade =
          double.tryParse(_semester2Controllers[studentId]!.text);

      if (existingGrade != null) {
        // Update existing grade
        gradesToUpsert.add(existingGrade.copyWith(
          semester1Grade: semester1Grade,
          semester2Grade: semester2Grade,
        ));
      } else {
        // Add new grade if at least one value is present
        if (semester1Grade != null || semester2Grade != null) {
          gradesToUpsert.add(Grade(
            studentId: studentId,
            classId: _selectedClass!.id!,
            subjectId: _selectedSubject!.id!,
            assessmentType: _selectedAssessmentType!,
            semester1Grade: semester1Grade,
            semester2Grade: semester2Grade,
            weight: 1.0, // Default weight
          ));
        }
      }
    }

    try {
      await gradeProvider.upsertGrades(gradesToUpsert);
      if (!mounted) return; // Check mounted after await
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم حفظ الدرجات بنجاح!')));
      if (mounted) {
        setState(() {
          _dirtyStudentIds.clear();
        });
      }
      await _loadData(); // Reload data to get updated IDs and computed values
    } catch (e) {
      if (!mounted) return; // Check mounted after await
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('حدث خطأ أثناء حفظ الدرجات: $e')));
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
    return Consumer3<ClassProvider, SubjectProvider, StudentProvider>(builder:
        (context, classProvider, subjectProvider, studentProvider, child) {
      return Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildFilterDropdowns(
                    classProvider.classes, subjectProvider.subjects),
                const SizedBox(height: 24),
                if (_studentsInClass.isNotEmpty)
                  Expanded(child: _buildGradesListView()),
                if (_studentsInClass.isEmpty && !_isLoading)
                  const Center(
                      child:
                          Text('الرجاء اختيار فصل ومادة لعرض الطلاب.')),
                const SizedBox(height: 24),
                if (_studentsInClass.isNotEmpty)
                  ElevatedButton(
                    onPressed: _saveGrades,
                    child: const Text('حفظ الدرجات'),
                  ),
              ],
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withAlpha((255 * 0.5).round()), // Use withAlpha instead of withOpacity
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      );
    });
  }

  Widget _buildFilterDropdowns(
      List<SchoolClass> classes, List<Subject> subjects) {
    return Column(
      children: [
        DropdownButtonFormField<SchoolClass>(
          decoration: const InputDecoration(labelText: 'الفصل'),
          initialValue: _selectedClass,
          items: classes.map((c) {
            return DropdownMenuItem(value: c, child: Text(c.name));
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedClass = value;
              _dirtyStudentIds.clear();
            });
            _loadData();
          },
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<Subject>(
          decoration: const InputDecoration(labelText: 'المادة'),
          initialValue: _selectedSubject,
          items: subjects.map((s) {
            return DropdownMenuItem(value: s, child: Text(s.name));
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedSubject = value;
              _dirtyStudentIds.clear();
            });
            _loadData();
          },
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          decoration: const InputDecoration(labelText: 'نوع التقييم'),
          initialValue: _selectedAssessmentType,
          items: _assessmentTypes.map((type) {
            return DropdownMenuItem(value: type, child: Text(type));
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedAssessmentType = value;
              _dirtyStudentIds.clear();
            });
            _loadData();
          },
        ),
      ],
    );
  }

  Widget _buildGradesListView() {
    return ListView.builder(
      itemCount: _studentsInClass.length,
      itemBuilder: (context, index) {
        final student = _studentsInClass[index];
        final key = _getGradeMapKey(student.id!, _selectedAssessmentType!);
        final grade = _gradesMap[key];

        // Ensure controllers exist for this student
        _semester1Controllers
            .putIfAbsent(student.id!, () => TextEditingController());
        _semester2Controllers
            .putIfAbsent(student.id!, () => TextEditingController());
        
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            children: [
              if (_dirtyStudentIds.contains(student.id))
                const Padding(
                  padding: EdgeInsets.only(right: 8.0),
                  child: Icon(Icons.edit, color: Colors.blue, size: 16),
                ),
              Expanded(flex: 2, child: Text(student.name)),
              const SizedBox(width: 8),
              Expanded(
                flex: 1,
                child: TextFormField(
                  controller: _semester1Controllers[student.id],
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                      labelText: 'فصل 1', border: OutlineInputBorder()),
                  onChanged: (_) =>
                      setState(() => _dirtyStudentIds.add(student.id!)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 1,
                child: TextFormField(
                  controller: _semester2Controllers[student.id],
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                      labelText: 'فصل 2', border: OutlineInputBorder()),
                  onChanged: (_) =>
                      setState(() => _dirtyStudentIds.add(student.id!)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 1,
                child: Text(
                  'النهائي: ${(grade?.finalGrade ?? 0.0).toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

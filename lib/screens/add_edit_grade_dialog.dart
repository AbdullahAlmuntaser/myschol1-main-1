import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../grade_model.dart';
import '../student_model.dart';
import '../subject_model.dart';
import '../class_model.dart';
import '../providers/grade_provider.dart';
import '../providers/student_provider.dart';
import '../providers/subject_provider.dart';
import '../providers/class_provider.dart';

class AddEditGradeDialog extends StatefulWidget {
  final Grade? grade; // Null for adding, non-null for editing

  const AddEditGradeDialog({super.key, this.grade});

  @override
  State<AddEditGradeDialog> createState() => _AddEditGradeDialogState();
}

class _AddEditGradeDialogState extends State<AddEditGradeDialog> {
  final _formKey = GlobalKey<FormState>();
  Student? _selectedStudent;
  Subject? _selectedSubject;
  SchoolClass? _selectedClass;
  String? _selectedAssessmentType;
  final TextEditingController _semester1GradeController = TextEditingController();
  final TextEditingController _semester2GradeController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();

  final List<String> _assessmentTypes = ['واجب', 'اختبار', 'مشروع', 'مشاركة'];

  @override
  void initState() {
    super.initState();
    if (widget.grade != null) {
      // Editing existing grade
      _semester1GradeController.text = widget.grade!.semester1Grade?.toString() ?? '';
      _semester2GradeController.text = widget.grade!.semester2Grade?.toString() ?? '';
      _weightController.text = widget.grade!.weight.toString();
      _selectedAssessmentType = widget.grade!.assessmentType;

      // Set initial dropdown values based on existing grade
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final studentProvider = Provider.of<StudentProvider>(
          context,
          listen: false,
        );
        final subjectProvider = Provider.of<SubjectProvider>(
          context,
          listen: false,
        );
        final classProvider = Provider.of<ClassProvider>(
          context,
          listen: false,
        );

        setState(() {
          _selectedStudent = studentProvider.students.firstWhere(
            (s) => s.id == widget.grade!.studentId,
            orElse: () =>
                Student(id: -1, name: '', dob: '', phone: '', grade: ''),
          );
          _selectedSubject = subjectProvider.subjects.firstWhere(
            (s) => s.id == widget.grade!.subjectId,
            orElse: () => Subject(id: -1, name: '', subjectId: ''),
          );
          _selectedClass = classProvider.classes.firstWhere(
            (c) => c.id == widget.grade!.classId,
            orElse: () => SchoolClass(id: -1, name: '', classId: ''),
          );
        });
      });
    }
  }

  @override
  void dispose() {
    _semester1GradeController.dispose();
    _semester2GradeController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _saveGrade() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedStudent == null ||
        _selectedSubject == null ||
        _selectedClass == null ||
        _selectedAssessmentType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء ملء جميع الحقول المطلوبة.')),
      );
      return;
    }

    final gradeProvider = Provider.of<GradeProvider>(context, listen: false);

    final semester1Grade = double.tryParse(_semester1GradeController.text);
    final semester2Grade = double.tryParse(_semester2GradeController.text);
    final weight = double.parse(_weightController.text);

    if (widget.grade == null) {
      // Add new grade
      final newGrade = Grade(
        studentId: _selectedStudent!.id!,
        subjectId: _selectedSubject!.id!,
        classId: _selectedClass!.id!,
        assessmentType: _selectedAssessmentType!,
        semester1Grade: semester1Grade,
        semester2Grade: semester2Grade,
        weight: weight,
      );
      await gradeProvider.addGrade(newGrade);
    } else {
      // Update existing grade
      final updatedGrade = widget.grade!.copyWith(
        studentId: _selectedStudent!.id!,
        subjectId: _selectedSubject!.id!,
        classId: _selectedClass!.id!,
        assessmentType: _selectedAssessmentType!,
        semester1Grade: semester1Grade,
        semester2Grade: semester2Grade,
        weight: weight,
      );
      await gradeProvider.updateGrade(updatedGrade);
    }

    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.grade == null ? 'إضافة درجة جديدة' : 'تعديل درجة'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Consumer<StudentProvider>(
                builder: (context, studentProvider, child) {
                  return DropdownButtonFormField<Student>(
                    decoration: const InputDecoration(labelText: 'الطالب'),
                    initialValue:
                        _selectedStudent, // Changed 'value' to 'initialValue'
                    items: studentProvider.students.map((student) {
                      return DropdownMenuItem(
                        value: student,
                        child: Text(student.name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedStudent = value;
                      });
                    },
                    validator: (value) =>
                        value == null ? 'الرجاء اختيار طالب' : null,
                  );
                },
              ),
              const SizedBox(height: 16),
              Consumer<SubjectProvider>(
                builder: (context, subjectProvider, child) {
                  return DropdownButtonFormField<Subject>(
                    decoration: const InputDecoration(labelText: 'المادة'),
                    initialValue:
                        _selectedSubject, // Changed 'value' to 'initialValue'
                    items: subjectProvider.subjects.map((subject) {
                      return DropdownMenuItem(
                        value: subject,
                        child: Text(subject.name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedSubject = value;
                      });
                    },
                    validator: (value) =>
                        value == null ? 'الرجاء اختيار مادة' : null,
                  );
                },
              ),
              const SizedBox(height: 16),
              Consumer<ClassProvider>(
                builder: (context, classProvider, child) {
                  return DropdownButtonFormField<SchoolClass>(
                    decoration: const InputDecoration(labelText: 'الفصل'),
                    initialValue:
                        _selectedClass, // Changed 'value' to 'initialValue'
                    items: classProvider.classes.map((schoolClass) {
                      return DropdownMenuItem(
                        value: schoolClass,
                        child: Text(schoolClass.name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedClass = value;
                      });
                    },
                    validator: (value) =>
                        value == null ? 'الرجاء اختيار فصل' : null,
                  );
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'نوع التقييم'),
                initialValue:
                    _selectedAssessmentType, // Changed 'value' to 'initialValue'
                items: _assessmentTypes.map((type) {
                  return DropdownMenuItem(value: type, child: Text(type));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedAssessmentType = value;
                  });
                },
                validator: (value) =>
                    value == null ? 'الرجاء اختيار نوع التقييم' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _semester1GradeController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'درجة الفصل الأول',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value != null && value.isNotEmpty && double.tryParse(value) == null) {
                    return 'الرجاء إدخال رقم صحيح';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _semester2GradeController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'درجة الفصل الثاني',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value != null && value.isNotEmpty && double.tryParse(value) == null) {
                    return 'الرجاء إدخال رقم صحيح';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _weightController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'الوزن النسبي',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء إدخال الوزن النسبي';
                  }
                  if (double.tryParse(value) == null) {
                    return 'الرجاء إدخال رقم صحيح';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('إلغاء'),
        ),
        ElevatedButton(onPressed: _saveGrade, child: const Text('حفظ')),
      ],
    );
  }
}

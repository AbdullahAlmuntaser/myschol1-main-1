import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/class_provider.dart';
import '../../../providers/student_provider.dart';
import '../../../providers/grade_provider.dart';
import '../../../providers/subject_provider.dart';
import '../../../student_model.dart';
import '../../../grade_model.dart';
import '../../../subject_model.dart';

class StudentResult {
  final String studentName;
  final double averageGrade; // Overall average
  final String academicStatus;
  final String studentId;
  final int? studentDbId;

  // New fields for subject-wise grades
  final Map<String, double?> subjectSemester1Grades;
  final Map<String, double?> subjectSemester2Grades;
  final Map<String, double> subjectFinalGrades; // Calculated final grade for each subject

  StudentResult({
    required this.studentName,
    required this.averageGrade,
    required this.academicStatus,
    required this.studentId,
    this.studentDbId,
    this.subjectSemester1Grades = const {},
    this.subjectSemester2Grades = const {},
    this.subjectFinalGrades = const {},
  });
}

class StudentResultsTab extends StatefulWidget {
  const StudentResultsTab({super.key});

  @override
  StudentResultsTabState createState() => StudentResultsTabState();
}

class StudentResultsTabState extends State<StudentResultsTab> {
  String? _selectedAcademicYear;
  String? _selectedSemester;
  String? _selectedClassId;

  List<StudentResult> _studentResults = [];
  bool _isLoading = false;

  final List<String> _academicYears = ['2024-2025', '2023-2024', '2022-2023'];
  final List<String> _semesters = ['الفصل الأول', 'الفصل الثاني'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Provider.of<ClassProvider>(context, listen: false).fetchClasses();
      Provider.of<SubjectProvider>(
        context,
        listen: false,
      ).fetchSubjects(); // Fetch subjects
    });
  }

  Future<void> _calculateResults() async {
    final messenger = ScaffoldMessenger.of(context);
    if (_selectedClassId == null) {
      messenger.showSnackBar(const SnackBar(content: Text('يرجى اختيار فصل أولاً.')));
      return;
    }

    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _studentResults = [];
    });

    final studentProvider = Provider.of<StudentProvider>(
      context,
      listen: false,
    );
    final gradeProvider = Provider.of<GradeProvider>(context, listen: false);

    await studentProvider.searchStudents('', classId: _selectedClassId);
    if (!mounted) return;
    final List<Student> students = studentProvider.students;

    final subjectProvider = Provider.of<SubjectProvider>(context, listen: false);
    final List<Subject> allSubjects = subjectProvider.subjects;
    final Map<int, String> subjectIdToName = {for (var s in allSubjects) s.id!: s.name};

    List<StudentResult> results = [];
    for (var student in students) {
      if (student.id == null) continue;

      final List<Grade> grades = await gradeProvider.getGradesByStudent(
        student.id!,
      );
      if (!mounted) return;

      double totalWeightedGrade = 0;
      double totalWeight = 0;
      Map<String, double?> studentSubjectSemester1Grades = {};
      Map<String, double?> studentSubjectSemester2Grades = {};
      Map<String, double> studentSubjectFinalGrades = {};

      if (grades.isNotEmpty) {
        for (var grade in grades) {
          String subjectName = subjectIdToName[grade.subjectId] ?? 'Unknown Subject';
          totalWeightedGrade += grade.finalGrade * grade.weight;
          totalWeight += grade.weight;

          studentSubjectSemester1Grades[subjectName] = grade.semester1Grade;
          studentSubjectSemester2Grades[subjectName] = grade.semester2Grade;
          studentSubjectFinalGrades[subjectName] = grade.finalGrade;
        }
        double average = totalWeight > 0 ? totalWeightedGrade / totalWeight : 0.0;
        String status = average >= 50 ? 'ناجح' : 'راسب';

        results.add(
          StudentResult(
            studentId: student.academicNumber ?? student.id.toString(),
            studentName: student.name,
            averageGrade: average,
            academicStatus: status,
            studentDbId: student.id,
            subjectSemester1Grades: studentSubjectSemester1Grades,
            subjectSemester2Grades: studentSubjectSemester2Grades,
            subjectFinalGrades: studentSubjectFinalGrades,
          ),
        );
      } else {
        results.add(
          StudentResult(
            studentId: student.academicNumber ?? student.id.toString(),
            studentName: student.name,
            averageGrade: 0,
            academicStatus: 'لا يوجد',
            studentDbId: student.id,
          ),
        );
      }
    }

    if (!mounted) return;
    setState(() {
      _studentResults = results;
      _isLoading = false;
    });

    messenger.showSnackBar(
      const SnackBar(
        content: Text('تم حساب النتائج بنجاح.'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _viewGradeDetails(int studentDbId, String studentName) async {
    if (!mounted) return;
    final gradeProvider = Provider.of<GradeProvider>(context, listen: false);
    final subjectProvider = Provider.of<SubjectProvider>(
      context,
      listen: false,
    );
    final List<Grade> grades = await gradeProvider.getGradesByStudent(
      studentDbId,
    );
    if (!mounted) return;
    final List<Subject> subjects = subjectProvider.subjects;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('درجات الطالب $studentName'),
        content: grades.isEmpty
            ? const Text('لا توجد درجات مسجلة لهذا الطالب.')
            : SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: grades.length,
                  itemBuilder: (context, index) {
                    final grade = grades[index];
                    final subject = subjects.firstWhere(
                      (s) => s.id == grade.subjectId,
                      orElse: () => Subject(
                        id: grade.subjectId,
                        name: 'مادة غير معروفة',
                        subjectId: 'UNKNOWN',
                      ),
                    );
                    return ListTile(
                      title: Text(subject.name),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('الفصل الأول: ${grade.semester1Grade?.toStringAsFixed(2) ?? 'N/A'}'),
                          Text('الفصل الثاني: ${grade.semester2Grade?.toStringAsFixed(2) ?? 'N/A'}'),
                          Text('النهائية: ${grade.finalGrade.toStringAsFixed(2)}'),
                          Text('النوع: ${grade.assessmentType}'),
                        ],
                      ),
                    );
                  },
                ),
              ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final classProvider = Provider.of<ClassProvider>(context);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'نتائج الطلاب',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 20),
          // Filters
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'العام الدراسي'),
                  items: _academicYears
                      .map(
                        (year) =>
                            DropdownMenuItem(value: year, child: Text(year)),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() => _selectedAcademicYear = value);
                    _calculateResults();
                  },
                  initialValue: _selectedAcademicYear,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'الفصل الدراسي'),
                  items: _semesters
                      .map(
                        (sem) => DropdownMenuItem(value: sem, child: Text(sem)),
                      )
                      .toList(),
                  onChanged: (value) {
                     setState(() => _selectedSemester = value);
                    _calculateResults();
                  },
                  initialValue: _selectedSemester,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'الفصل'),
                  items: classProvider.classes.map((schoolClass) {
                    return DropdownMenuItem(
                      value: schoolClass.classId,
                      child: Text(schoolClass.name),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => _selectedClassId = value);
                    _calculateResults();
                  },
                  initialValue: _selectedClassId,
                  validator: (value) =>
                      value == null ? 'يرجى اختيار فصل' : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Table
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _studentResults.isEmpty
                ? const Center(
                    child: Text(
                      'لا توجد بيانات لعرضها. اختر الفلاتر لبدء حساب النتائج.',
                    ),
                  )
                : SingleChildScrollView(
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('الرقم الأكاديمي')),
                        DataColumn(label: Text('الاسم')),
                        DataColumn(label: Text('المعدل العام')),
                        DataColumn(label: Text('الحالة الأكاديمية')),
                        DataColumn(
                          label: Text('إجراءات'),
                        ),
                      ],
                      rows: _studentResults.map((result) {
                        return DataRow(
                          cells: [
                            DataCell(Text(result.studentId)),
                            DataCell(Text(result.studentName)),
                            DataCell(
                              Text(result.averageGrade.toStringAsFixed(2)),
                            ),
                            DataCell(
                              Text(
                                result.academicStatus,
                                style: TextStyle(
                                  color: result.academicStatus == 'ناجح'
                                      ? Colors.green
                                      : Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            DataCell(
                              IconButton(
                                icon: const Icon(Icons.info_outline),
                                onPressed: () => _viewGradeDetails(
                                  result.studentDbId!,
                                  result.studentName,
                                ),
                                tooltip: 'عرض التفاصيل',
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

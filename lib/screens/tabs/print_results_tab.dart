import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:printing/printing.dart';
import 'package:file_saver/file_saver.dart';
import '../../../providers/class_provider.dart';
import '../../../providers/student_provider.dart';
import '../../../providers/grade_provider.dart';
import '../../../providers/subject_provider.dart';
import '../../../student_model.dart';
import '../../../grade_model.dart';
import '../../../subject_model.dart';
import '../../../services/report_generator_service.dart';

enum ReportType { classGradeSheet, studentGradeSheet, successFailureReport }

class PrintResultsTab extends StatefulWidget {
  const PrintResultsTab({super.key});

  @override
  PrintResultsTabState createState() => PrintResultsTabState();
}

class PrintResultsTabState extends State<PrintResultsTab> {
  ReportType? _selectedReportType;
  String? _selectedClassId;
  int? _selectedStudentId;
  bool _isLoading = false;

  final ReportGeneratorService _reportService = ReportGeneratorService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ClassProvider>(context, listen: false).fetchClasses();
      Provider.of<StudentProvider>(context, listen: false).fetchStudents();
      Provider.of<SubjectProvider>(context, listen: false).fetchSubjects();
    });
  }

  Future<Map<String, dynamic>> _gatherDataForReport() async {
    final classProvider = Provider.of<ClassProvider>(context, listen: false);
    final studentProvider = Provider.of<StudentProvider>(
      context,
      listen: false,
    );
    final gradeProvider = Provider.of<GradeProvider>(context, listen: false);
    final subjectProvider = Provider.of<SubjectProvider>(
      context,
      listen: false,
    );

    await classProvider.fetchClasses();
    await studentProvider.fetchStudents();
    await subjectProvider.fetchSubjects();

    List<Subject> allSubjects = subjectProvider.subjects;
    List<Student> allStudents = studentProvider.students;

    if (_selectedReportType == ReportType.classGradeSheet ||
        _selectedReportType == ReportType.successFailureReport) {
      if (_selectedClassId == null) return {};
      final schoolClass = await classProvider.getClassByClassIdString(
        _selectedClassId!,
      );
      if (schoolClass == null) return {};

      await studentProvider.searchStudents('', classId: _selectedClassId);
      if (!mounted) return {};
      final studentsInClass = studentProvider.students;
      final Map<int, List<Grade>> studentGrades = {};
      final List<Map<String, dynamic>> studentResults =
          []; // For success/failure report
      for (var student in studentsInClass) {
        if (student.id != null) {
          final grades = await gradeProvider.getGradesByStudent(student.id!);
          studentGrades[student.id!] = grades;

          double average = 0;
          if (grades.isNotEmpty) {
            average =
                grades.map((g) => g.gradeValue).reduce((a, b) => a + b) /
                grades.length;
          }
          studentResults.add({
            'studentName': student.name,
            'average': average,
            'status': average >= 50 ? 'ناجح' : 'راسب',
          });
        }
      }

      return {
        'schoolClass': schoolClass,
        'students': studentsInClass,
        'studentGrades': studentGrades,
        'allSubjects': allSubjects,
        'studentResults': studentResults, // Add for success/failure report
      };
    } else if (_selectedReportType == ReportType.studentGradeSheet) {
      if (_selectedStudentId == null) return {};
      final student = allStudents.firstWhere((s) => s.id == _selectedStudentId);
      final grades = await gradeProvider.getGradesByStudent(
        _selectedStudentId!,
      );
      return {'student': student, 'grades': grades, 'allSubjects': allSubjects};
    }
    return {};
  }

  Future<void> _generateAndPrintPdf() async {
    setState(() => _isLoading = true);
    final data = await _gatherDataForReport();
    if (data.isEmpty) {
      _showError('يرجى تحديد فصل أو طالب.');
      return;
    }

    Uint8List pdfData;
    if (_selectedReportType == ReportType.classGradeSheet) {
      pdfData = await _reportService.generateClassGradeSheetPdf(
        data['schoolClass'],
        data['students'],
        data['studentGrades'],
        data['allSubjects'],
      );
    } else if (_selectedReportType == ReportType.studentGradeSheet) {
      pdfData = await _reportService.generateStudentGradeSheetPdf(
        data['student'],
        data['grades'],
        data['allSubjects'],
      );
    } else if (_selectedReportType == ReportType.successFailureReport) {
      pdfData = await _reportService.generateSuccessFailureReportPdf(
        data['schoolClass'],
        data['studentResults'],
      );
    } else {
      _showError('نوع التقرير غير مدعوم لطباعة PDF.');
      return;
    }

    await Printing.layoutPdf(onLayout: (format) => pdfData);
    if (!mounted) return;
    setState(() => _isLoading = false);
  }

  Future<void> _generateAndDownloadPdf() async {
    setState(() => _isLoading = true);
    final data = await _gatherDataForReport();
    if (data.isEmpty) {
      _showError('يرجى تحديد فصل أو طالب.');
      return;
    }

    Uint8List pdfData;
    String fileName;

    if (_selectedReportType == ReportType.classGradeSheet) {
      pdfData = await _reportService.generateClassGradeSheetPdf(
        data['schoolClass'],
        data['students'],
        data['studentGrades'],
        data['allSubjects'],
      );
      fileName = 'class_grades_${data['schoolClass'].classId}';
    } else if (_selectedReportType == ReportType.studentGradeSheet) {
      pdfData = await _reportService.generateStudentGradeSheetPdf(
        data['student'],
        data['grades'],
        data['allSubjects'],
      );
      fileName =
          'student_grades_${data['student'].academicNumber ?? data['student'].id}';
    } else if (_selectedReportType == ReportType.successFailureReport) {
      pdfData = await _reportService.generateSuccessFailureReportPdf(
        data['schoolClass'],
        data['studentResults'],
      );
      fileName = 'success_failure_report_${data['schoolClass'].classId}';
    } else {
      _showError('نوع التقرير غير مدعوم لتنزيل PDF.');
      return;
    }

    await FileSaver.instance.saveFile(name: '$fileName.pdf', bytes: pdfData);
    if (!mounted) return;
    setState(() => _isLoading = false);
  }

  Future<void> _generateAndExportExcel() async {
    setState(() => _isLoading = true);
    final data = await _gatherDataForReport();
    if (data.isEmpty) {
      _showError('يرجى تحديد فصل أو طالب.');
      return;
    }

    List<int>? excelData;
    String fileName;

    if (_selectedReportType == ReportType.classGradeSheet) {
      excelData = await _reportService.generateClassGradeSheetExcel(
        data['schoolClass'],
        data['students'],
        data['studentGrades'],
        data['allSubjects'],
      );
      fileName = 'class_grades_${data['schoolClass'].classId}';
    } else if (_selectedReportType == ReportType.studentGradeSheet) {
      excelData = await _reportService.generateStudentGradeSheetExcel(
        data['student'],
        data['grades'],
        data['allSubjects'],
      );
      fileName =
          'student_grades_${data['student'].academicNumber ?? data['student'].id}';
    } else if (_selectedReportType == ReportType.successFailureReport) {
      excelData = await _reportService.generateSuccessFailureReportExcel(
        data['schoolClass'],
        data['studentResults'],
      );
      fileName = 'success_failure_report_${data['schoolClass'].classId}';
    } else {
      _showError('نوع التقرير غير مدعوم لتصدير Excel.');
      return;
    }

    if (excelData != null) {
      await FileSaver.instance.saveFile(
        name: '$fileName.xlsx',
        bytes: Uint8List.fromList(excelData),
      );
    }
    if (!mounted) return;
    setState(() => _isLoading = false);
  }

  void _showError(String message) {
    if (!mounted) return;
    setState(() => _isLoading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    final classProvider = Provider.of<ClassProvider>(context);
    final studentProvider = Provider.of<StudentProvider>(context);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'طباعة كشوف الدرجات',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 24),
                DropdownButtonFormField<ReportType>(
                  decoration: const InputDecoration(labelText: 'نوع التقرير'),
                  initialValue: _selectedReportType,
                  items: const [
                    DropdownMenuItem(
                      value: ReportType.classGradeSheet,
                      child: Text('كشف درجات الفصل'),
                    ),
                    DropdownMenuItem(
                      value: ReportType.studentGradeSheet,
                      child: Text('كشف درجات الطالب'),
                    ),
                    DropdownMenuItem(
                      value: ReportType.successFailureReport,
                      child: Text('تقرير النجاح والرسوب'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedReportType = value;
                      _selectedClassId = null;
                      _selectedStudentId = null;
                    });
                  },
                ),
                const SizedBox(height: 16),
                if (_selectedReportType == ReportType.classGradeSheet ||
                    _selectedReportType == ReportType.successFailureReport)
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'اختر الفصل'),
                    initialValue: _selectedClassId,
                    items: classProvider.classes
                        .map(
                          (c) => DropdownMenuItem(
                            value: c.classId,
                            child: Text(c.name),
                          ),
                        )
                        .toList(),
                    onChanged: (value) =>
                        setState(() => _selectedClassId = value),
                    validator: (value) =>
                        value == null ? 'الرجاء اختيار فصل' : null,
                  ),
                if (_selectedReportType == ReportType.studentGradeSheet)
                  DropdownButtonFormField<int>(
                    decoration: const InputDecoration(labelText: 'اختر الطالب'),
                    initialValue: _selectedStudentId,
                    items: studentProvider.students
                        .map(
                          (s) => DropdownMenuItem(
                            value: s.id,
                            child: Text(s.name),
                          ),
                        )
                        .toList(),
                    onChanged: (value) =>
                        setState(() => _selectedStudentId = value),
                    validator: (value) =>
                        value == null ? 'الرجاء اختيار طالب' : null,
                  ),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.print),
                      label: const Text('طباعة'),
                      onPressed:
                          (_selectedReportType == ReportType.classGradeSheet &&
                                  _selectedClassId == null) ||
                              (_selectedReportType ==
                                      ReportType.studentGradeSheet &&
                                  _selectedStudentId == null) ||
                              (_selectedReportType ==
                                      ReportType.successFailureReport &&
                                  _selectedClassId == null)
                          ? null
                          : _generateAndPrintPdf,
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.picture_as_pdf),
                      label: const Text('تنزيل PDF'),
                      onPressed:
                          (_selectedReportType == ReportType.classGradeSheet &&
                                  _selectedClassId == null) ||
                              (_selectedReportType ==
                                      ReportType.studentGradeSheet &&
                                  _selectedStudentId == null) ||
                              (_selectedReportType ==
                                      ReportType.successFailureReport &&
                                  _selectedClassId == null)
                          ? null
                          : _generateAndDownloadPdf,
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.table_chart),
                      label: const Text('تصدير Excel'),
                      onPressed:
                          (_selectedReportType == ReportType.classGradeSheet &&
                                  _selectedClassId == null) ||
                              (_selectedReportType ==
                                      ReportType.studentGradeSheet &&
                                  _selectedStudentId == null) ||
                              (_selectedReportType ==
                                      ReportType.successFailureReport &&
                                  _selectedClassId == null)
                          ? null
                          : _generateAndExportExcel,
                    ),
                  ],
                ),
              ],
            ),
    );
  }
}

import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:excel/excel.dart';
import '../class_model.dart';
import '../student_model.dart';
import '../grade_model.dart';
import '../subject_model.dart'; // Import Subject model

class ReportGeneratorService {
  String _getSubjectName(int subjectId, List<Subject> allSubjects) {
    return allSubjects
        .firstWhere(
          (s) => s.id == subjectId,
          orElse: () => Subject(
            id: subjectId,
            name: 'Unknown Subject',
            subjectId: 'UNKNOWN',
          ),
        )
        .name;
  }

  Future<Uint8List> generateClassGradeSheetPdf(
    SchoolClass schoolClass,
    List<Student> students,
    Map<int, List<Grade>> studentGrades,
    List<Subject> allSubjects,
  ) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              text: 'Grade Sheet for Class: ${schoolClass.name}',
            ),
            pw.TableHelper.fromTextArray(
              headers: ['Student ID', 'Student Name', 'Subject', 'Score'],
              data: _buildClassGradeTableData(
                students,
                studentGrades,
                allSubjects,
              ),
            ),
          ];
        },
      ),
    );

    return pdf.save();
  }

  List<List<String>> _buildClassGradeTableData(
    List<Student> students,
    Map<int, List<Grade>> studentGrades,
    List<Subject> allSubjects,
  ) {
    final List<List<String>> tableData = [];
    for (var student in students) {
      final grades = studentGrades[student.id] ?? [];
      if (grades.isEmpty) {
        tableData.add([
          student.academicNumber ?? student.id.toString(),
          student.name,
          'N/A',
          'N/A',
        ]);
      } else {
        for (var grade in grades) {
          tableData.add([
            student.academicNumber ?? student.id.toString(),
            student.name,
            _getSubjectName(grade.subjectId, allSubjects),
            grade.gradeValue.toStringAsFixed(2),
          ]);
        }
      }
    }
    return tableData;
  }

  Future<List<int>?> generateClassGradeSheetExcel(
    SchoolClass schoolClass,
    List<Student> students,
    Map<int, List<Grade>> studentGrades,
    List<Subject> allSubjects,
  ) async {
    var excel = Excel.createExcel();
    Sheet sheetObject = excel['${schoolClass.name} Grades'];

    sheetObject.appendRow([
      TextCellValue('Student ID'),
      TextCellValue('Student Name'),
      TextCellValue('Subject'),
      TextCellValue('Score'),
    ]);

    for (var student in students) {
      final grades = studentGrades[student.id] ?? [];
      if (grades.isEmpty) {
        sheetObject.appendRow([
          TextCellValue(student.academicNumber ?? student.id.toString()),
          TextCellValue(student.name),
          TextCellValue('N/A'),
          TextCellValue('N/A'),
        ]);
      } else {
        for (var grade in grades) {
          sheetObject.appendRow([
            TextCellValue(student.academicNumber ?? student.id.toString()),
            TextCellValue(student.name),
            TextCellValue(_getSubjectName(grade.subjectId, allSubjects)),
            DoubleCellValue(grade.gradeValue),
          ]);
        }
      }
    }
    return excel.encode();
  }

  Future<Uint8List> generateStudentGradeSheetPdf(
    Student student,
    List<Grade> grades,
    List<Subject> allSubjects,
  ) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              text: 'Grade Sheet for Student: ${student.name}',
            ),
            pw.TableHelper.fromTextArray(
              headers: ['Subject', 'Assessment Type', 'Score', 'Weight'],
              data: _buildStudentGradeTableData(grades, allSubjects),
            ),
          ];
        },
      ),
    );

    return pdf.save();
  }

  List<List<String>> _buildStudentGradeTableData(
    List<Grade> grades,
    List<Subject> allSubjects,
  ) {
    final List<List<String>> tableData = [];
    for (var grade in grades) {
      tableData.add([
        _getSubjectName(grade.subjectId, allSubjects),
        grade.assessmentType,
        grade.gradeValue.toStringAsFixed(2),
        grade.weight.toStringAsFixed(2),
      ]);
    }
    return tableData;
  }

  Future<List<int>?> generateStudentGradeSheetExcel(
    Student student,
    List<Grade> grades,
    List<Subject> allSubjects,
  ) async {
    var excel = Excel.createExcel();
    Sheet sheetObject = excel['${student.name} Grades'];

    sheetObject.appendRow([
      TextCellValue('Subject'),
      TextCellValue('Assessment Type'),
      TextCellValue('Score'),
      TextCellValue('Weight'),
    ]);

    for (var grade in grades) {
      sheetObject.appendRow([
        TextCellValue(_getSubjectName(grade.subjectId, allSubjects)),
        TextCellValue(grade.assessmentType),
        DoubleCellValue(grade.gradeValue),
        DoubleCellValue(grade.weight),
      ]);
    }
    return excel.encode();
  }

  Future<Uint8List> generateSuccessFailureReportPdf(
    SchoolClass schoolClass,
    List<Map<String, dynamic>> studentResults,
  ) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              text: 'Success/Failure Report for Class: ${schoolClass.name}',
            ),
            pw.TableHelper.fromTextArray(
              headers: ['Student Name', 'Average Grade', 'Academic Status'],
              data: _buildSuccessFailureTableData(studentResults),
            ),
          ];
        },
      ),
    );

    return pdf.save();
  }

  List<List<String>> _buildSuccessFailureTableData(
    List<Map<String, dynamic>> studentResults,
  ) {
    final List<List<String>> tableData = [];
    for (var result in studentResults) {
      tableData.add([
        result['studentName'].toString(),
        result['average'].toStringAsFixed(2),
        result['status'].toString(),
      ]);
    }
    return tableData;
  }

  Future<List<int>?> generateSuccessFailureReportExcel(
    SchoolClass schoolClass,
    List<Map<String, dynamic>> studentResults,
  ) async {
    var excel = Excel.createExcel();
    Sheet sheetObject = excel['${schoolClass.name} Success/Failure'];

    sheetObject.appendRow([
      TextCellValue('Student Name'),
      TextCellValue('Average Grade'),
      TextCellValue('Academic Status'),
    ]);

    for (var result in studentResults) {
      sheetObject.appendRow([
        TextCellValue(result['studentName'].toString()),
        DoubleCellValue(result['average']),
        TextCellValue(result['status'].toString()),
      ]);
    }
    return excel.encode();
  }
}

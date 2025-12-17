import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/class_provider.dart';
import '../../../providers/student_provider.dart';
import '../../../providers/grade_provider.dart';
import '../../../class_model.dart';
import '../../../student_model.dart';

class StudentPromotionTab extends StatefulWidget {
  const StudentPromotionTab({super.key});

  @override
  StudentPromotionTabState createState() => StudentPromotionTabState();
}

class StudentPromotionTabState extends State<StudentPromotionTab> {
  bool _isLoading = false;

  Future<void> _previewPromotion() async {
    setState(() => _isLoading = true);

    final results = await _calculateAllStudentResults();
    final promotions = await _getPromotionDecisions(results);

    setState(() => _isLoading = false);

    final currentContext = context; // Capture context before async gap
    if (!currentContext.mounted) {
      return; // Check mounted status of the captured context
    }

    showDialog(
      context: currentContext,
      builder: (ctx) => AlertDialog(
        title: const Text('معاينة الترحيل'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: promotions.length,
            itemBuilder: (context, index) {
              final promo = promotions[index];
              return ListTile(
                title: Text(promo['studentName']!),
                subtitle: Text(
                  promo['decision']!,
                  style: TextStyle(
                    color: promo['decision']!.startsWith('ترحيل')
                        ? Colors.green
                        : Colors.orange,
                  ),
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

  Future<void> _performPromotion(
    BuildContext context,
    StudentProvider studentProvider,
    ScaffoldMessengerState scaffoldMessenger,
  ) async {
    final results = await _calculateAllStudentResults();
    final promotions = await _getPromotionDecisions(results);

    int promotedCount = 0;
    int retainedCount = 0;

    for (var promo in promotions) {
      if (promo['action'] == 'promote') {
        await studentProvider.searchStudents(promo['studentName']!);
        final studentList = studentProvider.students;
        if (studentList.isEmpty) {
          continue;
        }
        Student? student;
        for (var s in studentList) {
          if (s.name == promo['studentName']) {
            student = s;
            break;
          }
        }
        if (student == null) {
          continue; // Student not found, skip promotion for this student
        }
        final updatedStudent = student.copyWith(classId: promo['newClassId']);
        await studentProvider.updateStudent(updatedStudent);
        promotedCount++;
      } else {
        retainedCount++;
      }
    }

    if (!context.mounted) return;
    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: Text(
          'اكتمل الترحيل! تم ترحيل $promotedCount طالبًا، واحتفاظ بـ $retainedCount طالبًا.',
        ),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _startPromotion() async {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تأكيد الترحيل'),
        content: const Text(
          'هل أنت متأكد أنك تريد المتابعة؟ سيؤدي هذا إلى تحديث سجلات الطلاب.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                final currentContext =
                    context; // Capture context before async gap
                Navigator.of(ctx).pop(); // Close confirmation dialog
                setState(() => _isLoading = true);

                if (!currentContext.mounted) {
                  return; // Check mounted status before using context
                }
                final studentProvider = Provider.of<StudentProvider>(
                  currentContext,
                  listen: false,
                );
                final scaffoldMessenger = ScaffoldMessenger.of(currentContext);

                await _performPromotion(
                  currentContext,
                  studentProvider,
                  scaffoldMessenger,
                );

                setState(() => _isLoading = false);
              } catch (e, s) {
                // Also capture stack trace
                // Handle any errors that might occur
                developer.log(
                  'Error during promotion',
                  name: 'StudentPromotionTab',
                  level: 900, // WARNING
                  error: e,
                  stackTrace: s,
                );
                setState(() => _isLoading = false);
              }
            },
            child: const Text('متابعة'),
          ),
        ],
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _calculateAllStudentResults() async {
    final classProvider = Provider.of<ClassProvider>(context, listen: false);
    final studentProvider = Provider.of<StudentProvider>(
      context,
      listen: false,
    );
    final gradeProvider = Provider.of<GradeProvider>(context, listen: false);

    await classProvider.fetchClasses();

    List<Map<String, dynamic>> allResults = [];

    for (var schoolClass in classProvider.classes) {
      await studentProvider.searchStudents('', classId: schoolClass.classId);
      final students = studentProvider.students;

      for (var student in students) {
        if (student.id == null) continue;
        final grades = await gradeProvider.getGradesByStudent(student.id!);
        double average = 0;
        if (grades.isNotEmpty) {
          average =
              grades.map((g) => g.gradeValue).reduce((a, b) => a + b) /
              grades.length;
        }
        allResults.add({
          'studentName': student.name,
          'studentId': student.id,
          'currentClassId': student.classId,
          'average': average,
          'status': average >= 50 ? 'ناجح' : 'راسب',
        });
      }
    }
    return allResults;
  }

  Future<List<Map<String, String>>> _getPromotionDecisions(
    List<Map<String, dynamic>> results,
  ) async {
    final classProvider = Provider.of<ClassProvider>(context, listen: false);
    await classProvider.fetchClasses();
    List<SchoolClass> sortedClasses = List.from(classProvider.classes);
    sortedClasses.sort((a, b) => a.id!.compareTo(b.id!));

    Map<String, String?> nextClassMap = {};
    for (int i = 0; i < sortedClasses.length - 1; i++) {
      nextClassMap[sortedClasses[i].classId] = sortedClasses[i + 1].classId;
    }

    List<Map<String, String>> decisions = [];
    for (var result in results) {
      if (result['status'] == 'ناجح') {
        final nextClassId = nextClassMap[result['currentClassId']];
        if (nextClassId != null) {
          final nextClassName = sortedClasses
              .firstWhere((c) => c.classId == nextClassId)
              .name;
          decisions.add({
            'studentName': result['studentName'],
            'decision': 'ترحيل إلى $nextClassName',
            'action': 'promote',
            'newClassId': nextClassId,
          });
        } else {
          decisions.add({
            'studentName': result['studentName'],
            'decision': 'يبقى (أعلى صف)',
            'action': 'retain',
          });
        }
      } else {
        decisions.add({
          'studentName': result['studentName'],
          'decision': 'يبقى (راسب)',
          'action': 'retain',
        });
      }
    }
    return decisions;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                semanticsLabel: "جارٍ المعالجة...",
              ),
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'ترحيل الطلاب إلى الصف التالي',
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'سيتم ترحيل الطلاب الناجحين تلقائيًا إلى الصف التالي، بينما سيبقى الطلاب الراسبون في فصولهم الحالية.',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  icon: const Icon(Icons.trending_up),
                  label: const Text('بدء الترحيل'),
                  onPressed: _startPromotion,
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  icon: const Icon(Icons.preview),
                  label: const Text('معاينة النتائج قبل الترحيل'),
                  onPressed: _previewPromotion,
                ),
                const SizedBox(height: 16),
                TextButton(
                  child: const Text('إلغاء'),
                  onPressed: () {
                    // Optional: Navigate back or clear selection
                  },
                ),
              ],
            ),
    );
  }
}

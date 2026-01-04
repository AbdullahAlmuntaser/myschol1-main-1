import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../grade_model.dart';
import '../../student_model.dart';
import '../../subject_model.dart';
import '../../class_model.dart';
import '../../providers/grade_provider.dart';
import '../../providers/student_provider.dart';
import '../../providers/class_provider.dart';
import '../../providers/subject_provider.dart';
import '../../services/local_auth_service.dart'; // 1. Import LocalAuthService
import '../add_edit_grade_dialog.dart';

class GradesOverviewTab extends StatefulWidget {
  const GradesOverviewTab({super.key});

  @override
  State<GradesOverviewTab> createState() => _GradesOverviewTabState();
}

class _GradesOverviewTabState extends State<GradesOverviewTab> {
  int? _selectedStudentId;
  int? _selectedClassId;
  int? _selectedSubjectId;

  Future<Map<int, double>>? _averageGradesFuture;

  @override
  void initState() {
    super.initState();
    _updateAverageGrades(); // Initial call
  }

  void _updateAverageGrades() {
    setState(() {
      if (_selectedStudentId != null) {
        _averageGradesFuture = context
            .read<GradeProvider>()
            .getAverageGradesBySubject(_selectedStudentId!);
      } else {
        _averageGradesFuture = Future.value({}); // Return an empty map if no student is selected
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // 2. Get user role and determine if they have editing rights
    final authService = Provider.of<LocalAuthService>(context, listen: false);
    final userRole = authService.currentUser?.role;
    final bool canEditOrDelete = userRole == 'admin' || userRole == 'teacher';

    return Consumer4<GradeProvider, StudentProvider, SubjectProvider,
        ClassProvider>(
      builder: (context, gradeProvider, studentProvider, subjectProvider,
          classProvider, child) {
        if (gradeProvider.isLoading ||
            studentProvider.isLoading ||
            subjectProvider.isLoading ||
            classProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        // Create lookup maps for efficient access, ensuring non-nullable int keys
        final studentMap = {
          for (var s in studentProvider.students.where((s) => s.id != null))
            s.id!: s
        };
        final classMap = {
          for (var c in classProvider.classes.where((c) => c.id != null))
            c.id!: c
        };
        final subjectMap = {
          for (var s in subjectProvider.subjects.where((s) => s.id != null))
            s.id!: s
        };

        // Apply filters more efficiently
        final List<Grade> filteredGrades = gradeProvider.grades.where((grade) {
          final studentMatch =
              _selectedStudentId == null || grade.studentId == _selectedStudentId;
          final classMatch =
              _selectedClassId == null || grade.classId == _selectedClassId;
          final subjectMatch =
              _selectedSubjectId == null || grade.subjectId == _selectedSubjectId;
          return studentMatch && classMatch && subjectMatch;
        }).toList();

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildChart(),
              const SizedBox(height: 24),
              const Text(
                'جميع الدرجات المسجلة',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildFilterWidgets(
                  studentProvider.students,
                  classProvider.classes,
                  subjectProvider.subjects),
              const SizedBox(height: 16),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth >= 600) {
                      return _buildGradesDataTable(
                          filteredGrades, studentMap, classMap, subjectMap, canEditOrDelete);
                    } else {
                      return _buildGradesList(
                          filteredGrades, studentMap, classMap, subjectMap, canEditOrDelete);
                    }
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

    Widget _buildChart() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'متوسط الدرجات لكل مادة',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: FutureBuilder<Map<int, double>>(
            future: _averageGradesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('خطأ: ${snapshot.error}'));
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(
                    child: Text('لا توجد بيانات لعرض الرسم البياني.'));
              }

              final data = snapshot.data!;
              final subjectProvider = context.read<SubjectProvider>();
              final subjects = subjectProvider.subjects;

              final List<BarChartGroupData> barGroups = [];
              final List<String> subjectNames = [];

              int xIndex = 0;
              data.forEach((subjectId, averageGrade) {
                final subject = subjects.firstWhere(
                  (s) => s.id == subjectId,
                  orElse: () => Subject(
                      id: subjectId,
                      name: 'غير معروف',
                      subjectId: 'UNKNOWN',
                  ),
                );
                subjectNames.add(subject.name);

                barGroups.add(
                  BarChartGroupData(
                    x: xIndex,
                    barRods: [
                      BarChartRodData(
                        toY: averageGrade,
                        color: Colors.blue,
                        width: 16,
                      ),
                    ],
                  ),
                );
                xIndex++;
              });

              return BarChart(
                BarChartData(
                  barGroups: barGroups,
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: true, interval: 20.0)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          final index = value.toInt();
                          if (index >= 0 && index < subjectNames.length) {
                            return SideTitleWidget(
                              axisSide: meta.axisSide,
                              space: 8.0,
                              child: Text(subjectNames[index],
                                  overflow: TextOverflow.ellipsis),
                            );
                          }
                          return const Text('');
                        },
                        reservedSize: 40,
                      ),
                    ),
                    topTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    rightTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  gridData: const FlGridData(show: false),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFilterWidgets(
      List<Student> students, List<SchoolClass> classes, List<Subject> subjects) {
    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<int>(
            decoration: const InputDecoration(labelText: 'الطالب'),
            initialValue: _selectedStudentId,
            items: students.map((s) {
              return DropdownMenuItem(value: s.id, child: Text(s.name));
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedStudentId = value;
                _updateAverageGrades(); // Call to update chart data
              });
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: DropdownButtonFormField<int>(
            decoration: const InputDecoration(labelText: 'الفصل'),
            initialValue: _selectedClassId,
            items: classes.map((c) {
              return DropdownMenuItem(value: c.id, child: Text(c.name));
            }).toList(),
            onChanged: (value) => setState(() => _selectedClassId = value),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: DropdownButtonFormField<int>(
            decoration: const InputDecoration(labelText: 'المادة'),
            initialValue: _selectedSubjectId,
            items: subjects.map((s) {
              return DropdownMenuItem(value: s.id, child: Text(s.name));
            }).toList(),
            onChanged: (value) => setState(() => _selectedSubjectId = value),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.clear),
          tooltip: 'مسح الفلاتر',
          onPressed: () => setState(() {
            _selectedStudentId = null;
            _selectedClassId = null;
            _selectedSubjectId = null;
            _averageGradesFuture = Future.value({}); // Clear chart
          }),
        ),
      ],
    );
  }

  Widget _buildGradesList(
      List<Grade> grades,
      Map<int, Student> studentMap,
      Map<int, SchoolClass> classMap,
      Map<int, Subject> subjectMap,
      bool canEditOrDelete) { // Pass the permission flag
    if (grades.isEmpty) {
      return const Center(child: Text('لا توجد درجات مطابقة للفلتر.'));
    }
    return ListView.builder(
      itemCount: grades.length,
      itemBuilder: (context, index) {
        final grade = grades[index];
        return _buildGradeCard(grade, studentMap, classMap, subjectMap, canEditOrDelete);
      },
    );
  }

  Card _buildGradeCard(
      Grade grade,
      Map<int, Student> studentMap,
      Map<int, SchoolClass> classMap,
      Map<int, Subject> subjectMap,
      bool canEditOrDelete) { // Pass the permission flag
    final studentName = studentMap[grade.studentId]?.name ?? 'غير معروف';
    final className = classMap[grade.classId]?.name ?? 'غير معروف';
    final subjectName = subjectMap[grade.subjectId]?.name ?? 'غير معروف';

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(studentName,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
                Text('${grade.gradeValue.toStringAsFixed(2)} / 100',
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue)),
              ],
            ),
            const Divider(),
            _buildDetailRow('الفصل:', className),
            _buildDetailRow('المادة:', subjectName),
            _buildDetailRow('نوع التقييم:', grade.assessmentType),
            _buildDetailRow('الوزن النسبي:', grade.weight.toStringAsFixed(2)),
            const SizedBox(height: 8),
            // 3. Conditionally render the action buttons
            if (canEditOrDelete)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    tooltip: 'تعديل',
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AddEditGradeDialog(grade: grade),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    tooltip: 'حذف',
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('تأكيد الحذف'),
                          content: const Text(
                              'هل أنت متأكد من رغبتك في حذف هذه الدرجة؟'),
                          actions: [
                            TextButton(
                              child: const Text('إلغاء'),
                              onPressed: () => Navigator.of(ctx).pop(),
                            ),
                            TextButton(
                              child: const Text('حذف'),
                              onPressed: () {
                                context
                                    .read<GradeProvider>()
                                    .deleteGrade(grade.id!);
                                Navigator.of(ctx).pop();
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildGradesDataTable(
      List<Grade> grades,
      Map<int, Student> studentMap,
      Map<int, SchoolClass> classMap,
      Map<int, Subject> subjectMap,
      bool canEditOrDelete) { // Pass the permission flag
    if (grades.isEmpty) {
      return const Center(child: Text('لا توجد درجات مطابقة للفلتر.'));
    }
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('الطالب')),
            DataColumn(label: Text('الفصل')),
            DataColumn(label: Text('المادة')),
            DataColumn(label: Text('نوع التقييم')),
            DataColumn(label: Text('الدرجة')),
            DataColumn(label: Text('الوزن النسبي')),
            DataColumn(label: Text('الإجراءات')),
          ],
          rows: grades.map((grade) {
            final studentName = studentMap[grade.studentId]?.name ?? 'غير معروف';
            final className = classMap[grade.classId]?.name ?? 'غير معروف';
            final subjectName = subjectMap[grade.subjectId]?.name ?? 'غير معروف';

            return DataRow(
              cells: [
                DataCell(Text(studentName)),
                DataCell(Text(className)),
                DataCell(Text(subjectName)),
                DataCell(Text(grade.assessmentType)),
                DataCell(Text(grade.gradeValue.toStringAsFixed(2))),
                DataCell(Text(grade.weight.toStringAsFixed(2))),
                DataCell(
                  // 4. Conditionally render the action buttons in the DataTable
                  canEditOrDelete
                      ? Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              tooltip: 'تعديل',
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (ctx) => AddEditGradeDialog(grade: grade),
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              tooltip: 'حذف',
                              onPressed: () {
                                // Confirmation dialog before deleting
                                showDialog(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: const Text('تأكيد الحذف'),
                                    content: const Text(
                                        'هل أنت متأكد من رغبتك في حذف هذه الدرجة؟'),
                                    actions: [
                                      TextButton(
                                        child: const Text('إلغاء'),
                                        onPressed: () => Navigator.of(ctx).pop(),
                                      ),
                                      TextButton(
                                        child: const Text('حذف'),
                                        onPressed: () {
                                          context
                                              .read<GradeProvider>()
                                              .deleteGrade(grade.id!);
                                          Navigator.of(ctx).pop();
                                        },
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],
                        )
                      : const SizedBox.shrink(), // If no permission, show an empty widget
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}

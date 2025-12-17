import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/student_provider.dart';
import '../../providers/teacher_provider.dart';
import '../../providers/class_provider.dart';
import '../../providers/subject_provider.dart';
import '../../providers/grade_provider.dart';
import '../../class_model.dart';

class ReportsTab extends StatefulWidget {
  const ReportsTab({super.key});

  @override
  State<ReportsTab> createState() => _ReportsTabState();
}

class _ReportsTabState extends State<ReportsTab> {
  SchoolClass? _selectedClass;
  Future<List<Map<String, dynamic>>>? _averageGradesFuture;

  void _fetchAverageGrades(int classId) {
    setState(() {
      _averageGradesFuture = Provider.of<GradeProvider>(context, listen: false)
          .getAverageGradesForClass(classId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final classProvider = Provider.of<ClassProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('التقارير والإحصائيات')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // New Class Performance Report Card
            Card(
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.analytics, size: 30, color: Theme.of(context).primaryColor),
                        const SizedBox(width: 10),
                        Text('تقرير أداء الفصل', style: Theme.of(context).textTheme.headlineSmall),
                      ],
                    ),
                    const Divider(height: 20),
                    DropdownButtonFormField<SchoolClass>(
                      initialValue: _selectedClass,
                      hint: const Text('اختر فصلاً لعرض التقرير'),
                      isExpanded: true,
                      items: classProvider.classes.map((c) {
                        return DropdownMenuItem(value: c, child: Text(c.name));
                      }).toList(),
                      onChanged: (newValue) {
                        if (newValue != null) {
                          setState(() {
                            _selectedClass = newValue;
                          });
                          _fetchAverageGrades(newValue.id!);
                        }
                      },
                    ),
                    const SizedBox(height: 20),
                    if (_averageGradesFuture != null)
                      FutureBuilder<List<Map<String, dynamic>>>(
                        future: _averageGradesFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            return Center(child: Text('خطأ: ${snapshot.error}'));
                          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return const Center(child: Text('لا توجد بيانات درجات لهذا الفصل.'));
                          }

                          final data = snapshot.data!;
                          return SizedBox(
                            height: 250,
                            child: BarChart(
                              BarChartData(
                                alignment: BarChartAlignment.spaceAround,
                                maxY: 100, // Assuming grades are out of 100
                                titlesData: FlTitlesData(
                                  show: true,
                                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      getTitlesWidget: (double value, TitleMeta meta) {
                                        final index = value.toInt();
                                        if (index >= 0 && index < data.length) {
                                          return SideTitleWidget(
                                            axisSide: meta.axisSide,
                                            space: 8.0,
                                            child: Text(
                                              data[index]['subjectName'],
                                              style: const TextStyle(fontSize: 10),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          );
                                        }
                                        return const Text('');
                                      },
                                      reservedSize: 40,
                                    ),
                                  ),
                                ),
                                barGroups: data.asMap().entries.map((entry) {
                                  final index = entry.key;
                                  final subjectData = entry.value;
                                  final avgGrade = (subjectData['averageGrade'] as num?)?.toDouble() ?? 0.0;
                                  return BarChartGroupData(
                                    x: index,
                                    barRods: [
                                      BarChartRodData(
                                        toY: avgGrade,
                                        color: Colors.teal,
                                        width: 16,
                                      ),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            Text("ملخصات عامة", style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 10),

            // Existing Summary Cards
            _buildSummaryInfo(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryInfo(BuildContext context) {
    // This is to avoid calling providers directly in the build method of the main widget
    final studentCount = Provider.of<StudentProvider>(context).students.length;
    final teacherCount = Provider.of<TeacherProvider>(context).teachers.length;
    final classCount = Provider.of<ClassProvider>(context).classes.length;
    final subjectCount = Provider.of<SubjectProvider>(context).subjects.length;

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      children: [
        _buildReportCard(
          context: context,
          title: 'الطلاب',
          icon: Icons.school,
          value: studentCount.toString(),
        ),
        _buildReportCard(
          context: context,
          title: 'المعلمين',
          icon: Icons.person,
          value: teacherCount.toString(),
        ),
        _buildReportCard(
          context: context,
          title: 'الفصول',
          icon: Icons.class_,
          value: classCount.toString(),
        ),
        _buildReportCard(
          context: context,
          title: 'المواد',
          icon: Icons.book,
          value: subjectCount.toString(),
        ),
      ],
    );
  }

  Widget _buildReportCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required String value,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 30, color: Theme.of(context).primaryColor),
            const SizedBox(height: 10),
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            Text(value, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

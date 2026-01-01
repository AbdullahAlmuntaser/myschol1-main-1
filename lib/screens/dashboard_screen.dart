import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';

import '../providers/theme_provider.dart';
import '../services/local_auth_service.dart';
import '../student_model.dart'; // Re-adding student model import
import '../grade_model.dart'; // Re-adding grade model import
// Imports for specific feature screens are now managed via app_constants.dart

import '../providers/permission_provider.dart';

import '../providers/student_provider.dart';
import '../providers/teacher_provider.dart';
import '../providers/class_provider.dart';
import '../providers/grade_provider.dart';
import '../providers/attendance_provider.dart';
import '../providers/timetable_provider.dart';

import '../utils/app_constants.dart'; // Import new constants file

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  DashboardScreenState createState() => DashboardScreenState();
}

class DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final authService = Provider.of<LocalAuthService>(context);
    final currentUser = authService.currentUser;
    final String? userRole = currentUser?.role;
    final bool isDesktop = MediaQuery.of(context).size.width >= 600;

    return Consumer<PermissionProvider>(
      builder: (context, permissionProvider, child) {
        final List<Widget> widgetOptions = [];
        final List<NavigationRailDestination> navigationRailDestinations = [];
        final List<BottomNavigationBarItem> bottomNavigationBarItems = [];

        // Manually handle DashboardSummary as its widget is dynamic
        if (permissionProvider.hasPermission(AppFeatures.dashboard)) {
          final data = allFeatureData[AppFeatures.dashboard]!;
          widgetOptions.add(DashboardSummary(userRole: userRole));
          navigationRailDestinations.add(_buildRailDestination(data));
          bottomNavigationBarItems.add(_buildBottomNavigationItem(data));
        }

        allFeatureData.forEach((feature, data) {
          if (feature != AppFeatures.dashboard && permissionProvider.hasPermission(feature)) {
            widgetOptions.add(data['widget'] as Widget);
            navigationRailDestinations.add(_buildRailDestination(data));
            bottomNavigationBarItems.add(_buildBottomNavigationItem(data));
          }
        });

        if (widgetOptions.isEmpty) {
          return Scaffold(
            appBar: AppBar(title: const Text('Dashboard')),
            body: const Center(
              child: Text('You do not have permission to view any features.'),
            ),
          );
        }

        if (_selectedIndex >= widgetOptions.length) {
          _selectedIndex = 0;
        }

        return Scaffold(
          appBar: AppBar(
            title: Text('مرحباً، ${currentUser?.username ?? 'زائر'}'),
            actions: [
              Consumer<ThemeProvider>(
                builder: (context, themeProvider, child) {
                  return IconButton(
                    icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
                    onPressed: () {
                      themeProvider.toggleTheme(!isDarkMode);
                    },
                    tooltip: 'تبديل السمة',
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () {
                  authService.signOut();
                },
                tooltip: 'تسجيل الخروج',
              ),
            ],
          ),
          body: Row(
            children: [
              if (isDesktop)
                NavigationRail(
                  selectedIndex: _selectedIndex,
                  onDestinationSelected: (int index) {
                    setState(() {
                      _selectedIndex = index;
                    });
                  },
                  labelType: NavigationRailLabelType.all,
                  destinations: navigationRailDestinations,
                ),
              Expanded(child: widgetOptions.elementAt(_selectedIndex)),
            ],
          ),
          bottomNavigationBar: isDesktop
              ? null
              : BottomNavigationBar(
                  items: bottomNavigationBarItems,
                  currentIndex: _selectedIndex,
                  onTap: (int index) {
                    setState(() {
                      _selectedIndex = index;
                    });
                  },
                  selectedItemColor: Theme.of(context).primaryColor,
                  unselectedItemColor: Colors.grey,
                  type: BottomNavigationBarType.fixed,
                ),
        );
      },
    );
  }

  NavigationRailDestination _buildRailDestination(Map<String, dynamic> data) {
    return NavigationRailDestination(
      icon: Icon(data['icon'] as IconData),
      selectedIcon: Icon(data['icon'] as IconData),
      label: Text(data['label'] as String),
    );
  }

  BottomNavigationBarItem _buildBottomNavigationItem(Map<String, dynamic> data) {
    return BottomNavigationBarItem(
      icon: Icon(data['icon'] as IconData),
      label: data['label'] as String,
    );
  }
}
 
class DashboardSummary extends StatelessWidget {
  final String? userRole;
  const DashboardSummary({super.key, this.userRole});

  @override
  Widget build(BuildContext context) {
    String titleText;
    switch (userRole) {
      case 'admin':
        titleText = 'ملخص لوحة تحكم المسؤول';
        break;
      case 'teacher':
        titleText = 'ملخص لوحة تحكم المعلم';
        break;
      case 'student':
        titleText = 'ملخص لوحة تحكم الطالب';
        break;
      case 'parent':
        titleText = 'ملخص لوحة تحكم ولي الأمر';
        break;
      default:
        titleText = 'ملخص لوحة التحكم';
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titleText, style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 20),
          // Conditional content based on role
          if (userRole == 'admin') ...[
            Consumer4<
              StudentProvider,
              TeacherProvider,
              ClassProvider,
              GradeProvider
            >(
              builder:
                  (
                    context,
                    studentProvider,
                    teacherProvider,
                    classProvider,
                    gradeProvider,
                    child,
                  ) {
                    final totalStudents = studentProvider.students.length;
                    final totalTeachers = teacherProvider.teachers.length;
                    final totalClasses = classProvider.classes.length;

                    // Calculate average success rate (dummy data for now, actual calculation needs grades data logic)
                    double successRate = 0;
                    if (totalStudents > 0) {
                      // This is a placeholder for actual success rate calculation.
                      // Real implementation would involve iterating through grades and determining pass/fail.
                      successRate = 85.0; // Placeholder
                    }

                    return GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      children: [
                        SummaryCard(
                          title: 'إجمالي الطلاب',
                          value: totalStudents.toString(),
                          icon: Icons.school,
                          color: Colors.blue,
                        ),
                        SummaryCard(
                          title: 'إجمالي المعلمين',
                          value: totalTeachers.toString(),
                          icon: Icons.person,
                          color: Colors.green,
                        ),
                        SummaryCard(
                          title: 'إجمالي الفصول',
                          value: totalClasses.toString(),
                          icon: Icons.class_,
                          color: Colors.orange,
                        ),
                        SummaryCard(
                          title: 'نسبة النجاح',
                          value: '${successRate.toStringAsFixed(0)}%',
                          icon: Icons.trending_up,
                          color: Colors.purple,
                        ),
                      ],
                    );
                  },
            ),
            const SizedBox(height: 30),
            Text(
              'نظرة عامة على حضور الطلاب',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  barGroups: [
                    BarChartGroupData(
                      x: 0,
                      barRods: [
                        BarChartRodData(toY: 8, color: Colors.lightBlue),
                      ],
                    ),
                    BarChartGroupData(
                      x: 1,
                      barRods: [
                        BarChartRodData(toY: 10, color: Colors.lightBlue),
                      ],
                    ),
                    BarChartGroupData(
                      x: 2,
                      barRods: [
                        BarChartRodData(toY: 14, color: Colors.lightBlue),
                      ],
                    ),
                    BarChartGroupData(
                      x: 3,
                      barRods: [
                        BarChartRodData(toY: 15, color: Colors.lightBlue),
                      ],
                    ),
                    BarChartGroupData(
                      x: 4,
                      barRods: [
                        BarChartRodData(toY: 13, color: Colors.lightBlue),
                      ],
                    ),
                    BarChartGroupData(
                      x: 5,
                      barRods: [
                        BarChartRodData(toY: 10, color: Colors.lightBlue),
                      ],
                    ),
                    BarChartGroupData(
                      x: 6,
                      barRods: [
                        BarChartRodData(toY: 11, color: Colors.lightBlue),
                      ],
                    ),
                  ],
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) =>
                            Text('اليوم ${value.toInt() + 1}'),
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: true),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  gridData: FlGridData(show: false),
                ),
              ),
            ),
          ] else if (userRole == 'teacher') ...[
            // Teacher-specific content
            Consumer4<
              TeacherProvider,
              ClassProvider,
              AttendanceProvider,
              TimetableProvider
            >(
              builder:
                  (
                    context,
                    teacherProvider,
                    classProvider,
                    attendanceProvider,
                    timetableProvider,
                    child,
                  ) {
                    final currentUser = Provider.of<LocalAuthService>(
                      context,
                    ).currentUser;
                    final currentTeacherId = currentUser?.id;
                    final teachersClasses = classProvider.classes
                        .where((c) => c.teacherId == currentTeacherId)
                        .length;
                    final classesIds = classProvider.classes
                        .where((c) => c.teacherId == currentTeacherId)
                        .map((e) => e.classId)
                        .toList();

                    // Placeholder for upcoming classes/appointments
                    final upcomingTimetableEntries = timetableProvider
                        .timetableEntries
                        .where((entry) => classesIds.contains(entry.classId.toString()))
                        .length;

                    // Count attendances with 'absent' or 'late' status as pending for review
                    final pendingAttendances = attendanceProvider.attendances
                        .where(
                          (att) =>
                              classesIds.contains(att.classId.toString()) &&
                              (att.status == 'absent' || att.status == 'late'),
                        )
                        .length;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'مرحباً أيها المعلم! إليك ملخص المهام المخصصة لك.',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        const SizedBox(height: 16),
                        GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          children: [
                            SummaryCard(
                              title: 'فصولي',
                              value: teachersClasses.toString(),
                              icon: Icons.class_,
                              color: Colors.indigo,
                            ),
                            SummaryCard(
                              title: 'جداول قادمة',
                              value: upcomingTimetableEntries.toString(),
                              icon: Icons.calendar_today,
                              color: Colors.purple,
                            ),
                            SummaryCard(
                              title: 'حضور يحتاج مراجعة',
                              value: pendingAttendances.toString(),
                              icon: Icons.pending_actions,
                              color: Colors.red,
                            ),
                          ],
                        ),
                      ],
                    );
                  },
            ),
          ] else if (userRole == 'student') ...[
            // Student-specific content
            Consumer3<StudentProvider, GradeProvider, TimetableProvider>(
              builder:
                  (
                    context,
                    studentProvider,
                    gradeProvider,
                    timetableProvider,
                    child,
                  ) {
                    final currentUser = Provider.of<LocalAuthService>(
                      context,
                    ).currentUser;
                    final currentUserId = currentUser?.id;

                    Student? foundStudent;
                    for (Student s in studentProvider.students) {
                      if (s.id != null && s.id == currentUserId) {
                        foundStudent = s;
                        break;
                      }
                    }

                    final currentStudent =
                        foundStudent ??
                        Student(
                          id: -1,
                          name: 'غير معروف',
                          dob: '',
                          phone: '',
                          grade: '',
                          academicNumber: 'N/A',
                          classId: 'N/A',
                        );

                    // If student is not found or invalid, show a message or empty state
                    if (currentStudent.id == -1) {
                      return const Center(
                        child: Text('Student data not found.'),
                      );
                    }

                    // Now, use FutureBuilder for the async parts
                    return FutureBuilder<List<Grade>>(
                      future: gradeProvider.getGradesByStudent(
                        currentStudent.id!,
                      ),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        } else if (snapshot.hasError) {
                          return Center(
                            child: Text('Error: ${snapshot.error}'),
                          );
                        } else if (snapshot.hasData) {
                          final grades = snapshot.data!;
                          double averageGrade = 0;
                          if (grades.isNotEmpty) {
                            double totalWeightedGrade = 0.0;
                            double totalWeight = 0.0;
                            for (Grade grade in grades) {
                              totalWeightedGrade +=
                                  grade.gradeValue * grade.weight;
                              totalWeight += grade.weight;
                            }
                            if (totalWeight > 0) {
                              averageGrade = totalWeightedGrade / totalWeight;
                            }
                          }

                          int upcomingTimetableEntries = timetableProvider
                              .timetableEntries
                              .where(
                                (entry) =>
                                    entry.classId ==
                                    int.tryParse(currentStudent.classId ?? ''),
                              )
                              .length;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'مرحباً أيها الطالب! إليك ملخص لدرجاتك وجدولك الدراسي.',
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              const SizedBox(height: 16),
                              GridView.count(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                crossAxisCount: 2,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                                children: [
                                  SummaryCard(
                                    title: 'المعدل العام',
                                    value: averageGrade.toStringAsFixed(1),
                                    icon: Icons.grade,
                                    color: Colors.teal,
                                  ),
                                  SummaryCard(
                                    title: 'حصص قادمة',
                                    value: upcomingTimetableEntries.toString(),
                                    icon: Icons.calendar_today,
                                    color: Colors.blueAccent,
                                  ),
                                  // Add more student-specific cards
                                ],
                              ),
                            ],
                          );
                        } else {
                          return const Center(
                            child: Text('No grades data available.'),
                          );
                        }
                      },
                    );
                  },
            ),
          ] else if (userRole == 'parent') ...[
            // Parent-specific content
            Consumer<StudentProvider>(
              builder: (context, studentProvider, child) {
                // Assuming a parent can see multiple children associated with their user ID
                final currentUser = Provider.of<LocalAuthService>(
                  context,
                ).currentUser;
                final currentParentUserId = currentUser?.id;
                // For now, let's assume students have a parentUserId property or similar
                // This needs actual implementation in student_model and database_helper
                final children = studentProvider.students
                    .where((s) => s.parentUserId == currentParentUserId)
                    .toList(); // Assuming student model has parentUserId

                final childrenCount = children.length;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'مرحباً ولي الأمر! إليك ملخص أداء أبنائك في المدرسة.',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 16),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      children: [
                        SummaryCard(
                          title: 'عدد الأبناء',
                          value: childrenCount.toString(),
                          icon: Icons.family_restroom,
                          color: Colors.brown,
                        ),
                        // Add more parent-specific cards, e.g., quick overview of children's grades
                      ],
                    ),
                  ],
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}

class SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const SummaryCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                Icon(icon, color: color, size: 30),
              ],
            ),
            Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

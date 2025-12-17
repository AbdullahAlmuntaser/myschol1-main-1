import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/local_auth_service.dart';
import '../student_model.dart';
import 'student_detail_for_parent_screen.dart';
import 'chat_screen.dart';
import '../providers/student_provider.dart';
import '../providers/grade_provider.dart';
import '../providers/attendance_provider.dart';
import '../grade_model.dart';

class ParentPortalScreen extends StatefulWidget {
  const ParentPortalScreen({super.key});

  @override
  State<ParentPortalScreen> createState() => _ParentPortalScreenState();
}

class _ParentPortalScreenState extends State<ParentPortalScreen> {
  List<Map<String, dynamic>> _childrenData = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchChildrenData();
  }

  Future<void> _fetchChildrenData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _childrenData.clear();
    });

    try {
      final authService = Provider.of<LocalAuthService>(context, listen: false);
      final studentProvider = Provider.of<StudentProvider>(context, listen: false);
      final gradeProvider = Provider.of<GradeProvider>(context, listen: false);
      final attendanceProvider = Provider.of<AttendanceProvider>(context, listen: false);
      final currentUser = authService.currentUser;

      if (currentUser != null && currentUser.role == 'parent' && currentUser.id != null) {
        await studentProvider.fetchStudentsByParent(currentUser.id!);
        final students = studentProvider.students;

        List<Map<String, dynamic>> tempChildrenData = [];
        for (Student student in students) {
          // Calculate average grade
          final grades = await gradeProvider.getGradesByStudent(student.id!);
          double averageGrade = 0.0;
          if (grades.isNotEmpty) {
            double totalWeightedGrade = 0.0;
            double totalWeight = 0.0;
            for (Grade grade in grades) {
              totalWeightedGrade += grade.gradeValue * grade.weight;
              totalWeight += grade.weight;
            }
            if (totalWeight > 0) {
              averageGrade = totalWeightedGrade / totalWeight;
            }
          }

          // Fetch and calculate attendance stats
          final attendances = await attendanceProvider.getAttendancesByStudent(student.id!);
          final absentCount = attendances.where((a) => a.status == 'absent').length;

          tempChildrenData.add({
            'student': student,
            'averageGrade': averageGrade,
            'absentCount': absentCount,
          });
        }

        if (mounted) {
          setState(() {
            _childrenData = tempChildrenData;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _errorMessage = 'You do not have permission to view this page or are not logged in as a parent.';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'An error occurred while fetching your children\'s data: $e';
        });
      }
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Parent Portal'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchChildrenData,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : _childrenData.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.sentiment_dissatisfied,
                    size: 80,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 20),
                  Text(
                    'No children associated with this account.',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Please contact the school administration to link your children to your account.',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: _childrenData.length,
              itemBuilder: (context, index) {
                final studentData = _childrenData[index];
                final student = studentData['student'] as Student;
                final averageGrade = studentData['averageGrade'] as double;
                final absentCount = studentData['absentCount'] as int;

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  elevation: 3,
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              StudentDetailForParentScreen(student: student),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            student.name,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Grade: ${student.grade} - Academic Number: ${student.academicNumber ?? 'N/A'}',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Average Grade: ${averageGrade.toStringAsFixed(2)}',
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: averageGrade >= 50
                                          ? Colors.green.shade700
                                          : Colors.red.shade700,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              Text(
                                'Absences: $absentCount',
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: absentCount > 0
                                          ? Colors.orange.shade800
                                          : Colors.grey.shade600,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ChatScreen()),
          );
        },
        tooltip: 'Chat with School',
        child: const Icon(Icons.chat),
      ),
    );
  }
}

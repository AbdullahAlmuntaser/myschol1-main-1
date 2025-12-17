import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/grade_provider.dart';
import '../providers/student_provider.dart';
import '../providers/subject_provider.dart';
import '../providers/class_provider.dart';
import 'tabs/grades_overview_tab.dart';
import 'tabs/grades_bulk_entry_tab.dart';

class GradesScreen extends StatefulWidget {
  static const routeName = '/grades';

  const GradesScreen({super.key});

  @override
  State<GradesScreen> createState() => _GradesScreenState();
}

class _GradesScreenState extends State<GradesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Fetch initial data for providers
    Provider.of<GradeProvider>(context, listen: false).fetchGrades();
    Provider.of<StudentProvider>(context, listen: false).fetchStudents();
    Provider.of<SubjectProvider>(context, listen: false).fetchSubjects();
    Provider.of<ClassProvider>(context, listen: false).fetchClasses();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة الدرجات'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'نظرة عامة'),
            Tab(text: 'إدخال جماعي'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [GradesOverviewTab(), GradesBulkEntryTab()],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'tabs/student_results_tab.dart';
import 'tabs/student_promotion_tab.dart';
import 'tabs/print_results_tab.dart';

class StudentAffairsScreen extends StatefulWidget {
  const StudentAffairsScreen({super.key});

  @override
  StudentAffairsScreenState createState() => StudentAffairsScreenState();
}

class StudentAffairsScreenState extends State<StudentAffairsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
        title: const Text('شؤون الطلاب'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'نتائج الطلاب', icon: Icon(Icons.assessment)),
            Tab(text: 'ترحيل الطلاب', icon: Icon(Icons.trending_up)),
            Tab(text: 'طباعة النتائج', icon: Icon(Icons.print)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          StudentResultsTab(),
          StudentPromotionTab(),
          PrintResultsTab(),
        ],
      ),
    );
  }
}

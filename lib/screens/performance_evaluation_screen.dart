import 'package:flutter/material.dart';
import '../performance_evaluation_model.dart';
import 'add_edit_performance_evaluation_screen.dart';

class PerformanceEvaluationScreen extends StatefulWidget {
  final int staffId;

  const PerformanceEvaluationScreen({super.key, required this.staffId});

  @override
  PerformanceEvaluationScreenState createState() => PerformanceEvaluationScreenState();
}

class PerformanceEvaluationScreenState extends State<PerformanceEvaluationScreen> {
  final bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // TODO: Implement fetching evaluations when PerformanceEvaluationProvider is ready
  }

  void _navigateToAddEditScreen([PerformanceEvaluation? evaluation]) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddEditPerformanceEvaluationScreen(
          staffId: widget.staffId,
          evaluation: evaluation,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تقييمات الأداء'),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : const Center(
              child: Text('لا توجد تقييمات أداء حالياً.'),
            ), // Placeholder for evaluation list
      floatingActionButton: FloatingActionButton(
        onPressed: _isLoading ? null : () => _navigateToAddEditScreen(),
        tooltip: 'إضافة تقييم جديد',
        child: const Icon(Icons.add),
      ),
    );
  }
}

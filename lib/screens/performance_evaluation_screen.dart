import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../performance_evaluation_model.dart';
import '../providers/performance_evaluation_provider.dart';
import 'add_edit_performance_evaluation_screen.dart';

class PerformanceEvaluationScreen extends StatefulWidget {
  final int staffId;

  const PerformanceEvaluationScreen({super.key, required this.staffId});

  @override
  PerformanceEvaluationScreenState createState() =>
      PerformanceEvaluationScreenState();
}

class PerformanceEvaluationScreenState
    extends State<PerformanceEvaluationScreen> {
  late Future<void> _fetchEvaluationsFuture;

  @override
  void initState() {
    super.initState();
    _fetchEvaluationsFuture = _fetchEvaluations();
  }

  Future<void> _fetchEvaluations() async {
    final provider =
        Provider.of<PerformanceEvaluationProvider>(context, listen: false);
    await provider.getPerformanceEvaluationsByStaffId(widget.staffId);
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
      body: FutureBuilder(
        future: _fetchEvaluationsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          return Consumer<PerformanceEvaluationProvider>(
            builder: (context, provider, child) {
              if (provider.evaluations.isEmpty) {
                return const Center(
                    child: Text('لا توجد تقييمات أداء حالياً.'));
              }
              return ListView.builder(
                itemCount: provider.evaluations.length,
                itemBuilder: (context, index) {
                  final evaluation = provider.evaluations[index];
                  return ListTile(
                    title: Text('تقييم ${evaluation.evaluationDate}'),
                    subtitle: Text('التقييم: ${evaluation.overallRating}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () =>
                              _navigateToAddEditScreen(evaluation),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () async {
                            await showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('تأكيد الحذف'),
                                content: const Text(
                                    'هل أنت متأكد أنك تريد حذف هذا التقييم؟'),
                                actions: <Widget>[
                                  TextButton(
                                    child: const Text('إلغاء'),
                                    onPressed: () {
                                      Navigator.of(ctx).pop();
                                    },
                                  ),
                                  TextButton(
                                    child: const Text('حذف'),
                                    onPressed: () async {
                                      await provider.deletePerformanceEvaluation(
                                          evaluation.id!);
                                      if (!mounted) return;
                                      // ignore: use_build_context_synchronously
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
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddEditScreen(),
        tooltip: 'إضافة تقييم جديد',
        child: const Icon(Icons.add),
      ),
    );
  }
}

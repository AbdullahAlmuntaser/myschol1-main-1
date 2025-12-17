import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../performance_evaluation_model.dart';
import '../services/local_auth_service.dart'; // For current user ID
import '../custom_exception.dart'; // Add this import
import '../providers/performance_evaluation_provider.dart'; // Added PerformanceEvaluationProvider import

class AddEditPerformanceEvaluationScreen extends StatefulWidget {
  final int staffId;
  final PerformanceEvaluation? evaluation;

  const AddEditPerformanceEvaluationScreen({
    super.key,
    required this.staffId,
    this.evaluation,
  });

  @override
  AddEditPerformanceEvaluationScreenState createState() =>
      AddEditPerformanceEvaluationScreenState();
}

class AddEditPerformanceEvaluationScreenState
    extends State<AddEditPerformanceEvaluationScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _evaluationDateController;
  late TextEditingController _overallRatingController;
  late TextEditingController _commentsController;
  late TextEditingController _areasForImprovementController;
  late TextEditingController _developmentGoalsController;
  int? _evaluatorUserId;

  @override
  void initState() {
    super.initState();
    _evaluationDateController = TextEditingController(
      text: widget.evaluation?.evaluationDate ?? '',
    );
    _overallRatingController = TextEditingController(
      text: widget.evaluation?.overallRating ?? '',
    );
    _commentsController = TextEditingController(
      text: widget.evaluation?.comments ?? '',
    );
    _areasForImprovementController = TextEditingController(
      text: widget.evaluation?.areasForImprovement ?? '',
    );
    _developmentGoalsController = TextEditingController(
      text: widget.evaluation?.developmentGoals ?? '',
    );

    _evaluatorUserId = Provider.of<LocalAuthService>(context, listen: false).currentUser?.id; // Get current user ID for evaluator
  }

  @override
  void dispose() {
    _evaluationDateController.dispose();
    _overallRatingController.dispose();
    _commentsController.dispose();
    _areasForImprovementController.dispose();
    _developmentGoalsController.dispose();
    super.dispose();
  }

  Future<void> _saveEvaluation() async {
    if (_formKey.currentState!.validate()) {
      if (_evaluatorUserId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('خطأ: معرف المقيم غير متاح.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final evaluation = PerformanceEvaluation(
        id: widget.evaluation?.id,
        staffId: widget.staffId,
        evaluationDate: _evaluationDateController.text,
        evaluatorUserId: _evaluatorUserId!,
        overallRating: _overallRatingController.text,
        comments: _commentsController.text,
        areasForImprovement: _areasForImprovementController.text.isNotEmpty
            ? _areasForImprovementController.text
            : null,
        developmentGoals: _developmentGoalsController.text.isNotEmpty
            ? _developmentGoalsController.text
            : null,
      );

      final provider = Provider.of<PerformanceEvaluationProvider>(context, listen: false);
      final message = widget.evaluation == null
          ? 'تمت إضافة التقييم بنجاح'
          : 'تم تحديث التقييم بنجاح';

      try {
        if (widget.evaluation == null) {
          await provider.addPerformanceEvaluation(evaluation);
        } else {
          await provider.updatePerformanceEvaluation(evaluation);
        }
        if (!mounted) return;
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.green),
        );
      } on CustomException catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message), backgroundColor: Colors.red),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل حفظ التقييم: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Helper to pick date
  Future<void> _pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.tryParse(_evaluationDateController.text) ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _evaluationDateController.text = picked.toIso8601String().split('T').first; // Format YYYY-MM-DD
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.evaluation == null ? 'إضافة تقييم أداء' : 'تعديل تقييم أداء'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _evaluationDateController,
                  decoration: InputDecoration(
                    labelText: 'تاريخ التقييم',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: _pickDate,
                    ),
                  ),
                  readOnly: true,
                  validator: (value) =>
                      value!.isEmpty ? 'الرجاء اختيار تاريخ التقييم' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _overallRatingController,
                  decoration: const InputDecoration(
                    labelText: 'التقييم العام (مثل ممتاز، جيد، يحتاج تحسين)',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value!.isEmpty ? 'الرجاء إدخال التقييم العام' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _commentsController,
                  decoration: const InputDecoration(
                    labelText: 'التعليقات',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 4,
                  validator: (value) =>
                      value!.isEmpty ? 'الرجاء إدخال التعليقات' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _areasForImprovementController,
                  decoration: const InputDecoration(
                    labelText: 'مجالات التحسين (اختياري)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _developmentGoalsController,
                  decoration: const InputDecoration(
                    labelText: 'أهداف التطوير (اختياري)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _saveEvaluation,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  child: const Text('حفظ التقييم'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

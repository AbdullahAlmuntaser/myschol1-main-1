import 'package:flutter/material.dart';

import '../database_helper.dart';
import '../performance_evaluation_model.dart';

class PerformanceEvaluationProvider with ChangeNotifier {
  List<PerformanceEvaluation> _evaluations = [];
  final DatabaseHelper _dbHelper;

  PerformanceEvaluationProvider({DatabaseHelper? databaseHelper})
      : _dbHelper = databaseHelper ?? DatabaseHelper();

  List<PerformanceEvaluation> get evaluations => _evaluations;

  Future<void> fetchPerformanceEvaluations() async {
    _evaluations = await _dbHelper.getPerformanceEvaluations();
    notifyListeners();
  }

  Future<void> searchPerformanceEvaluations(String query) async {
    if (query.isEmpty) {
      await fetchPerformanceEvaluations();
    } else {
      _evaluations = await _dbHelper.searchPerformanceEvaluations(query);
      notifyListeners();
    }
  }

  Future<void> addPerformanceEvaluation(PerformanceEvaluation evaluation) async {
    await _dbHelper.createPerformanceEvaluation(evaluation);
    await fetchPerformanceEvaluations();
  }

  Future<void> updatePerformanceEvaluation(PerformanceEvaluation evaluation) async {
    await _dbHelper.updatePerformanceEvaluation(evaluation);
    await fetchPerformanceEvaluations();
  }

  Future<void> deletePerformanceEvaluation(int id) async {
    await _dbHelper.deletePerformanceEvaluation(id);
    await fetchPerformanceEvaluations();
  }

  Future<List<PerformanceEvaluation>> getPerformanceEvaluationsByStaffId(int staffId) async {
    return await _dbHelper.getPerformanceEvaluationsByStaffId(staffId);
  }

  void clearPerformanceEvaluations() {
    _evaluations = [];
    notifyListeners();
  }

  Future<PerformanceEvaluation?> getPerformanceEvaluationById(int id) async {
    return await _dbHelper.getPerformanceEvaluationById(id);
  }
}

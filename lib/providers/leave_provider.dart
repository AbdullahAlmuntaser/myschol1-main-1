import 'package:flutter/material.dart';

import '../database_helper.dart';
import '../leave_model.dart';

class LeaveProvider with ChangeNotifier {
  List<Leave> _leaves = [];
  final DatabaseHelper _dbHelper;

  LeaveProvider({DatabaseHelper? databaseHelper})
      : _dbHelper = databaseHelper ?? DatabaseHelper();

  List<Leave> get leaves => _leaves;

  Future<void> fetchLeaves() async {
    _leaves = await _dbHelper.getLeaves();
    notifyListeners();
  }

  Future<void> searchLeaves(String query) async {
    if (query.isEmpty) {
      await fetchLeaves();
    } else {
      _leaves = await _dbHelper.searchLeaves(query);
      notifyListeners();
    }
  }

  Future<void> addLeave(Leave leave) async {
    await _dbHelper.createLeave(leave);
    await fetchLeaves();
  }

  Future<void> updateLeave(Leave leave) async {
    await _dbHelper.updateLeave(leave);
    await fetchLeaves();
  }

  Future<void> deleteLeave(int id) async {
    await _dbHelper.deleteLeave(id);
    await fetchLeaves();
  }

  Future<List<Leave>> getLeavesByStaffId(int staffId) async {
    return await _dbHelper.getLeavesByStaffId(staffId);
  }

  void clearLeaves() {
    _leaves = [];
    notifyListeners();
  }

  Future<Leave?> getLeaveById(int id) async {
    return await _dbHelper.getLeaveById(id);
  }
}

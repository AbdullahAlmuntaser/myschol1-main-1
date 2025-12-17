import 'package:flutter/material.dart';

import '../database_helper.dart';
import '../staff_model.dart';

class StaffProvider with ChangeNotifier {
  List<Staff> _staff = [];
  final DatabaseHelper _dbHelper;

  StaffProvider({DatabaseHelper? databaseHelper})
      : _dbHelper = databaseHelper ?? DatabaseHelper();

  List<Staff> get staff => _staff;

  Future<void> fetchStaff() async {
    _staff = await _dbHelper.getStaff();
    notifyListeners();
  }

  Future<void> searchStaff(String query) async {
    if (query.isEmpty) {
      await fetchStaff();
    } else {
      _staff = await _dbHelper.searchStaff(query);
      notifyListeners();
    }
  }

  Future<void> addStaff(Staff staff) async {
    // Optional: Add validation for unique email/phone or other business logic
    await _dbHelper.createStaff(staff);
    await fetchStaff();
  }

  Future<void> updateStaff(Staff staff) async {
    // Optional: Add validation for unique email/phone or other business logic
    await _dbHelper.updateStaff(staff);
    await fetchStaff();
  }

  Future<void> deleteStaff(int id) async {
    await _dbHelper.deleteStaff(id);
    await fetchStaff();
  }

  void clearStaff() {
    _staff = [];
    notifyListeners();
  }

  Future<Staff?> getStaffById(int id) async {
    return await _dbHelper.getStaffById(id);
  }
}

import 'package:flutter/material.dart';
import '../leave_model.dart';
import 'add_edit_leave_screen.dart';

class LeaveManagementScreen extends StatefulWidget {
  const LeaveManagementScreen({super.key});

  @override
  LeaveManagementScreenState createState() => LeaveManagementScreenState();
}

class LeaveManagementScreenState extends State<LeaveManagementScreen> {
  final bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // TODO: Implement fetching leaves when LeaveProvider is ready
  }

  void _navigateToAddEditScreen([Leave? leave]) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddEditLeaveScreen(leave: leave),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة الإجازات'),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : const Center(
              child: Text('لا توجد طلبات إجازة حالياً.'),
            ), // Placeholder for leave list
      floatingActionButton: FloatingActionButton(
        onPressed: _isLoading ? null : () => _navigateToAddEditScreen(),
        tooltip: 'إضافة طلب إجازة جديد',
        child: const Icon(Icons.add),
      ),
    );
  }
}

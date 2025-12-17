import 'package:flutter/material.dart';
import '../staff_model.dart';
import 'add_edit_staff_screen.dart';

class StaffManagementScreen extends StatefulWidget {
  const StaffManagementScreen({super.key});

  @override
  StaffManagementScreenState createState() => StaffManagementScreenState();
}

class StaffManagementScreenState extends State<StaffManagementScreen> {
  final bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // TODO: Implement fetching staff when StaffProvider is ready
  }

  void _navigateToAddEditScreen([Staff? staff]) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddEditStaffScreen(staff: staff),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة الموظفين'),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : const Center(
              child: Text('لا توجد بيانات موظفين حالياً.'),
            ), // Placeholder for staff list
      floatingActionButton: FloatingActionButton(
        onPressed: _isLoading ? null : () => _navigateToAddEditScreen(),
        tooltip: 'إضافة موظف جديد',
        child: const Icon(Icons.add),
      ),
    );
  }
}

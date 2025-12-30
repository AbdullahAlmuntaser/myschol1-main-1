import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../staff_model.dart';
import '../providers/staff_provider.dart';
import 'add_edit_staff_screen.dart';

class StaffManagementScreen extends StatefulWidget {
  const StaffManagementScreen({super.key});

  @override
  StaffManagementScreenState createState() => StaffManagementScreenState();
}

class StaffManagementScreenState extends State<StaffManagementScreen> {
  late Future<void> _fetchStaffFuture;

  @override
  void initState() {
    super.initState();
    _fetchStaffFuture = _fetchStaff();
  }

  Future<void> _fetchStaff() async {
    final provider = Provider.of<StaffProvider>(context, listen: false);
    await provider.fetchStaff();
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
      body: FutureBuilder(
        future: _fetchStaffFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          return Consumer<StaffProvider>(
            builder: (context, provider, child) {
              if (provider.staff.isEmpty) {
                return const Center(
                    child: Text('لا توجد بيانات موظفين حالياً.'));
              }
              return ListView.builder(
                itemCount: provider.staff.length,
                itemBuilder: (context, index) {
                  final staffMember = provider.staff[index];
                  return ListTile(
                    title: Text(staffMember.name),
                    subtitle: Text(
                        '${staffMember.position} - ${staffMember.department}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () =>
                              _navigateToAddEditScreen(staffMember),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () async {
                            await showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('تأكيد الحذف'),
                                content: const Text(
                                    'هل أنت متأكد أنك تريد حذف هذا الموظف؟'),
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
                                      await provider
                                          .deleteStaff(staffMember.id!);
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
        tooltip: 'إضافة موظف جديد',
        child: const Icon(Icons.add),
      ),
    );
  }
}

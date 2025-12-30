import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../leave_model.dart';
import '../providers/leave_provider.dart';
import 'add_edit_leave_screen.dart';

class LeaveManagementScreen extends StatefulWidget {
  const LeaveManagementScreen({super.key});

  @override
  LeaveManagementScreenState createState() => LeaveManagementScreenState();
}

class LeaveManagementScreenState extends State<LeaveManagementScreen> {
  late Future<void> _fetchLeavesFuture;

  @override
  void initState() {
    super.initState();
    _fetchLeavesFuture = _fetchLeaves();
  }

  Future<void> _fetchLeaves() async {
    final provider = Provider.of<LeaveProvider>(context, listen: false);
    await provider.fetchLeaves();
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
      body: FutureBuilder(
        future: _fetchLeavesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          return Consumer<LeaveProvider>(
            builder: (context, provider, child) {
              if (provider.leaves.isEmpty) {
                return const Center(
                    child: Text('لا توجد طلبات إجازة حالياً.'));
              }
              return ListView.builder(
                itemCount: provider.leaves.length,
                itemBuilder: (context, index) {
                  final leave = provider.leaves[index];
                  return ListTile(
                    title: Text('طلب إجازة من ${leave.staffId}'),
                    subtitle: Text(
                        'من ${leave.startDate} إلى ${leave.endDate}\nالحالة: ${leave.status}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _navigateToAddEditScreen(leave),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () async {
                            await showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('تأكيد الحذف'),
                                content: const Text(
                                    'هل أنت متأكد أنك تريد حذف طلب الإجازة هذا؟'),
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
                                      await provider.deleteLeave(leave.id!);
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
        tooltip: 'إضافة طلب إجازة جديد',
        child: const Icon(Icons.add),
      ),
    );
  }
}

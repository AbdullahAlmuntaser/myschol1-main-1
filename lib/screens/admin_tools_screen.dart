import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/local_auth_service.dart';

class AdminToolsScreen extends StatefulWidget {
  const AdminToolsScreen({super.key});

  @override
  State<AdminToolsScreen> createState() => _AdminToolsScreenState();
}

class _AdminToolsScreenState extends State<AdminToolsScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch users when the screen is initialized
    Provider.of<LocalAuthService>(context, listen: false).fetchUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('أدوات المسؤول'),
      ),
      body: Consumer<LocalAuthService>(
        builder: (context, authService, child) {
          if (authService.isSessionLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          final users = authService.users;
          if (users.isEmpty) {
            return const Center(child: Text('لا يوجد مستخدمون لعرضهم.'));
          }
          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'اسم المستخدم: ${user.username}',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Text(
                            'الدور: ${user.role}',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                      if (user.id != authService.currentUser?.id) // Prevent changing own role
                        DropdownButton<String>(
                          value: user.role,
                          items: <String>['admin', 'teacher', 'student', 'parent']
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (String? newValue) async {
                            if (newValue != null) {
                              await authService.updateUserRole(user.id!, newValue);
                              // Refresh the list after update
                              await authService.fetchUsers();
                            }
                          },
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

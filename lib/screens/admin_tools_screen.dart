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
    Provider.of<LocalAuthService>(context, listen: false).fetchUsers();
  }

  Future<void> _showCreateUserDialog() async {
    final bool? success = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return const _CreateUserDialog();
      },
    );

    if (success != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'تم إنشاء المستخدم بنجاح'
                : 'فشل إنشاء المستخدم (قد يكون اسم المستخدم موجودًا بالفعل)',
          ),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
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
                      if (user.id != authService.currentUser?.id)
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
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateUserDialog,
        tooltip: 'إنشاء مستخدم جديد',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _CreateUserDialog extends StatefulWidget {
  const _CreateUserDialog();

  @override
  State<_CreateUserDialog> createState() => _CreateUserDialogState();
}

class _CreateUserDialogState extends State<_CreateUserDialog> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  String _selectedRole = 'student';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('إنشاء مستخدم جديد'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextFormField(
              controller: _usernameController,
              decoration: const InputDecoration(labelText: 'اسم المستخدم'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'الرجاء إدخال اسم المستخدم';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'كلمة المرور'),
              obscureText: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'الرجاء إدخال كلمة المرور';
                }
                return null;
              },
            ),
            DropdownButtonFormField<String>(
              initialValue: _selectedRole, // Corrected: Use initialValue
              decoration: const InputDecoration(labelText: 'الدور'),
              items: <String>['admin', 'teacher', 'student', 'parent']
                  .map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedRole = newValue;
                  });
                }
              },
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('إلغاء'),
          onPressed: () {
            Navigator.of(context).pop(null); // Return null on cancel
          },
        ),
        TextButton(
          child: const Text('إنشاء'),
          onPressed: () async {
            final navigator = Navigator.of(context); // Corrected: Capture navigator
            if (_formKey.currentState!.validate()) {
              final authService = Provider.of<LocalAuthService>(context, listen: false);
              final success = await authService.adminCreateUser(
                _usernameController.text,
                _passwordController.text,
                _selectedRole,
              );
              navigator.pop(success); // Corrected: Use captured navigator
            }
          },
        ),
      ],
    );
  }
}

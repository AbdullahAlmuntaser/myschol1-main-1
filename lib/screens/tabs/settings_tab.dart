import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../../database_helper.dart';

class SettingsTab extends StatefulWidget {
  const SettingsTab({super.key});

  @override
  State<SettingsTab> createState() => _SettingsTabState();
}

class _SettingsTabState extends State<SettingsTab> {
  String _selectedLanguage = 'العربية';

  Future<void> _exportStudentsToCsv() async {
    final dbHelper = DatabaseHelper();
    final students = await dbHelper.getStudents();

    List<List<dynamic>> rows = [];
    rows.add([
      'المعرف',
      'الاسم',
      'تاريخ الميلاد',
      'الهاتف',
      'الصف',
      'البريد الإلكتروني',
      'معرف الفصل',
    ]);
    for (var student in students) {
      rows.add([
        student.id,
        student.name,
        student.dob,
        student.phone,
        student.grade,
        student.email,
        student.classId,
      ]);
    }

    String csv = const ListToCsvConverter().convert(rows);

    final directory = await getApplicationDocumentsDirectory();
    final path = "${directory.path}/students.csv";
    final file = File(path);
    await file.writeAsString(csv);

    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('تم تصدير بيانات الطلاب إلى $path')));
  }

  Future<void> _backupDatabase() async {
    // This is a simplified backup. For a real app, you would copy the database file.
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'لم يتم تنفيذ وظيفة النسخ الاحتياطي لقاعدة البيانات بالكامل في هذا العرض التوضيحي.',
        ),
      ),
    );
  }

  Future<void> _restoreDatabase() async {
    // This is a simplified restore. For a real app, you would replace the database file.
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'لم يتم تنفيذ وظيفة استعادة قاعدة البيانات بالكامل في هذا العرض التوضيحي.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('الإعدادات')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Card(
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            child: SwitchListTile(
              title: Text(
                'الوضع الداكن',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              value: isDarkMode,
              onChanged: (value) {
                themeProvider.toggleTheme(value);
              },
              secondary: Icon(
                isDarkMode
                    ? Icons.dark_mode_outlined
                    : Icons.light_mode_outlined,
              ),
            ),
          ),
          Card(
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            child: ListTile(
              title: Text(
                'اللغة',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              trailing: DropdownButton<String>(
                value: _selectedLanguage,
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedLanguage = newValue!;
                  });
                  // Here you would implement the logic to change the app's language
                },
                items: <String>['English', 'العربية']
                    .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    })
                    .toList(),
              ),
            ),
          ),
          const Divider(height: 32),
          Text(
            'إدارة البيانات',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Card(
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            child: ListTile(
              leading: const Icon(Icons.backup_outlined),
              title: Text(
                'النسخ الاحتياطي لقاعدة البيانات',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              onTap: _backupDatabase,
            ),
          ),
          Card(
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            child: ListTile(
              leading: const Icon(Icons.restore_outlined),
              title: Text(
                'استعادة قاعدة البيانات',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              onTap: _restoreDatabase,
            ),
          ),
          Card(
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            child: ListTile(
              leading: const Icon(Icons.download_outlined),
              title: Text(
                'تصدير الطلاب إلى CSV',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              onTap: _exportStudentsToCsv,
            ),
          ),
          const Divider(height: 32),
          Card(
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            child: ListTile(
              leading: const Icon(Icons.info_outline),
              title: Text(
                'حول التطبيق',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              onTap: () {
                showAboutDialog(
                  context: context,
                  applicationName: 'نظام إدارة المدارس',
                  applicationVersion: '1.0.0',
                  applicationLegalese: '© 2023 تطبيقي. كل الحقوق محفوظة.',
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

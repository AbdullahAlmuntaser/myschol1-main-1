import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/subject_provider.dart';
import '../../providers/teacher_provider.dart';
import '../../teacher_model.dart';
import '../add_edit_teacher_screen.dart';

class TeachersTab extends StatefulWidget {
  const TeachersTab({super.key});

  @override
  State<TeachersTab> createState() => _TeachersTabState();
}

class _TeachersTabState extends State<TeachersTab> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedSubject;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _isLoading = true;
    });
    try {
      if (!mounted) return; // Check mounted before using context
      await Provider.of<TeacherProvider>(
        context,
        listen: false,
      ).fetchTeachers();
      if (!mounted) return; // Check mounted before using context
      await Provider.of<SubjectProvider>(
        context,
        listen: false,
      ).fetchSubjects();
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() async {
    setState(() {
      _isLoading = true;
    });
    try {
      if (!mounted) return; // Check mounted before using context
      await Provider.of<TeacherProvider>(
        context,
        listen: false,
      ).searchTeachers(_searchController.text, subject: _selectedSubject);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _onFilterChanged(String? subject) async {
    setState(() {
      _selectedSubject = subject;
      _isLoading = true;
    });
    try {
      if (!mounted) return; // Check mounted before using context
      await Provider.of<TeacherProvider>(
        context,
        listen: false,
      ).searchTeachers(_searchController.text, subject: _selectedSubject);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final teacherProvider = Provider.of<TeacherProvider>(context);
    final subjectProvider = Provider.of<SubjectProvider>(context);
    final isLargeScreen = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      appBar: AppBar(title: const Text('المعلمون')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      labelText: 'البحث عن معلم',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: _isLoading
                        ? null
                        : (value) => _onSearchChanged(),
                    enabled: !_isLoading,
                  ),
                ),
                const SizedBox(width: 10),
                DropdownButton<String>(
                  value: _selectedSubject,
                  hint: const Text('تصفية حسب المادة'),
                  onChanged: _isLoading
                      ? null
                      : (value) => _onFilterChanged(value),
                  items: [
                    const DropdownMenuItem<String>(
                      value: null,
                      child: Text('جميع المواد'),
                    ),
                    ...subjectProvider.subjects.map((subject) {
                      return DropdownMenuItem<String>(
                        value: subject.name,
                        child: Text(subject.name),
                      );
                    }),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : teacherProvider.teachers.isEmpty
                ? const Center(child: Text('لا يوجد معلمون حالياً.'))
                : isLargeScreen
                ? _buildDataTable(teacherProvider.teachers)
                : _buildListView(teacherProvider.teachers),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'إضافة معلم جديد',
        onPressed: _isLoading ? null : () => _navigateToAddEditScreen(null),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _navigateToAddEditScreen(Teacher? teacher) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddEditTeacherScreen(teacher: teacher),
      ),
    );
  }

  Widget _buildListView(List<Teacher> teachers) {
    return ListView.builder(
      itemCount: teachers.length,
      itemBuilder: (context, index) {
        final teacher = teachers[index];
        return Card(
          margin: const EdgeInsets.all(8.0),
          child: ListTile(
            leading: CircleAvatar(child: Text(teacher.name[0])),
            title: Text(teacher.name),
            subtitle: Text(teacher.subject),
            trailing: PopupMenuButton<String>(
              onSelected: _isLoading
                  ? null
                  : (value) {
                      if (value == 'edit') {
                        _navigateToAddEditScreen(teacher);
                      } else if (value == 'delete') {
                        _deleteTeacher(teacher);
                      }
                    },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'edit',
                  enabled: !_isLoading,
                  child: const Text('تعديل'),
                ),
                PopupMenuItem(
                  value: 'delete',
                  enabled: !_isLoading,
                  child: const Text('حذف'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDataTable(List<Teacher> teachers) {
    return DataTable(
      columns: const [
        DataColumn(label: Text('الاسم')),
        DataColumn(label: Text('المادة')),
        DataColumn(label: Text('البريد الإلكتروني')),
        DataColumn(label: Text('رقم الهاتف')),
        DataColumn(label: Text('الإجراءات')),
      ],
      rows: teachers.map((teacher) {
        return DataRow(
          cells: [
            DataCell(Text(teacher.name)),
            DataCell(Text(teacher.subject)),
            DataCell(Text(teacher.email ?? '')),
            DataCell(Text(teacher.phone)),
            DataCell(
              PopupMenuButton<String>(
                onSelected: _isLoading
                    ? null
                    : (value) {
                        if (value == 'edit') {
                          _navigateToAddEditScreen(teacher);
                        } else if (value == 'delete') {
                          _deleteTeacher(teacher);
                        }
                      },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'edit',
                    enabled: !_isLoading,
                    child: const Text('تعديل'),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    enabled: !_isLoading,
                    child: const Text('حذف'),
                  ),
                ],
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  void _deleteTeacher(Teacher teacher) async {
    // Ensure dialog context is not used after async gap, use rootNavigator if needed.
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف معلم'),
        content: const Text('هل أنت متأكد أنك تريد حذف هذا المعلم؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: _isLoading
                ? null
                : () => Navigator.of(context).pop(true),
            child: const Text('حذف'),
          ),
        ],
      ),
    );

    if (!mounted) return;

    if (confirm == true) {
      setState(() {
        _isLoading = true;
      });
      try {
        if (!mounted) return;
        final messenger = ScaffoldMessenger.of(context);
        await Provider.of<TeacherProvider>(
          context,
          listen: false,
        ).deleteTeacher(teacher.id!);
        if (!mounted) return;
        messenger.showSnackBar(
          const SnackBar(
            content: Text('تم حذف المعلم بنجاح'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل حذف المعلم: $e'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }
}

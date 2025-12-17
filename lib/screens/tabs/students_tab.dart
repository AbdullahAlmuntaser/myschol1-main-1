import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/student_provider.dart';
import '../../student_model.dart';
import '../add_edit_student_screen.dart';
import '../../providers/class_provider.dart';
import '../../class_model.dart';

class StudentsTab extends StatefulWidget {
  const StudentsTab({super.key});

  @override
  StudentsTabState createState() => StudentsTabState();
}

class StudentsTabState extends State<StudentsTab> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedClassId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (mounted) {
        setState(() {
          _isLoading = true;
        });
        try {
          await Provider.of<StudentProvider>(
            context,
            listen: false,
          ).fetchStudents();
          if (!mounted) return; // Check mounted after async operation
          await Provider.of<ClassProvider>(
            context,
            listen: false,
          ).fetchClasses();
        } finally {
          if (mounted) {
            setState(() {
              _isLoading = false;
            });
          }
        }
      }
    });
    _searchController.addListener(_filterStudents);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterStudents() async {
    setState(() {
      _isLoading = true;
    });
    try {
      if (!mounted) return;
      await Provider.of<StudentProvider>(
        context,
        listen: false,
      ).searchStudents(_searchController.text, classId: _selectedClassId);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _navigateToAddEditScreen([Student? student]) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddEditStudentScreen(student: student),
      ),
    );
  }

  Future<void> _deleteStudent(int id) async {
    final bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: const Text('هل أنت متأكد أنك تريد حذف هذا الطالب؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
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
        await Provider.of<StudentProvider>(
          context,
          listen: false,
        ).deleteStudent(id);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم حذف الطالب بنجاح'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل حذف الطالب: $e'),
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

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen =
        screenWidth > 600; // Define breakpoint for large screens

    return Scaffold(
      key: const Key('students_tab_view'),
      appBar: AppBar(
        title: const Text('الطلاب'),
        actions: const [], // No actions here, theme toggle is in dashboard
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      labelText: 'البحث بالاسم أو الرقم الأكاديمي',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12.0)),
                      ),
                    ),
                    onChanged: _isLoading ? null : (value) => _filterStudents(),
                    enabled: !_isLoading, // Disable when loading
                  ),
                ),
                const SizedBox(width: 12),
                Consumer<ClassProvider>(
                  builder: (context, classProvider, child) {
                    return DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedClassId,
                        hint: const Text('الفصل'),
                        items: [
                          const DropdownMenuItem<String>(
                            value: null,
                            child: Text('جميع الفصول'),
                          ),
                          ...classProvider.classes.map(
                            (c) => DropdownMenuItem<String>(
                              value: c.classId,
                              child: Text(c.name),
                            ),
                          ),
                        ].toList(),
                        onChanged: _isLoading
                            ? null
                            : (String? newValue) {
                                setState(() {
                                  _selectedClassId = newValue;
                                  _filterStudents();
                                });
                              },
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Consumer<StudentProvider>(
                    builder: (context, studentProvider, child) {
                      if (studentProvider.students.isEmpty) {
                        return const Center(
                          child: Text('لا يوجد طلاب حالياً.'),
                        );
                      }
                      return isLargeScreen
                          ? _buildWebLayout(studentProvider.students)
                          : _buildMobileLayout(studentProvider.students);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _isLoading ? null : () => _navigateToAddEditScreen(),
        tooltip: 'إضافة طالب جديد',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildMobileLayout(List<Student> students) {
    return ListView.builder(
      itemCount: students.length,
      itemBuilder: (context, index) {
        final student = students[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
          child: ListTile(
            leading: const CircleAvatar(child: Icon(Icons.person)),
            title: Text(student.name),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'الرقم الأكاديمي: ${student.academicNumber ?? 'غير متوفر'}',
                ),
                Text('الصف: ${student.grade}'),
                if (student.classId != null)
                  Text(
                    'الفصل: ${Provider.of<ClassProvider>(context, listen: false).classes.firstWhere(
                      (c) => c.classId == student.classId,
                      orElse: () => SchoolClass(name: 'غير معروف', classId: ''),
                    ).name}',
                  ),
                Text('الحالة: ${student.status ? 'نشط' : 'غير نشط'}'),
              ],
            ),
            trailing: PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') {
                  _navigateToAddEditScreen(student);
                } else if (value == 'delete') {
                  _deleteStudent(student.id!); // Ensure id is not null
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  enabled: !_isLoading,
                  value: 'edit',
                  child: const Text('تعديل'),
                ), // child is last
                PopupMenuItem(
                  enabled: !_isLoading,
                  value: 'delete',
                  child: const Text('حذف'),
                ), // child is last
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildWebLayout(List<Student> students) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: DataTable(
        columns: const [
          DataColumn(label: Text('الاسم')),
          DataColumn(label: Text('الرقم الأكاديمي')),
          DataColumn(label: Text('البريد الإلكتروني')),
          DataColumn(label: Text('الصف')),
          DataColumn(label: Text('الفصل')),
          DataColumn(label: Text('ولي الأمر')),
          DataColumn(label: Text('الحالة')),
          DataColumn(label: Text('الإجراءات')),
        ],
        rows: students.map((student) {
          final className = Provider.of<ClassProvider>(context, listen: false)
              .classes
              .firstWhere(
                (c) => c.classId == student.classId,
                orElse: () => SchoolClass(name: 'غير معروف', classId: ''),
              )
              .name;

          return DataRow(
            cells: [
              DataCell(Text(student.name)),
              DataCell(Text(student.academicNumber ?? 'غير متوفر')),
              DataCell(Text(student.email ?? 'غير متوفر')),
              DataCell(Text(student.grade)),
              DataCell(Text(className)),
              DataCell(Text(student.parentName ?? 'غير متوفر')),
              DataCell(Text(student.status ? 'نشط' : 'غير نشط')),
              DataCell(
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: _isLoading
                          ? null
                          : () => _navigateToAddEditScreen(student),
                      tooltip: 'تعديل',
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: _isLoading
                          ? null
                          : () => _deleteStudent(student.id!),
                      tooltip: 'حذف',
                    ),
                  ],
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

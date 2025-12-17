import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:developer' as developer; // Added import for logging

import '../../providers/subject_provider.dart';
import '../../subject_model.dart';
import '../add_edit_subject_screen.dart';

class SubjectsTab extends StatefulWidget {
  const SubjectsTab({super.key});

  @override
  SubjectsTabState createState() => SubjectsTabState();
}

class SubjectsTabState extends State<SubjectsTab> {
  final TextEditingController _searchController = TextEditingController();
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
    });
    _searchController.addListener(_filterSubjects);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterSubjects() async {
    // Made async
    setState(() {
      _isLoading = true;
    });
    try {
      await Provider.of<SubjectProvider>(
        context,
        listen: false,
      ).searchSubjects(_searchController.text);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _navigateToAddEditScreen([Subject? subject]) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddEditSubjectScreen(subject: subject),
      ),
    );
  }

  Future<void> _deleteSubject(int id) async {
    final bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: const Text('هل أنت متأكد أنك تريد حذف هذه المادة؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: _isLoading
                ? null
                : () => Navigator.of(context).pop(true), // Disable when loading
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
        await Provider.of<SubjectProvider>(
          context,
          listen: false,
        ).deleteSubject(id);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم حذف المادة بنجاح'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e, s) {
        // Added stack trace parameter 's'
        if (!mounted) return;
        developer.log(
          'فشل حذف المادة',
          name: 'subjects_tab',
          level: 900, // WARNING
          error: e,
          stackTrace: s,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'حدث خطأ غير متوقع أثناء حذف المادة. الرجاء المحاولة مرة أخرى.',
            ), // User-friendly message
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
    return Scaffold(
      appBar: AppBar(title: const Text('المواد الدراسية')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'البحث باسم المادة أو المعرف',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12.0)),
                ),
              ),
              onChanged: _isLoading
                  ? null
                  : (value) => _filterSubjects(), // Disable when loading
              enabled: !_isLoading, // Disable when loading
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(),
                  ) // Show loading indicator
                : Consumer<SubjectProvider>(
                    builder: (context, subjectProvider, child) {
                      if (subjectProvider.subjects.isEmpty) {
                        return const Center(
                          child: Text('لا توجد مواد حالياً.'),
                        );
                      }
                      return ListView.builder(
                        itemCount: subjectProvider.subjects.length,
                        itemBuilder: (context, index) {
                          final subject = subjectProvider.subjects[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 12.0,
                              vertical: 6.0,
                            ),
                            child: ListTile(
                              title: Text(subject.name),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('معرف المادة: ${subject.subjectId}'),
                                  if (subject.description != null &&
                                      subject.description!.isNotEmpty)
                                    Text('الوصف: ${subject.description}'),
                                  if (subject.teacherId != null)
                                    Text(
                                      'معرف المعلم المسؤول: ${subject.teacherId}',
                                    ),
                                  if (subject.curriculumDescription != null &&
                                      subject.curriculumDescription!.isNotEmpty)
                                    Text(
                                      'وصف المنهج: ${subject.curriculumDescription}',
                                    ),
                                  if (subject.learningObjectives != null &&
                                      subject.learningObjectives!.isNotEmpty)
                                    Text(
                                      'أهداف التعلم: ${subject.learningObjectives}',
                                    ),
                                  if (subject.recommendedResources != null &&
                                      subject.recommendedResources!.isNotEmpty)
                                    Text(
                                      'المصادر الموصى بها: ${subject.recommendedResources}',
                                    ),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: _isLoading
                                        ? null
                                        : () =>
                                              _navigateToAddEditScreen(subject),
                                    tooltip: 'تعديل',
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: _isLoading
                                        ? null
                                        : () => _deleteSubject(subject.id!),
                                    tooltip: 'حذف',
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _isLoading
            ? null
            : () => _navigateToAddEditScreen(), // Disable when loading
        tooltip: 'إضافة مادة جديدة',
        child: const Icon(Icons.add),
      ),
    );
  }
}

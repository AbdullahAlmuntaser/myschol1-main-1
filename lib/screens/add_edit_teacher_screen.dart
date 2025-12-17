import 'package:flutter/material.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:provider/provider.dart';
import 'dart:developer' as developer; // Added for logging

import '../providers/subject_provider.dart';
import '../providers/teacher_provider.dart';
import '../teacher_model.dart';
import '../subject_model.dart';

class AddEditTeacherScreen extends StatefulWidget {
  final Teacher? teacher;

  const AddEditTeacherScreen({super.key, this.teacher});

  @override
  State<AddEditTeacherScreen> createState() => _AddEditTeacherScreenState();
}

class _AddEditTeacherScreenState extends State<AddEditTeacherScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _phoneController;
  late TextEditingController _qualificationController;
  List<Subject> _selectedSubjects = [];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.teacher?.name ?? '');
    _emailController = TextEditingController(text: widget.teacher?.email ?? '');
    _passwordController = TextEditingController();
    _phoneController = TextEditingController(text: widget.teacher?.phone ?? '');
    _qualificationController = TextEditingController(
      text: widget.teacher?.qualificationType ?? '',
    );

    if (widget.teacher != null) {
      // Fetch subjects for the existing teacher
      final subjectProvider = Provider.of<SubjectProvider>(
        context,
        listen: false,
      );
      final teacherSubjects = widget.teacher!.subject.split(',');
      _selectedSubjects = subjectProvider.subjects
          .where((subject) => teacherSubjects.contains(subject.name))
          .toList();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _qualificationController.dispose();
    super.dispose();
  }

  Future<void> _saveTeacher() async {
    // Made async
    if (_formKey.currentState!.validate()) {
      final teacherProvider = Provider.of<TeacherProvider>(
        context,
        listen: false,
      );
      final subjects = _selectedSubjects.map((s) => s.name).join(',');

      final newTeacher = Teacher(
        id: widget.teacher?.id,
        name: _nameController.text,
        email: _emailController.text,
        password: _passwordController.text,
        phone: _phoneController.text,
        qualificationType: _qualificationController.text,
        subject: subjects,
        responsibleClassId: widget.teacher?.responsibleClassId,
      );

      String message;
      try {
        if (widget.teacher == null) {
          await teacherProvider.addTeacher(newTeacher);
          message = 'تمت إضافة المعلم بنجاح';
        } else {
          await teacherProvider.updateTeacher(newTeacher);
          message = 'تم تحديث المعلم بنجاح';
        }
        if (!mounted) return;
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.green),
        );
      } catch (e, s) {
        // Added stack trace for logging
        if (!mounted) return;
        developer.log(
          'فشل حفظ المعلم',
          name: 'add_edit_teacher_screen',
          level: 900, // WARNING
          error: e,
          stackTrace: s,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل حفظ المعلم: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final subjectProvider = Provider.of<SubjectProvider>(context);
    final allSubjects = subjectProvider.subjects;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.teacher == null ? 'إضافة معلم' : 'تعديل معلم'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'الاسم الكامل'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'يرجى إدخال اسم المعلم';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'البريد الإلكتروني',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'يرجى إدخال البريد الإلكتروني';
                  }
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return 'يرجى إدخال بريد إلكتروني صحيح';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'كلمة المرور'),
                obscureText: true,
                validator: (value) {
                  if (widget.teacher == null &&
                      (value == null || value.isEmpty)) {
                    return 'يرجى إدخال كلمة المرور';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'رقم الهاتف'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'يرجى إدخال رقم الهاتف';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _qualificationController,
                decoration: const InputDecoration(labelText: 'المؤهل العلمي'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'يرجى إدخال المؤهل العلمي';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              MultiSelectDialogField<Subject>(
                items: allSubjects
                    .map((s) => MultiSelectItem<Subject>(s, s.name))
                    .toList(),
                title: const Text('المواد'),
                selectedColor: Theme.of(context).primaryColor,
                onConfirm: (values) {
                  setState(() {
                    _selectedSubjects = values;
                  });
                },
                initialValue: _selectedSubjects,
                chipDisplay: MultiSelectChipDisplay(
                  items: _selectedSubjects
                      .map((s) => MultiSelectItem<Subject>(s, s.name))
                      .toList(),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: _saveTeacher, child: const Text('حفظ')),
            ],
          ),
        ),
      ),
    );
  }
}

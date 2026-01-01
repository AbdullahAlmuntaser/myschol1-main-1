import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/class_provider.dart';
import '../../class_model.dart';
import '../../subject_model.dart';

import '../../custom_exception.dart';

class AddEditClassScreen extends StatefulWidget {
  final SchoolClass? schoolClass;

  const AddEditClassScreen({super.key, this.schoolClass});

  @override
  AddEditClassScreenState createState() => AddEditClassScreenState();
}

class AddEditClassScreenState extends State<AddEditClassScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedClassName;
  late TextEditingController _classIdController;
  late TextEditingController _teacherIdController;
  late TextEditingController _capacityController;
  late TextEditingController _yearTermController;

  final List<Subject> _selectedSubjects = []; // Full Subject objects of selected items



  final List<String> _classNames = [
    'الأول الابتدائي',
    'الثاني الابتدائي',
    'الثالث الابتدائي',
    'الرابع الابتدائي',
    'الخامس الابتدائي',
    'السادس الابتدائي',
    'الأول المتوسط',
    'الثاني المتوسط',
    'الثالث المتوسط',
    'الأول الثانوي',
    'الثاني الثانوي',
    'الثالث الثانوي',
  ];

  @override
  void initState() {
    super.initState();
    _selectedClassName = widget.schoolClass?.name;
    _classIdController =
        TextEditingController(text: widget.schoolClass?.classId ?? '');
    _teacherIdController = TextEditingController(
        text: widget.schoolClass?.teacherId?.toString() ?? '');
    _capacityController = TextEditingController(
        text: widget.schoolClass?.capacity?.toString() ?? '');
    _yearTermController =
        TextEditingController(text: widget.schoolClass?.yearTerm ?? '');


  }

  @override
  void dispose() {
    _classIdController.dispose();
    _teacherIdController.dispose();
    _capacityController.dispose();
    _yearTermController.dispose();
    super.dispose();
  }

  Future<void> _saveClass() async {
    if (_formKey.currentState!.validate()) {
      final schoolClass = SchoolClass(
        id: widget.schoolClass?.id,
        name: _selectedClassName!,
        classId: _classIdController.text,
        teacherId: int.tryParse(_teacherIdController.text),
        capacity: int.tryParse(_capacityController.text),
        yearTerm: _yearTermController.text.isNotEmpty
            ? _yearTermController.text
            : null,
        subjectIds: _selectedSubjects.map((s) => s.subjectId).toList(),
      );

      final provider = Provider.of<ClassProvider>(context, listen: false);
      final message = widget.schoolClass == null
          ? 'تمت إضافة الصف بنجاح'
          : 'تم تحديث الصف بنجاح';

      try {
        if (widget.schoolClass == null) {
          await provider.addClass(schoolClass);
        } else {
          await provider.updateClass(schoolClass);
        }
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.green),
        );
        Navigator.of(context).pop();
      } on CustomException catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message),
            backgroundColor: Colors.red,
          ),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('فشل حفظ الصف. الرجاء المحاولة مرة أخرى.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.schoolClass == null ? 'إضافة صف' : 'تعديل صف'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: _selectedClassName,
                  decoration: const InputDecoration(
                    labelText: 'اسم الصف',
                    border: OutlineInputBorder(),
                  ),
                  items: _classNames.map((String className) {
                    return DropdownMenuItem<String>(
                      value: className,
                      child: Text(className),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      _selectedClassName = newValue;
                    });
                  },
                  validator: (value) =>
                      value == null ? 'الرجاء اختيار اسم الصف' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _classIdController,
                  decoration: const InputDecoration(
                    labelText: 'معرف الصف (فريد)',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value!.isEmpty ? 'الرجاء إدخال معرف صف فريد' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _teacherIdController,
                  decoration: const InputDecoration(
                    labelText: 'معرف المعلم المسؤول (اختياري)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _capacityController,
                  decoration: const InputDecoration(
                    labelText: 'السعة (عدد الطلاب) (اختياري)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) return null;
                    if (int.tryParse(value) == null) {
                      return 'الرجاء إدخال رقم صحيح';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _yearTermController,
                  decoration: const InputDecoration(
                    labelText: 'السنة/الفصل الدراسي (اختياري)',
                    border: OutlineInputBorder(),
                  ),
                ),
                // Placeholder for subject selection
                const SizedBox(height: 16),
                const Text('Subject selection feature is currently disabled.'),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _saveClass,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  child: const Text('حفظ'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

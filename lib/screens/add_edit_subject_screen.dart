import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../custom_exception.dart';
import '../providers/subject_provider.dart';
import '../subject_model.dart';

class AddEditSubjectScreen extends StatefulWidget {
  final Subject? subject;

  const AddEditSubjectScreen({super.key, this.subject});

  @override
  AddEditSubjectScreenState createState() => AddEditSubjectScreenState();
}

class AddEditSubjectScreenState extends State<AddEditSubjectScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _subjectIdController;
  late TextEditingController _descriptionController;
  late TextEditingController _teacherIdController;
  late TextEditingController _curriculumDescriptionController;
  late TextEditingController _learningObjectivesController;
  late TextEditingController _recommendedResourcesController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.subject?.name ?? '');
    _subjectIdController = TextEditingController(
      text: widget.subject?.subjectId ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.subject?.description ?? '',
    );
    _teacherIdController = TextEditingController(
      text: widget.subject?.teacherId?.toString() ?? '',
    );
    _curriculumDescriptionController = TextEditingController(
      text: widget.subject?.curriculumDescription ?? '',
    );
    _learningObjectivesController = TextEditingController(
      text: widget.subject?.learningObjectives ?? '',
    );
    _recommendedResourcesController = TextEditingController(
      text: widget.subject?.recommendedResources ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _subjectIdController.dispose();
    _descriptionController.dispose();
    _teacherIdController.dispose();
    _curriculumDescriptionController.dispose();
    _learningObjectivesController.dispose();
    _recommendedResourcesController.dispose();
    super.dispose();
  }

  Future<void> _saveSubject() async {
    if (_formKey.currentState!.validate()) {
      final subject = Subject(
        id: widget.subject?.id,
        name: _nameController.text,
        subjectId: _subjectIdController.text,
        description: _descriptionController.text.isNotEmpty
            ? _descriptionController.text
            : null,
        teacherId: _teacherIdController.text.isNotEmpty
            ? int.tryParse(_teacherIdController.text)
            : null,
        curriculumDescription: _curriculumDescriptionController.text.isNotEmpty
            ? _curriculumDescriptionController.text
            : null,
        learningObjectives: _learningObjectivesController.text.isNotEmpty
            ? _learningObjectivesController.text
            : null,
        recommendedResources: _recommendedResourcesController.text.isNotEmpty
            ? _recommendedResourcesController.text
            : null,
      );

      final provider = Provider.of<SubjectProvider>(context, listen: false);
      final message = widget.subject == null
          ? 'تمت إضافة المادة بنجاح'
          : 'تم تحديث المادة بنجاح';

      try {
        if (widget.subject == null) {
          await provider.addSubject(subject);
        } else {
          await provider.updateSubject(subject);
        }
        if (!mounted) return;
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.green),
        );
      } on CustomException catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message), backgroundColor: Colors.red),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل حفظ المادة: $e'),
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
        title: Text(widget.subject == null ? 'إضافة مادة' : 'تعديل مادة'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'اسم المادة',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value!.isEmpty ? 'الرجاء إدخال اسم المادة' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _subjectIdController,
                  decoration: const InputDecoration(
                    labelText: 'معرف المادة (فريد)',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value!.isEmpty ? 'الرجاء إدخال معرف مادة فريد' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'الوصف (اختياري)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
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
                  controller: _curriculumDescriptionController,
                  decoration: const InputDecoration(
                    labelText: 'وصف المنهج الدراسي (اختياري)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 5,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _learningObjectivesController,
                  decoration: const InputDecoration(
                    labelText: 'أهداف التعلم (اختياري، مفصولة بفواصل)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _recommendedResourcesController,
                  decoration: const InputDecoration(
                    labelText: 'المصادر الموصى بها (اختياري، مفصولة بفواصل)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _saveSubject,
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

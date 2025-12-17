import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/academic_year_provider.dart';
import '../academic_year_model.dart';

class AddEditAcademicYearDialog extends StatefulWidget {
  final AcademicYear? academicYear;

  const AddEditAcademicYearDialog({super.key, this.academicYear});

  @override
  AddEditAcademicYearDialogState createState() =>
      AddEditAcademicYearDialogState();
}

class AddEditAcademicYearDialogState extends State<AddEditAcademicYearDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _startDateController;
  late TextEditingController _endDateController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.academicYear?.name ?? '');
    _startDateController = TextEditingController(
      text: widget.academicYear?.startDate ?? '',
    );
    _endDateController = TextEditingController(
      text: widget.academicYear?.endDate ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.tryParse(controller.text) ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        controller.text = picked.toIso8601String().split('T').first; // Format as YYYY-MM-DD
      });
    }
  }

  Future<void> _saveAcademicYear() async {
    if (_formKey.currentState!.validate()) {
      final academicYear = AcademicYear(
        id: widget.academicYear?.id,
        name: _nameController.text,
        startDate: _startDateController.text,
        endDate: _endDateController.text,
        isActive: widget.academicYear?.isActive ?? false, // Maintain existing status
      );

      final provider = Provider.of<AcademicYearProvider>(context, listen: false);
      try {
        if (widget.academicYear == null) {
          await provider.addAcademicYear(academicYear);
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تمت إضافة العام الدراسي بنجاح'), backgroundColor: Colors.green),
          );
        } else {
          await provider.updateAcademicYear(academicYear);
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم تحديث العام الدراسي بنجاح'), backgroundColor: Colors.green),
          );
        }
        if (!mounted) return;
        Navigator.of(context).pop();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل حفظ العام الدراسي: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.academicYear == null ? 'إضافة عام دراسي' : 'تعديل عام دراسي'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'اسم العام الدراسي'),
                validator: (value) =>
                    value!.isEmpty ? 'الرجاء إدخال اسم العام الدراسي' : null,
              ),
              TextFormField(
                controller: _startDateController,
                decoration: InputDecoration(
                  labelText: 'تاريخ البدء',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () => _selectDate(context, _startDateController),
                  ),
                ),
                readOnly: true,
                validator: (value) =>
                    value!.isEmpty ? 'الرجاء تحديد تاريخ البدء' : null,
              ),
              TextFormField(
                controller: _endDateController,
                decoration: InputDecoration(
                  labelText: 'تاريخ الانتهاء',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () => _selectDate(context, _endDateController),
                  ),
                ),
                readOnly: true,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'الرجاء تحديد تاريخ الانتهاء';
                  }
                  if (DateTime.tryParse(_startDateController.text) != null &&
                      DateTime.tryParse(value) != null &&
                      DateTime.parse(value).isBefore(
                          DateTime.parse(_startDateController.text))) {
                    return 'تاريخ الانتهاء يجب أن يكون بعد تاريخ البدء';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('إلغاء'),
        ),
        ElevatedButton(
          onPressed: _saveAcademicYear,
          child: const Text('حفظ'),
        ),
      ],
    );
  }
}
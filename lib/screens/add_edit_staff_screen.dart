import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../custom_exception.dart';
import '../staff_model.dart';
import '../providers/staff_provider.dart';

class AddEditStaffScreen extends StatefulWidget {
  final Staff? staff;

  const AddEditStaffScreen({super.key, this.staff});

  @override
  AddEditStaffScreenState createState() => AddEditStaffScreenState();
}

class AddEditStaffScreenState extends State<AddEditStaffScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _positionController;
  late TextEditingController _departmentController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _addressController;
  late TextEditingController _hireDateController;
  late TextEditingController _salaryController;
  late TextEditingController _userIdController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.staff?.name ?? '');
    _positionController = TextEditingController(text: widget.staff?.position ?? '');
    _departmentController = TextEditingController(text: widget.staff?.department ?? '');
    _phoneController = TextEditingController(text: widget.staff?.phone ?? '');
    _emailController = TextEditingController(text: widget.staff?.email ?? '');
    _addressController = TextEditingController(text: widget.staff?.address ?? '');
    _hireDateController = TextEditingController(text: widget.staff?.hireDate ?? '');
    _salaryController = TextEditingController(text: widget.staff?.salary.toString() ?? '');
    _userIdController = TextEditingController(text: widget.staff?.userId?.toString() ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _positionController.dispose();
    _departmentController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _hireDateController.dispose();
    _salaryController.dispose();
    _userIdController.dispose();
    super.dispose();
  }

  Future<void> _saveStaff() async {
    if (_formKey.currentState!.validate()) {
      final staff = Staff(
        id: widget.staff?.id,
        name: _nameController.text,
        position: _positionController.text,
        department: _departmentController.text,
        phone: _phoneController.text,
        email: _emailController.text.isNotEmpty ? _emailController.text : null,
        address: _addressController.text.isNotEmpty ? _addressController.text : null,
        hireDate: _hireDateController.text,
        salary: double.tryParse(_salaryController.text) ?? 0.0,
        userId: int.tryParse(_userIdController.text),
      );

      final provider = Provider.of<StaffProvider>(context, listen: false);
      final message = widget.staff == null
          ? 'تمت إضافة الموظف بنجاح'
          : 'تم تحديث الموظف بنجاح';

      try {
        if (widget.staff == null) {
          await provider.addStaff(staff);
        } else {
          await provider.updateStaff(staff);
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
            content: Text('فشل حفظ الموظف: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Helper to pick date
  Future<void> _pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.tryParse(_hireDateController.text) ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _hireDateController.text = picked.toIso8601String().split('T').first; // Format YYYY-MM-DD
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.staff == null ? 'إضافة موظف' : 'تعديل موظف'),
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
                    labelText: 'الاسم الكامل',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value!.isEmpty ? 'الرجاء إدخال اسم الموظف' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _positionController,
                  decoration: const InputDecoration(
                    labelText: 'المسمى الوظيفي',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value!.isEmpty ? 'الرجاء إدخال المسمى الوظيفي' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _departmentController,
                  decoration: const InputDecoration(
                    labelText: 'القسم',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value!.isEmpty ? 'الرجاء إدخال القسم' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                    labelText: 'رقم الهاتف',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (value) =>
                      value!.isEmpty ? 'الرجاء إدخال رقم الهاتف' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'البريد الإلكتروني (اختياري)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _addressController,
                  decoration: const InputDecoration(
                    labelText: 'العنوان (اختياري)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _hireDateController,
                  decoration: InputDecoration(
                    labelText: 'تاريخ التعيين',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: _pickDate,
                    ),
                  ),
                  readOnly: true,
                  validator: (value) =>
                      value!.isEmpty ? 'الرجاء اختيار تاريخ التعيين' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _salaryController,
                  decoration: const InputDecoration(
                    labelText: 'الراتب',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) =>
                      value!.isEmpty ? 'الرجاء إدخال الراتب' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _userIdController,
                  decoration: const InputDecoration(
                    labelText: 'معرف المستخدم (اختياري)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _saveStaff,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  child: const Text('حفظ الموظف'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

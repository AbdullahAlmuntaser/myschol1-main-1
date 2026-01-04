import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/student_provider.dart';
import '../student_model.dart';
import '../providers/class_provider.dart';
import '../class_model.dart';
import '../user_model.dart';
import '../services/local_auth_service.dart'; 

class AddEditStudentScreen extends StatefulWidget {
  final Student? student;

  const AddEditStudentScreen({super.key, this.student});

  @override
  AddEditStudentScreenState createState() => AddEditStudentScreenState();
}

class AddEditStudentScreenState extends State<AddEditStudentScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _dobController;
  late TextEditingController _phoneController;
  late TextEditingController _gradeController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _academicNumberController;
  late TextEditingController _sectionController;
  late TextEditingController _parentNameController;
  late TextEditingController _parentPhoneController;
  late TextEditingController _addressController;

  String? _selectedClassId;
  bool _status = true;
  List<User> _parents = [];
  int? _selectedParentUserId;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.student?.name ?? '');
    _dobController = TextEditingController(text: widget.student?.dob ?? '');
    _phoneController = TextEditingController(text: widget.student?.phone ?? '');
    _gradeController = TextEditingController(text: widget.student?.grade ?? '');
    _emailController = TextEditingController(text: widget.student?.email ?? '');
    _passwordController = TextEditingController(
      text: widget.student?.password ?? '',
    );
    _academicNumberController = TextEditingController(
      text: widget.student?.academicNumber ?? '',
    );
    _sectionController = TextEditingController(
      text: widget.student?.section ?? '',
    );
    _parentNameController = TextEditingController(
      text: widget.student?.parentName ?? '',
    );
    _parentPhoneController = TextEditingController(
      text: widget.student?.parentPhone ?? '',
    );
    _addressController = TextEditingController(
      text: widget.student?.address ?? '',
    );

    _selectedClassId = widget.student?.classId;
    _status = widget.student?.status ?? true;
    _selectedParentUserId = widget.student?.parentUserId;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ClassProvider>(context, listen: false).fetchClasses();
      _fetchParents();
    });
  }

  Future<void> _fetchParents() async {
    final authService = Provider.of<LocalAuthService>(context, listen: false);
    await authService.fetchUsers();
    final allParentUsers = authService.users.where((user) => user.role == 'parent').toList();

    if (mounted) {
      setState(() {
        _parents = allParentUsers;
        if (_selectedParentUserId != null) {
          final selectedParent = _parents.firstWhere(
            (p) => p.id == _selectedParentUserId,
            orElse: () => _parents.first,
          );
          _parentNameController.text = selectedParent.username;
          _parentPhoneController.text = selectedParent.phone ?? '';
        }
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dobController.dispose();
    _phoneController.dispose();
    _gradeController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _academicNumberController.dispose();
    _sectionController.dispose();
    _parentNameController.dispose();
    _parentPhoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _dobController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _saveStudent() async {
    if (_formKey.currentState!.validate()) {
      final student = Student(
        id: widget.student?.id,
        name: _nameController.text,
        dob: _dobController.text,
        phone: _phoneController.text,
        grade: _gradeController.text,
        email: _emailController.text,
        password: _passwordController.text,
        classId: _selectedClassId,
        academicNumber: _academicNumberController.text,
        section: _sectionController.text,
        parentName: _parentNameController.text,
        parentPhone: _parentPhoneController.text,
        address: _addressController.text,
        status: _status,
        parentUserId: _selectedParentUserId,
      );

      final provider = Provider.of<StudentProvider>(context, listen: false);
      String message = widget.student == null
          ? 'تمت إضافة الطالب بنجاح'
          : 'تم تحديث الطالب بنجاح';
      try {
        if (widget.student == null) {
          await provider.addStudent(student);
        } else {
          await provider.updateStudent(student);
        }
        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message), backgroundColor: Colors.green),
          );
        }
      } catch (e) {
        if (mounted) {
          String errorMessage = 'فشل حفظ الطالب. الرجاء المحاولة مرة أخرى.';
          if (e is Exception) {
            errorMessage = e.toString().replaceFirst('Exception: ', '');
          } else if (e is String) {
            errorMessage = e;
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.student == null ? 'Add Student' : 'Edit Student'),
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
                  decoration: const InputDecoration(labelText: 'Full Name'),
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter a name' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _academicNumberController,
                  decoration: const InputDecoration(
                    labelText: 'Academic Number',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter an academic number' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _dobController,
                  decoration: const InputDecoration(
                    labelText: 'Date of Birth',
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  readOnly: true,
                  onTap: _selectDate,
                  validator: (value) =>
                      value!.isEmpty ? 'Please select a date of birth' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(labelText: 'Phone Number'),
                  keyboardType: TextInputType.phone,
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter a phone number' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _gradeController,
                  decoration: const InputDecoration(labelText: 'Grade/Class'),
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter a grade' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an email';
                    }
                    if (!RegExp(
                      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
                    ).hasMatch(value)) {
                      return 'Please enter a valid email address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true,
                ),
                const SizedBox(height: 16),
                Consumer<ClassProvider>(
                  builder: (context, classProvider, child) {
                    return DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Class'),
                      initialValue: _selectedClassId,
                      hint: const Text('Select a class'),
                      items: classProvider.classes.map((SchoolClass classItem) {
                        return DropdownMenuItem<String>(
                          value: classItem.classId,
                          child: Text(classItem.name),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedClassId = newValue;
                        });
                      },
                      validator: (value) => value == null || value.isEmpty
                          ? 'Please select a class'
                          : null,
                    );
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _sectionController,
                  decoration: const InputDecoration(
                    labelText: 'Section (Optional)',
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<int>(
                  decoration: const InputDecoration(
                    labelText: 'Link Parent (Optional)',
                  ),
                  initialValue: _selectedParentUserId,
                  hint: const Text('Select a parent'),
                  items: _parents.map((User parentUser) {
                    return DropdownMenuItem<int>(
                      value: parentUser.id,
                      child: Text(
                        '${parentUser.username} (${parentUser.role})',
                      ),
                    );
                  }).toList(),
                  onChanged: (int? newValue) {
                    setState(() {
                      _selectedParentUserId = newValue;
                      if (newValue != null) {
                        final selectedParent = _parents.firstWhere(
                          (p) => p.id == newValue,
                        );
                        _parentNameController.text = selectedParent.username;
                        _parentPhoneController.text =
                            selectedParent.phone ?? '';
                      } else {
                        _parentNameController.clear();
                        _parentPhoneController.clear();
                      }
                    });
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _parentNameController,
                  decoration: const InputDecoration(labelText: 'Parent Name'),
                  readOnly: true,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _parentPhoneController,
                  decoration: const InputDecoration(labelText: 'Parent Phone'),
                  keyboardType: TextInputType.phone,
                  readOnly: true,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _addressController,
                  decoration: const InputDecoration(
                    labelText: 'Address (Optional)',
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('Student Status'),
                  subtitle: Text(_status ? 'Active' : 'Inactive'),
                  value: _status,
                  onChanged: (bool value) {
                    setState(() {
                      _status = value;
                    });
                  },
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _saveStudent,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Save Student'),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

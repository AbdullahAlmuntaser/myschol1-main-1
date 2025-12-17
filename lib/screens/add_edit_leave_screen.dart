import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../leave_model.dart';
import '../staff_model.dart';
import '../custom_exception.dart';
import '../providers/staff_provider.dart';
import '../providers/leave_provider.dart'; // Added LeaveProvider import

class AddEditLeaveScreen extends StatefulWidget {
  final Leave? leave;

  const AddEditLeaveScreen({super.key, this.leave});

  @override
  AddEditLeaveScreenState createState() => AddEditLeaveScreenState();
}

class AddEditLeaveScreenState extends State<AddEditLeaveScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _staffIdController;
  late TextEditingController _leaveTypeController;
  late TextEditingController _startDateController;
  late TextEditingController _endDateController;
  late TextEditingController _reasonController;
  late String _status;
  Staff? _selectedStaff;
  List<Staff> _allStaff = [];

  @override
  void initState() {
    super.initState();
    _staffIdController = TextEditingController(text: widget.leave?.staffId.toString() ?? '');
    _leaveTypeController = TextEditingController(text: widget.leave?.leaveType ?? '');
    _startDateController = TextEditingController(text: widget.leave?.startDate ?? '');
    _endDateController = TextEditingController(text: widget.leave?.endDate ?? '');
    _reasonController = TextEditingController(text: widget.leave?.reason ?? '');
    _status = widget.leave?.status ?? 'Pending';
    _loadStaff();
  }

  Future<void> _loadStaff() async {
    final staffProvider = Provider.of<StaffProvider>(context, listen: false);
    await staffProvider.fetchStaff();
    _allStaff = staffProvider.staff;
    if (widget.leave != null) {
      _selectedStaff = _allStaff.firstWhere(
        (staff) => staff.id == widget.leave!.staffId,
        orElse: () => _allStaff.first, // Fallback if staff not found
      );
    }
    setState(() {}); // Rebuild to show dropdown with selected staff
  }

  @override
  void dispose() {
    _staffIdController.dispose();
    _leaveTypeController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _saveLeave() async {
    if (_formKey.currentState!.validate()) {
      final leave = Leave(
        id: widget.leave?.id,
        staffId: _selectedStaff!.id!,
        leaveType: _leaveTypeController.text,
        startDate: _startDateController.text,
        endDate: _endDateController.text,
        reason: _reasonController.text,
        status: _status,
        // approvedByUserId: ... // Will be set when leave is approved/rejected
      );

      final provider = Provider.of<LeaveProvider>(context, listen: false); // Uncommented
      final message = widget.leave == null
          ? 'تمت إضافة طلب الإجازة بنجاح'
          : 'تم تحديث طلب الإجازة بنجاح';

      try {
        if (widget.leave == null) {
          await provider.addLeave(leave);
        } else {
          await provider.updateLeave(leave);
        }
        if (!mounted) return;
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.green), // Used message
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
            content: Text('فشل حفظ طلب الإجازة: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Helper to pick date
  Future<void> _pickDate(TextEditingController controller) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.tryParse(controller.text) ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        controller.text = picked.toIso8601String().split('T').first; // Format YYYY-MM-DD
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.leave == null ? 'إضافة طلب إجازة' : 'تعديل طلب إجازة'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Staff Dropdown
                DropdownButtonFormField<Staff>(
                  initialValue: _selectedStaff,
                  decoration: const InputDecoration(
                    labelText: 'الموظف',
                    border: OutlineInputBorder(),
                  ),
                  items: _allStaff.map((staff) {
                    return DropdownMenuItem<Staff>(
                      value: staff,
                      child: Text(staff.name),
                    );
                  }).toList(),
                  onChanged: (staff) {
                    setState(() {
                      _selectedStaff = staff;
                      _staffIdController.text = staff?.id.toString() ?? '';
                    });
                  },
                  validator: (value) => value == null ? 'الرجاء اختيار موظف' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _leaveTypeController,
                  decoration: const InputDecoration(
                    labelText: 'نوع الإجازة (مثل سنوية، مرضية)',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value!.isEmpty ? 'الرجاء إدخال نوع الإجازة' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _startDateController,
                  decoration: InputDecoration(
                    labelText: 'تاريخ البدء',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: () => _pickDate(_startDateController),
                    ),
                  ),
                  readOnly: true,
                  validator: (value) =>
                      value!.isEmpty ? 'الرجاء اختيار تاريخ بدء الإجازة' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _endDateController,
                  decoration: InputDecoration(
                    labelText: 'تاريخ الانتهاء',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: () => _pickDate(_endDateController),
                    ),
                  ),
                  readOnly: true,
                  validator: (value) =>
                      value!.isEmpty ? 'الرجاء اختيار تاريخ انتهاء الإجازة' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _reasonController,
                  decoration: const InputDecoration(
                    labelText: 'السبب',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  validator: (value) =>
                      value!.isEmpty ? 'الرجاء إدخال سبب الإجازة' : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _status,
                  decoration: const InputDecoration(
                    labelText: 'الحالة',
                    border: OutlineInputBorder(),
                  ),
                  items: <String>['Pending', 'Approved', 'Rejected']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _status = newValue!;
                    });
                  },
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _saveLeave,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  child: const Text('حفظ طلب الإجازة'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

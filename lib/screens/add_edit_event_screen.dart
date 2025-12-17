import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../custom_exception.dart';
import '../event_model.dart';
import '../providers/event_provider.dart'; // Will create this later

class AddEditEventScreen extends StatefulWidget {
  final Event? event;

  const AddEditEventScreen({super.key, this.event});

  @override
  AddEditEventScreenState createState() => AddEditEventScreenState();
}

class AddEditEventScreenState extends State<AddEditEventScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _dateController;
  late TextEditingController _startTimeController;
  late TextEditingController _endTimeController;
  late TextEditingController _locationController;
  late TextEditingController _eventTypeController;
  late TextEditingController _attendeeRolesController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.event?.title ?? '');
    _descriptionController = TextEditingController(text: widget.event?.description ?? '');
    _dateController = TextEditingController(text: widget.event?.date ?? '');
    _startTimeController = TextEditingController(text: widget.event?.startTime ?? '');
    _endTimeController = TextEditingController(text: widget.event?.endTime ?? '');
    _locationController = TextEditingController(text: widget.event?.location ?? '');
    _eventTypeController = TextEditingController(text: widget.event?.eventType ?? '');
    _attendeeRolesController = TextEditingController(text: widget.event?.attendeeRoles ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _dateController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    _locationController.dispose();
    _eventTypeController.dispose();
    _attendeeRolesController.dispose();
    super.dispose();
  }

  Future<void> _saveEvent() async {
    if (_formKey.currentState!.validate()) {
      final event = Event(
        id: widget.event?.id,
        title: _titleController.text,
        description: _descriptionController.text,
        date: _dateController.text,
        startTime: _startTimeController.text,
        endTime: _endTimeController.text,
        location: _locationController.text,
        eventType: _eventTypeController.text,
        attendeeRoles: _attendeeRolesController.text,
      );

      final provider = Provider.of<EventProvider>(context, listen: false);
      final message = widget.event == null
          ? 'تمت إضافة الفعالية بنجاح'
          : 'تم تحديث الفعالية بنجاح';

      try {
        if (widget.event == null) {
          await provider.addEvent(event);
        } else {
          await provider.updateEvent(event);
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
            content: Text('فشل حفظ الفعالية: $e'),
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
      initialDate: DateTime.tryParse(_dateController.text) ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _dateController.text = picked.toIso8601String().split('T').first; // Format YYYY-MM-DD
      });
    }
  }

  // Helper to pick time
  Future<void> _pickTime(TextEditingController controller) async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        controller.text = picked.format(context); // Format HH:MM
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.event == null ? 'إضافة فعالية' : 'تعديل فعالية'),
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
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'عنوان الفعالية',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value!.isEmpty ? 'الرجاء إدخال عنوان الفعالية' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'الوصف',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  validator: (value) =>
                      value!.isEmpty ? 'الرجاء إدخال وصف الفعالية' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _dateController,
                  decoration: InputDecoration(
                    labelText: 'التاريخ',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: _pickDate,
                    ),
                  ),
                  readOnly: true,
                  validator: (value) =>
                      value!.isEmpty ? 'الرجاء اختيار تاريخ الفعالية' : null,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _startTimeController,
                        decoration: InputDecoration(
                          labelText: 'وقت البدء',
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.access_time),
                            onPressed: () => _pickTime(_startTimeController),
                          ),
                        ),
                        readOnly: true,
                        validator: (value) =>
                            value!.isEmpty ? 'الرجاء اختيار وقت البدء' : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _endTimeController,
                        decoration: InputDecoration(
                          labelText: 'وقت الانتهاء',
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.access_time),
                            onPressed: () => _pickTime(_endTimeController),
                          ),
                        ),
                        readOnly: true,
                        validator: (value) =>
                            value!.isEmpty ? 'الرجاء اختيار وقت الانتهاء' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _locationController,
                  decoration: const InputDecoration(
                    labelText: 'الموقع',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value!.isEmpty ? 'الرجاء إدخال موقع الفعالية' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _eventTypeController,
                  decoration: const InputDecoration(
                    labelText: 'نوع الفعالية (مثل اجتماع، رحلة)',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value!.isEmpty ? 'الرجاء إدخال نوع الفعالية' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _attendeeRolesController,
                  decoration: const InputDecoration(
                    labelText: 'أدوار الحضور (مثل الكل، الطلاب، المعلمون)',
                    hintText: 'مفصولة بفواصل، مثال: students,teachers',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value!.isEmpty ? 'الرجاء إدخال أدوار الحضور' : null,
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _saveEvent,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  child: const Text('حفظ الفعالية'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

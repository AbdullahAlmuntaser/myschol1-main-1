import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:developer' as developer; // Added import for logging
import '../event_model.dart';
import '../providers/event_provider.dart';
import 'add_edit_event_screen.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  EventsScreenState createState() => EventsScreenState();
}

class EventsScreenState extends State<EventsScreen> {
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
          await Provider.of<EventProvider>(
            context,
            listen: false,
          ).fetchEvents();
        } finally {
          if (mounted) {
            setState(() {
              _isLoading = false;
            });
          }
        }
      }
    });
    _searchController.addListener(_filterEvents);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterEvents() async {
    setState(() {
      _isLoading = true;
    });
    try {
      await Provider.of<EventProvider>(
        context,
        listen: false,
      ).searchEvents(_searchController.text);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _navigateToAddEditScreen([Event? event]) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddEditEventScreen(event: event),
      ),
    );
  }

  Future<void> _deleteEvent(int id) async {
    final bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: const Text('هل أنت متأكد أنك تريد حذف هذه الفعالية؟'),
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
        await Provider.of<EventProvider>(
          context,
          listen: false,
        ).deleteEvent(id);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم حذف الفعالية بنجاح'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e, s) {
        if (!mounted) return;
        developer.log(
          'فشل حذف الفعالية',
          name: 'events_screen',
          level: 900, // WARNING
          error: e,
          stackTrace: s,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'حدث خطأ غير متوقع أثناء حذف الفعالية. الرجاء المحاولة مرة أخرى.',
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
      appBar: AppBar(title: const Text('إدارة الفعاليات')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'البحث بالعنوان، الوصف، الموقع أو النوع',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12.0)),
                ),
              ),
              onChanged: _isLoading
                  ? null
                  : (value) => _filterEvents(), // Disable when loading
              enabled: !_isLoading, // Disable when loading
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(),
                  ) // Show loading indicator
                : Consumer<EventProvider>(
                    builder: (context, eventProvider, child) {
                      if (eventProvider.events.isEmpty) {
                        return const Center(
                          child: Text('لا توجد فعاليات حالياً.'),
                        );
                      }
                      return ListView.builder(
                        itemCount: eventProvider.events.length,
                        itemBuilder: (context, index) {
                          final event = eventProvider.events[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 12.0,
                              vertical: 6.0,
                            ),
                            child: ListTile(
                              title: Text(event.title),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('الوصف: ${event.description}'),
                                  Text('التاريخ: ${event.date}'),
                                  Text('الوقت: ${event.startTime} - ${event.endTime}'),
                                  Text('الموقع: ${event.location}'),
                                  Text('النوع: ${event.eventType}'),
                                  Text('الحضور: ${event.attendeeRoles}'),
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
                                              _navigateToAddEditScreen(event),
                                    tooltip: 'تعديل',
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: _isLoading
                                        ? null
                                        : () => _deleteEvent(event.id!),
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
        tooltip: 'إضافة فعالية جديدة',
        child: const Icon(Icons.add),
      ),
    );
  }
}

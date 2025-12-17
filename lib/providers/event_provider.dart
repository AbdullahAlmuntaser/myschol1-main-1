import 'package:flutter/material.dart';

import '../database_helper.dart';
import '../event_model.dart';
import '../services/notification_service.dart'; // Import NotificationService

class EventProvider with ChangeNotifier {
  List<Event> _events = [];
  final DatabaseHelper _dbHelper;
  final NotificationService _notificationService; // Add NotificationService

  EventProvider({DatabaseHelper? databaseHelper, NotificationService? notificationService})
      : _dbHelper = databaseHelper ?? DatabaseHelper(),
        _notificationService = notificationService ?? NotificationService();

  List<Event> get events => _events;

  Future<void> fetchEvents() async {
    _events = await _dbHelper.getEvents();
    notifyListeners();
  }

  Future<void> searchEvents(String query) async {
    if (query.isEmpty) {
      await fetchEvents();
    } else {
      _events = await _dbHelper.searchEvents(query);
      notifyListeners();
    }
  }

  Future<void> addEvent(Event event) async {
    final newEventId = await _dbHelper.createEvent(event);
    final newEvent = event.copyWith(id: newEventId);
    await _notificationService.scheduleEventNotification(newEvent);
    await fetchEvents();
  }

  Future<void> updateEvent(Event event) async {
    await _dbHelper.updateEvent(event);
    await _notificationService.scheduleEventNotification(event);
    await fetchEvents();
  }

  Future<void> deleteEvent(int id) async {
    await _dbHelper.deleteEvent(id);
    await _notificationService.cancelEventNotification(id);
    await fetchEvents();
  }

  void clearEvents() {
    _events = [];
    notifyListeners();
  }

  Future<Event?> getEventById(int id) async {
    return await _dbHelper.getEventById(id);
  }
}

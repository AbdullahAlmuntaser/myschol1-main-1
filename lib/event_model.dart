class Event {
  final int? id;
  final String title;
  final String description;
  final String date; // YYYY-MM-DD
  final String startTime; // HH:MM
  final String endTime; // HH:MM
  final String location;
  final String eventType; // e.g., "Meeting", "Trip", "Sports Day", "Activity"
  final String
      attendeeRoles; // Comma-separated roles, e.g., "all", "students", "teachers", "parents"

  Event({
    this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.location,
    required this.eventType,
    required this.attendeeRoles,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'date': date,
      'startTime': startTime,
      'endTime': endTime,
      'location': location,
      'eventType': eventType,
      'attendeeRoles': attendeeRoles,
    };
  }

  factory Event.fromMap(Map<String, dynamic> map) {
    return Event(
      id: map['id'] as int?,
      title: map['title'] as String,
      description: map['description'] as String,
      date: map['date'] as String,
      startTime: map['startTime'] as String,
      endTime: map['endTime'] as String,
      location: map['location'] as String,
      eventType: map['eventType'] as String,
      attendeeRoles: map['attendeeRoles'] as String,
    );
  }

  @override
  String toString() {
    return 'Event{id: $id, title: $title, description: $description, date: $date, startTime: $startTime, endTime: $endTime, location: $location, eventType: $eventType, attendeeRoles: $attendeeRoles}';
  }

  Event copyWith({
    int? id,
    String? title,
    String? description,
    String? date,
    String? startTime,
    String? endTime,
    String? location,
    String? eventType,
    String? attendeeRoles,
  }) {
    return Event(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      location: location ?? this.location,
      eventType: eventType ?? this.eventType,
      attendeeRoles: attendeeRoles ?? this.attendeeRoles,
    );
  }
}

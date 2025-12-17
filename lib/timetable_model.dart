class TimetableEntry {
  int? id;
  int classId;
  int subjectId;
  int teacherId;
  String dayOfWeek; // e.g., 'Sunday', 'Monday'
  int lessonNumber; // e.g., 1, 2, 3
  String startTime; // e.g., '08:00'
  String endTime; // e.g., '08:40'

  TimetableEntry({
    this.id,
    required this.classId,
    required this.subjectId,
    required this.teacherId,
    required this.dayOfWeek,
    required this.lessonNumber,
    required this.startTime,
    required this.endTime,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'classId': classId,
      'subjectId': subjectId,
      'teacherId': teacherId,
      'dayOfWeek': dayOfWeek,
      'lessonNumber': lessonNumber,
      'startTime': startTime,
      'endTime': endTime,
    };
  }

  factory TimetableEntry.fromMap(Map<String, dynamic> map) {
    return TimetableEntry(
      id: map['id'],
      classId: map['classId'],
      subjectId: map['subjectId'],
      teacherId: map['teacherId'],
      dayOfWeek: map['dayOfWeek'],
      lessonNumber: map['lessonNumber'],
      startTime: map['startTime'],
      endTime: map['endTime'],
    );
  }
}

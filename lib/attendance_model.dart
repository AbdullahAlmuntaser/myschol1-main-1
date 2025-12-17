class Attendance {
  int? id;
  int studentId;
  int classId;
  int subjectId; // To link attendance to a specific subject lesson
  int teacherId; // To link attendance to a specific teacher
  String date; // Format: YYYY-MM-DD
  int lessonNumber; // Example: 1, 2, 3 for first, second, third lesson
  String status; // 'present', 'absent', 'late', 'excused'

  Attendance({
    this.id,
    required this.studentId,
    required this.classId,
    required this.subjectId,
    required this.teacherId,
    required this.date,
    required this.lessonNumber,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'studentId': studentId,
      'classId': classId,
      'subjectId': subjectId,
      'teacherId': teacherId,
      'date': date,
      'lessonNumber': lessonNumber,
      'status': status,
    };
  }

  factory Attendance.fromMap(Map<String, dynamic> map) {
    return Attendance(
      id: map['id'],
      studentId: map['studentId'],
      classId: map['classId'],
      subjectId: map['subjectId'],
      teacherId: map['teacherId'],
      date: map['date'],
      lessonNumber: map['lessonNumber'],
      status: map['status'],
    );
  }

  Attendance copyWith({
    int? id,
    int? studentId,
    int? classId,
    int? subjectId,
    int? teacherId,
    String? date,
    int? lessonNumber,
    String? status,
  }) {
    return Attendance(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      classId: classId ?? this.classId,
      subjectId: subjectId ?? this.subjectId,
      teacherId: teacherId ?? this.teacherId,
      date: date ?? this.date,
      lessonNumber: lessonNumber ?? this.lessonNumber,
      status: status ?? this.status,
    );
  }
}

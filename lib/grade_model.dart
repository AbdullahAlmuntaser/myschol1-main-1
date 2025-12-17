class Grade {
  int? id;
  final int studentId;
  final int subjectId;
  final int classId;
  final String assessmentType; // e.g., 'واجب', 'اختبار', 'مشروع'
  final double? semester1Grade;
  final double? semester2Grade;
  final double weight; // Relative weight of the assessment

  Grade({
    this.id,
    required this.studentId,
    required this.subjectId,
    required this.classId,
    required this.assessmentType,
    this.semester1Grade,
    this.semester2Grade,
    required this.weight,
  });

  double get finalGrade {
    double total = (semester1Grade ?? 0.0) + (semester2Grade ?? 0.0);
    int count = 0;
    if (semester1Grade != null) count++;
    if (semester2Grade != null) count++;
    return count > 0 ? total / count : 0.0;
  }

  // Add the missing gradeValue getter
  double get gradeValue => finalGrade;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'studentId': studentId,
      'subjectId': subjectId,
      'classId': classId,
      'assessmentType': assessmentType,
      'semester1Grade': semester1Grade,
      'semester2Grade': semester2Grade,
      'weight': weight,
    };
  }

  static Grade fromMap(Map<String, dynamic> map) {
    return Grade(
      id: map['id'],
      studentId: map['studentId'],
      subjectId: map['subjectId'],
      classId: map['classId'],
      assessmentType: map['assessmentType'],
      semester1Grade: map['semester1Grade'],
      semester2Grade: map['semester2Grade'],
      weight: map['weight'],
    );
  }

  @override
  String toString() {
    return 'Grade{id: $id, studentId: $studentId, subjectId: $subjectId, classId: $classId, assessmentType: $assessmentType, semester1Grade: $semester1Grade, semester2Grade: $semester2Grade, weight: $weight}';
  }
}

// Extension to allow copyWith on Grade model
extension GradeCopyWith on Grade {
  Grade copyWith({
    int? id,
    int? studentId,
    int? subjectId,
    int? classId,
    String? assessmentType,
    double? semester1Grade,
    double? semester2Grade,
    double? weight,
  }) {
    return Grade(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      subjectId: subjectId ?? this.subjectId,
      classId: classId ?? this.classId,
      assessmentType: assessmentType ?? this.assessmentType,
      semester1Grade: semester1Grade ?? this.semester1Grade,
      semester2Grade: semester2Grade ?? this.semester2Grade,
      weight: weight ?? this.weight,
    );
  }
}

class SchoolClass {
  final int? id;
  final String name;
  final String classId; // Unique identifier for the class (e.g., "10A", "Grade5B")
  final int? teacherId; // ID of the responsible teacher
  final int? capacity; // Maximum number of students
  final String? yearTerm; // Academic year or term
  final List<String>?
  subjectIds; // List of subject IDs associated with this class

  SchoolClass({
    this.id,
    required this.name,
    required this.classId,
    this.teacherId,
    this.capacity,
    this.yearTerm,
    this.subjectIds,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'classId': classId,
      'teacherId': teacherId,
      'capacity': capacity,
      'yearTerm': yearTerm,
      'subjectIds': subjectIds?.join(
        ',',
      ), // Convert list to comma-separated string
    };
  }

  factory SchoolClass.fromMap(Map<String, dynamic> map) {
    return SchoolClass(
      id: map['id'] as int?,
      name: map['name'] as String,
      classId: map['classId'] as String,
      teacherId: map['teacherId'] as int?,
      capacity: map['capacity'] as int?,
      yearTerm: map['yearTerm'] as String?,
      subjectIds: map['subjectIds'] != null
          ? (map['subjectIds'] as String)
                .split(',')
                .where((id) => id.isNotEmpty)
                .toList()
          : null,
    );
  }

  @override
  String toString() {
    return 'SchoolClass{id: $id, name: $name, classId: $classId, teacherId: $teacherId, capacity: $capacity, yearTerm: $yearTerm, subjectIds: $subjectIds}';
  }

  SchoolClass copyWith({
    int? id,
    String? name,
    String? classId,
    int? teacherId,
    int? capacity,
    String? yearTerm,
    List<String>? subjectIds,
  }) {
    return SchoolClass(
      id: id ?? this.id,
      name: name ?? this.name,
      classId: classId ?? this.classId,
      teacherId: teacherId ?? this.teacherId,
      capacity: capacity ?? this.capacity,
      yearTerm: yearTerm ?? this.yearTerm,
      subjectIds: subjectIds ?? this.subjectIds,
    );
  }
}

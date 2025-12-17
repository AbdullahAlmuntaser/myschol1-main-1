class AcademicYear {
  int? id;
  final String name;
  final String startDate;
  final String endDate;
  final bool isActive;

  AcademicYear({
    this.id,
    required this.name,
    required this.startDate,
    required this.endDate,
    required this.isActive,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'start_date': startDate,
      'end_date': endDate,
      'is_active': isActive ? 1 : 0,
    };
  }

  static AcademicYear fromMap(Map<String, dynamic> map) {
    return AcademicYear(
      id: map['id'],
      name: map['name'],
      startDate: map['start_date'],
      endDate: map['end_date'],
      isActive: map['is_active'] == 1,
    );
  }

  @override
  String toString() {
    return 'AcademicYear{id: $id, name: $name, startDate: $startDate, endDate: $endDate, isActive: $isActive}';
  }
}

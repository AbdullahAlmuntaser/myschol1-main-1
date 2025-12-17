class Subject {
  final int? id;
  final String name;
  final String subjectId; // Unique identifier for the subject (e.g., "MATH101", "ARAB102")
  final String? description;
  final int? teacherId; // ID of the teacher responsible for this subject
  final String? curriculumDescription; // Detailed description of the curriculum
  final String? learningObjectives; // Comma-separated learning objectives
  final String? recommendedResources; // Comma-separated recommended resources

  Subject({
    this.id,
    required this.name,
    required this.subjectId,
    this.description,
    this.teacherId,
    this.curriculumDescription,
    this.learningObjectives,
    this.recommendedResources,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'subjectId': subjectId,
      'description': description,
      'teacherId': teacherId,
      'curriculumDescription': curriculumDescription,
      'learningObjectives': learningObjectives,
      'recommendedResources': recommendedResources,
    };
  }

  factory Subject.fromMap(Map<String, dynamic> map) {
    return Subject(
      id: map['id'] as int?,
      name: map['name'] as String,
      subjectId: map['subjectId'] as String,
      description: map['description'] as String?,
      teacherId: map['teacherId'] as int?,
      curriculumDescription: map['curriculumDescription'] as String?,
      learningObjectives: map['learningObjectives'] as String?,
      recommendedResources: map['recommendedResources'] as String?,
    );
  }

  @override
  String toString() {
    return 'Subject{id: $id, name: $name, subjectId: $subjectId, description: $description, teacherId: $teacherId, curriculumDescription: $curriculumDescription, learningObjectives: $learningObjectives, recommendedResources: $recommendedResources}';
  }

  Subject copyWith({
    int? id,
    String? name,
    String? subjectId,
    String? description,
    int? teacherId,
    String? curriculumDescription,
    String? learningObjectives,
    String? recommendedResources,
  }) {
    return Subject(
      id: id ?? this.id,
      name: name ?? this.name,
      subjectId: subjectId ?? this.subjectId,
      description: description ?? this.description,
      teacherId: teacherId ?? this.teacherId,
      curriculumDescription: curriculumDescription ?? this.curriculumDescription,
      learningObjectives: learningObjectives ?? this.learningObjectives,
      recommendedResources: recommendedResources ?? this.recommendedResources,
    );
  }
}

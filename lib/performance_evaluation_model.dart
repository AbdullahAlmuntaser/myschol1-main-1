

class PerformanceEvaluation {
  final int? id;
  final int staffId;
  final String evaluationDate; // YYYY-MM-DD
  final int evaluatorUserId; // ID of the user who performed the evaluation
  final String overallRating; // e.g., "Excellent", "Good", "Needs Improvement"
  final String comments;
  final String? areasForImprovement;
  final String? developmentGoals;

  PerformanceEvaluation({
    this.id,
    required this.staffId,
    required this.evaluationDate,
    required this.evaluatorUserId,
    required this.overallRating,
    required this.comments,
    this.areasForImprovement,
    this.developmentGoals,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'staffId': staffId,
      'evaluationDate': evaluationDate,
      'evaluatorUserId': evaluatorUserId,
      'overallRating': overallRating,
      'comments': comments,
      'areasForImprovement': areasForImprovement,
      'developmentGoals': developmentGoals,
    };
  }

  factory PerformanceEvaluation.fromMap(Map<String, dynamic> map) {
    return PerformanceEvaluation(
      id: map['id'] as int?,
      staffId: map['staffId'] as int,
      evaluationDate: map['evaluationDate'] as String,
      evaluatorUserId: map['evaluatorUserId'] as int,
      overallRating: map['overallRating'] as String,
      comments: map['comments'] as String,
      areasForImprovement: map['areasForImprovement'] as String?,
      developmentGoals: map['developmentGoals'] as String?,
    );
  }

  @override
  String toString() {
    return 'PerformanceEvaluation{id: $id, staffId: $staffId, evaluationDate: $evaluationDate, evaluatorUserId: $evaluatorUserId, overallRating: $overallRating, comments: $comments, areasForImprovement: $areasForImprovement, developmentGoals: $developmentGoals}';
  }

  PerformanceEvaluation copyWith({
    int? id,
    int? staffId,
    String? evaluationDate,
    int? evaluatorUserId,
    String? overallRating,
    String? comments,
    String? areasForImprovement,
    String? developmentGoals,
  }) {
    return PerformanceEvaluation(
      id: id ?? this.id,
      staffId: staffId ?? this.staffId,
      evaluationDate: evaluationDate ?? this.evaluationDate,
      evaluatorUserId: evaluatorUserId ?? this.evaluatorUserId,
      overallRating: overallRating ?? this.overallRating,
      comments: comments ?? this.comments,
      areasForImprovement: areasForImprovement ?? this.areasForImprovement,
      developmentGoals: developmentGoals ?? this.developmentGoals,
    );
  }
}

class Permission {
  final int? id;
  final String role;
  final String feature;
  final bool isEnabled;

  Permission({
    this.id,
    required this.role,
    required this.feature,
    required this.isEnabled,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'role': role,
      'feature': feature,
      'is_enabled': isEnabled ? 1 : 0,
    };
  }

  factory Permission.fromMap(Map<String, dynamic> map) {
    return Permission(
      id: map['id'],
      role: map['role'],
      feature: map['feature'],
      isEnabled: map['is_enabled'] == 1,
    );
  }

  @override
  String toString() {
    return 'Permission{id: $id, role: $role, feature: $feature, isEnabled: $isEnabled}';
  }
}

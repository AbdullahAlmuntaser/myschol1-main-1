class Teacher {
  final int? id;
  final String name;
  final String subject;
  final String phone;
  final String? email;
  final String? password;
  final String? qualificationType;
  final String? responsibleClassId;
  final int? userId;

  Teacher({
    this.id,
    required this.name,
    required this.subject,
    required this.phone,
    this.email,
    this.password,
    this.qualificationType,
    this.responsibleClassId,
    this.userId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'subject': subject,
      'phone': phone,
      'email': email,
      'password': password,
      'qualificationType': qualificationType,
      'responsibleClassId': responsibleClassId,
      'userId': userId,
    };
  }

  factory Teacher.fromMap(Map<String, dynamic> map) {
    return Teacher(
      id: map['id'],
      name: map['name'],
      subject: map['subject'],
      phone: map['phone'],
      email: map['email'],
      password: map['password'],
      qualificationType: map['qualificationType'],
      responsibleClassId: map['responsibleClassId'],
      userId: map['userId'],
    );
  }

  @override
  String toString() {
    return 'Teacher{id: $id, name: $name, subject: $subject, phone: $phone, email: $email, qualificationType: $qualificationType, responsibleClassId: $responsibleClassId, userId: $userId}';
  }

  Teacher copyWith({
    int? id,
    String? name,
    String? subject,
    String? phone,
    String? email,
    String? password,
    String? qualificationType,
    String? responsibleClassId,
    int? userId,
  }) {
    return Teacher(
      id: id ?? this.id,
      name: name ?? this.name,
      subject: subject ?? this.subject,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      password: password ?? this.password,
      qualificationType: qualificationType ?? this.qualificationType,
      responsibleClassId: responsibleClassId ?? this.responsibleClassId,
      userId: userId ?? this.userId,
    );
  }
}

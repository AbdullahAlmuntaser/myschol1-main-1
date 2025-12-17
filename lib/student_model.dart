class Student {
  final int? id;
  final String name;
  final String dob;
  final String phone;
  final String grade;
  final String? email;
  final String? password;
  final String? classId;
  final String? academicNumber;
  final String? section;
  final String? parentName;
  final String? parentPhone;
  final String? address;
  final bool status;
  final int? parentUserId;
  final int? userId;

  Student({
    this.id,
    required this.name,
    required this.dob,
    required this.phone,
    required this.grade,
    this.email,
    this.password,
    this.classId,
    this.academicNumber,
    this.section,
    this.parentName,
    this.parentPhone,
    this.address,
    this.status = true,
    this.parentUserId,
    this.userId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'dob': dob,
      'phone': phone,
      'grade': grade,
      'email': email,
      'password': password,
      'classId': classId,
      'academicNumber': academicNumber,
      'section': section,
      'parentName': parentName,
      'parentPhone': parentPhone,
      'address': address,
      'status': status ? 1 : 0,
      'parentUserId': parentUserId,
      'userId': userId,
    };
  }

  factory Student.fromMap(Map<String, dynamic> map) {
    return Student(
      id: map['id'] as int?,
      name: map['name'] as String,
      dob: map['dob'] as String,
      phone: map['phone'] as String,
      grade: map['grade'] as String,
      email: map['email'] as String?,
      password: map['password'] as String?,
      classId: map['classId']?.toString(), // Ensure classId is a string
      academicNumber: map['academicNumber']
          ?.toString(), // Ensure academicNumber is a string
      section: map['section']?.toString(), // Ensure section is a string
      parentName: map['parentName'] as String?,
      parentPhone: map['parentPhone'] as String?,
      address: map['address'] as String?,
      status: (map['status'] as int?) == 1,
      parentUserId: map['parentUserId'] as int?,
      userId: map['userId'] as int?,
    );
  }

  @override
  String toString() {
    return 'Student{id: $id, name: $name, dob: $dob, phone: $phone, grade: $grade, email: $email, classId: $classId, academicNumber: $academicNumber, section: $section, parentName: $parentName, parentPhone: $parentPhone, address: $address, status: $status, parentUserId: $parentUserId, userId: $userId}';
  }

  Student copyWith({
    int? id,
    String? name,
    String? dob,
    String? phone,
    String? grade,
    String? email,
    String? password,
    String? classId,
    String? academicNumber,
    String? section,
    String? parentName,
    String? parentPhone,
    String? address,
    bool? status,
    int? parentUserId,
    int? userId,
  }) {
    return Student(
      id: id ?? this.id,
      name: name ?? this.name,
      dob: dob ?? this.dob,
      phone: phone ?? this.phone,
      grade: grade ?? this.grade,
      email: email ?? this.email,
      password: password ?? this.password,
      classId: classId ?? this.classId,
      academicNumber: academicNumber ?? this.academicNumber,
      section: section ?? this.section,
      parentName: parentName ?? this.parentName,
      parentPhone: parentPhone ?? this.parentPhone,
      address: address ?? this.address,
      status: status ?? this.status,
      parentUserId: parentUserId ?? this.parentUserId,
      userId: userId ?? this.userId,
    );
  }
}

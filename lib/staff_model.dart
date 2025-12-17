class Staff {
  final int? id;
  final String name;
  final String position;
  final String department;
  final String phone;
  final String? email;
  final String? address;
  final String hireDate; // YYYY-MM-DD
  final double salary;
  final int? userId; // Link to the user authentication system

  Staff({
    this.id,
    required this.name,
    required this.position,
    required this.department,
    required this.phone,
    this.email,
    this.address,
    required this.hireDate,
    required this.salary,
    this.userId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'position': position,
      'department': department,
      'phone': phone,
      'email': email,
      'address': address,
      'hireDate': hireDate,
      'salary': salary,
      'userId': userId,
    };
  }

  factory Staff.fromMap(Map<String, dynamic> map) {
    return Staff(
      id: map['id'] as int?,
      name: map['name'] as String,
      position: map['position'] as String,
      department: map['department'] as String,
      phone: map['phone'] as String,
      email: map['email'] as String?,
      address: map['address'] as String?,
      hireDate: map['hireDate'] as String,
      salary: map['salary'] as double,
      userId: map['userId'] as int?,
    );
  }

  @override
  String toString() {
    return 'Staff{id: $id, name: $name, position: $position, department: $department, phone: $phone, email: $email, address: $address, hireDate: $hireDate, salary: $salary, userId: $userId}';
  }

  Staff copyWith({
    int? id,
    String? name,
    String? position,
    String? department,
    String? phone,
    String? email,
    String? address,
    String? hireDate,
    double? salary,
    int? userId,
  }) {
    return Staff(
      id: id ?? this.id,
      name: name ?? this.name,
      position: position ?? this.position,
      department: department ?? this.department,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      hireDate: hireDate ?? this.hireDate,
      salary: salary ?? this.salary,
      userId: userId ?? this.userId,
    );
  }
}

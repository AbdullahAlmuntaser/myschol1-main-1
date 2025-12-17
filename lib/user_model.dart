class User {
  int? id;
  final String username;
  final String passwordHash;
  final String role;
  final String? phone;

  User({
    this.id,
    required this.username,
    required this.passwordHash,
    required this.role,
    this.phone,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'passwordHash': passwordHash,
      'role': role,
      'phone': phone,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      username: map['username'],
      passwordHash: map['passwordHash'],
      role: map['role'],
      phone: map['phone'],
    );
  }

  @override
  String toString() {
    return 'User{id: $id, username: $username, role: $role, phone: $phone}';
  }
}

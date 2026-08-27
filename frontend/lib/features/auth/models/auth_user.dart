class AuthUser {
  const AuthUser({
    required this.id,
    required this.phoneNumber,
    required this.name,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: (json['id'] as num).toInt(),
      phoneNumber: json['phone_number'] as String,
      name: json['name'] as String,
    );
  }

  final int id;
  final String phoneNumber;
  final String name;
}

import 'package:apiland/core/auth/user_role.dart';

export 'package:apiland/core/auth/user_role.dart';

class User {
  const User({
    this.id,
    required this.username,
    required this.lastName,
    required this.email,
    required this.position,
    required this.companyId,
    required this.role,
    this.password, // solo para crear (se envía como "password")
    this.passwordHash, // solo viene del backend (se lee de "passwordHash")
  });

  final String? id; // Guid en el backend → llega como string
  final String username;
  final String lastName;
  final String email;
  final String position;
  final int companyId;
  final UserRole role;

  /// Texto plano, únicamente al crear un usuario. No viene en las respuestas.
  final String? password;

  /// Hash almacenado; llega desde el backend. No se envía nunca.
  final String? passwordHash;

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String?,
      username: (json['username'] ?? '') as String,
      lastName: (json['lastName'] ?? '') as String,
      email: (json['email'] ?? '') as String,
      position: (json['position'] ?? '') as String,
      companyId: json['companyId'] as int,
      passwordHash: json['passwordHash'] as String?,
      role: UserRole.fromWire(json['role'] as String?),
    );
  }

  // Para el POST: mandamos `password` (texto plano), no el id ni el hash.
  Map<String, dynamic> toJson() => {
    'username': username,
    'lastName': lastName,
    'email': email,
    'position': position,
    'companyId': companyId,
    'password': password ?? '',
    'role': role.wire.toLowerCase(),
  };
}

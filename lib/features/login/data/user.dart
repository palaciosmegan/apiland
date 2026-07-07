/// Roles posibles de un usuario. `wire` es el valor tal cual viaja en el JSON
/// (ej. el claim "role" del JWT: "Root", "Admin"…).
enum UserRole {
  root('Root'),
  admin('Admin'),
  user('User');

  const UserRole(this.wire);

  final String wire;

  /// Parsea desde el string del backend, sin importar mayúsculas.
  /// Nunca queda vacío: cualquier valor nulo o no reconocido cae a [user].
  static UserRole fromWire(String? value) {
    if (value == null || value.isEmpty) return UserRole.user;
    return UserRole.values.firstWhere(
      (r) => r.wire.toLowerCase() == value.toLowerCase(),
      orElse: () => UserRole.user,
    );
  }
}

class User {
  const User({
    this.id,
    required this.username,
    required this.lastName,
    required this.email,
    required this.position,
    required this.role,
    this.password, // solo para crear (se envía como "password")
    this.passwordHash, // solo viene del backend (se lee de "passwordHash")
  });

  final String? id; // Guid en el backend → llega como string
  final String username;
  final String lastName;
  final String email;
  final String position;
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
    'password': password ?? '',
    'role': role.wire,
  };
}

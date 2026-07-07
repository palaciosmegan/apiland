/// Roles posibles de un usuario. `wire` es el valor tal cual viaja en el JWT
/// (claim "role": "Root", "Admin"…). `rank` define jerarquía para permisos
/// (mayor = más privilegios).
enum UserRole {
  user('User', 0),
  admin('Admin', 1),
  root('Root', 2);

  const UserRole(this.wire, this.rank);

  final String wire;
  final int rank;

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

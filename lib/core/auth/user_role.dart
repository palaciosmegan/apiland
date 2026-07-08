enum UserRole {
  viewer('viewer', 0),
  editor('editor', 1),
  admin('admin', 2),
  root('root', 3);

  const UserRole(this.wire, this.rank);

  final String wire;
  final int rank;

  /// Parsea desde el string del backend, sin importar mayúsculas.
  /// Nunca queda vacío: cualquier valor nulo o no reconocido cae a [user].
  static UserRole fromWire(String? value) {
    if (value == null || value.isEmpty) return UserRole.viewer;
    return UserRole.values.firstWhere(
      (r) => r.wire.toLowerCase() == value.toLowerCase(),
      orElse: () => UserRole.viewer,
    );
  }
}

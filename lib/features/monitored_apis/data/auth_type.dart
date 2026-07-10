enum AuthType {
  none('None', 0, 'Ninguna'),
  staticBearer('StaticBearer', 1, 'Token fijo'),
  credentialsLogin('CredentialsLogin', 2, 'Credenciales');

  const AuthType(this.wire, this.value, this.label);

  /// Nombre tal cual lo espera el backend (coincide con el enum de C#).
  final String wire;

  /// Valor numérico del enum en el backend.
  final int value;

  /// Etiqueta corta para mostrar en la UI.
  final String label;

  static AuthType fromWire(String? value) {
    if (value == null || value.isEmpty) return AuthType.none;
    return AuthType.values.firstWhere(
      (a) => a.wire.toLowerCase() == value.toLowerCase(),
      orElse: () => AuthType.none,
    );
  }

  /// El backend serializa el enum como int (no como string) — este parser
  /// cubre ambos casos por si algún endpoint cambia de convención.
  static AuthType fromJsonValue(dynamic value) {
    if (value is int) {
      return AuthType.values.firstWhere(
        (a) => a.value == value,
        orElse: () => AuthType.none,
      );
    }
    return fromWire(value as String?);
  }
}

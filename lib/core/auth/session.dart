import 'package:apiland/core/auth/user_role.dart';
import 'package:apiland/core/utils/jwt.dart';

/// Estado de la sesión actual (rol, nombre, email), para mostrar en la UI.
class Session {
  Session._();

  // Claims que emite .NET en el JWT.
  static const String _roleClaim =
      'http://schemas.microsoft.com/ws/2008/06/identity/claims/role';
  static const String _nameClaim =
      'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name';

  static UserRole _role = UserRole.user;
  static String _name = '';
  static String _email = '';

  static UserRole get role => _role;
  static String get name => _name;
  static String get email => _email;

  /// Extrae rol de los claims del token.
  static void setFromToken(String token) {
    final claims = decodeJwtPayload(token);
    _role = UserRole.fromWire(claims[_roleClaim] as String?);
    _name = (claims[_nameClaim] ?? '') as String;
  }

  /// Fallback: el email que se escribió en el login (por si el JWT aún no trae
  /// el claim de email).
  static void setEmail(String email) => _email = email;

  static void clear() {
    _role = UserRole.user;
    _name = '';
    _email = '';
  }
}

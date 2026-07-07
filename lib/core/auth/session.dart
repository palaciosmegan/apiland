import 'package:apiland/core/auth/user_role.dart';
import 'package:apiland/core/utils/jwt.dart';

/// Estado de la sesión actual. Por ahora guarda el rol, derivado del JWT.
class Session {
  Session._();

  // Claim de rol que emite .NET en el JWT.
  static const String _roleClaim =
      'http://schemas.microsoft.com/ws/2008/06/identity/claims/role';

  static UserRole _role = UserRole.user;

  static UserRole get role => _role;

  /// Extrae el rol de los claims del token. Si falla, queda en [UserRole.user].
  static void setFromToken(String token) {
    final claims = decodeJwtPayload(token);
    _role = UserRole.fromWire(claims[_roleClaim] as String?);
  }

  static void clear() => _role = UserRole.user;
}

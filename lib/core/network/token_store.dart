/// Guarda el access token de la sesión, en memoria.
///
/// Transversal (vive en core): el interceptor de Dio lo LEE, y el auth_service
/// lo ESCRIBE tras un login/register exitoso. Así `network` no depende de una
/// feature ni al revés.
///
/// NOTA: es en memoria, se pierde al cerrar la app. Para persistir entre
/// reinicios, luego se cambia por flutter_secure_storage.
class TokenStore {
  TokenStore._();

  static String? _accessToken;

  static String? get accessToken => _accessToken;

  static bool get hasToken => _accessToken != null && _accessToken!.isNotEmpty;

  static void setToken(String token) => _accessToken = token;

  static void clear() => _accessToken = null;
}

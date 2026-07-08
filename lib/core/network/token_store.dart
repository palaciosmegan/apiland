import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Guarda los tokens de sesión: en memoria (para que el interceptor de Dio los
/// lea de forma síncrona) y persistidos en almacenamiento cifrado (sobreviven
/// al reinicio de la app).
class TokenStore {
  TokenStore._();

  static final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static const String _kAccess = 'accessToken';
  static const String _kRefresh = 'refreshToken';
  static const String _kUserId = 'userId';

  static String? _accessToken;
  static String? _refreshToken;
  static String? _userId;

  static String? get accessToken => _accessToken;
  static String? get refreshToken => _refreshToken;
  static String? get userId => _userId;
  static bool get hasToken => _accessToken != null && _accessToken!.isNotEmpty;

  /// Carga los tokens persistidos a memoria. Llamar al arrancar la app.
  static Future<void> load() async {
    _accessToken = await _storage.read(key: _kAccess);
    _refreshToken = await _storage.read(key: _kRefresh);
    _userId = await _storage.read(key: _kUserId);
  }

  /// Guarda (memoria + disco cifrado).
  static Future<void> save({
    required String accessToken,
    required String refreshToken,
    required String userId,
  }) async {
    _accessToken = accessToken;
    _refreshToken = refreshToken;
    _userId = userId;
    await _storage.write(key: _kAccess, value: accessToken);
    await _storage.write(key: _kRefresh, value: refreshToken);
    await _storage.write(key: _kUserId, value: userId);
  }

  static Future<void> clear() async {
    _accessToken = null;
    _refreshToken = null;
    _userId = null;
    await _storage.delete(key: _kAccess);
    await _storage.delete(key: _kRefresh);
    await _storage.delete(key: _kUserId);
  }
}

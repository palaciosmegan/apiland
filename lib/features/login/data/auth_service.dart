import 'package:apiland/core/network/dio_client.dart';
import 'package:apiland/features/login/data/auth_result.dart';
import 'package:apiland/features/login/data/user.dart';
import 'package:dio/dio.dart';

class AuthService {
  AuthService({Dio? dio}) : _dio = dio ?? DioClient.instance;
  static const String _path = '/api/auth';

  final Dio _dio;

  // POST /api/auth/register → registra un usuario y devuelve los tokens.
  // Recibe un [User] (con `password` puesto) y reusa su toJson() para el body.
  Future<AuthResult> register(User user) async {
    final res = await _dio.post('$_path/register', data: user.toJson());
    return AuthResult.fromJson(res.data as Map<String, dynamic>);
  }

  // POST /api/auth/login → login con email + password, devuelve los tokens.
  Future<AuthResult> login(String email, String password) async {
    final res = await _dio.post(
      '$_path/login',
      data: {'email': email, 'password': password},
    );
    return AuthResult.fromJson(res.data as Map<String, dynamic>);
  }

  // POST /api/auth/refresh-token → renueva los tokens con el refresh token.
  Future<AuthResult> refresh({
    required String userId,
    required String refreshToken,
  }) async {
    final res = await _dio.post(
      '$_path/refresh-token',
      data: {'userId': userId, 'refreshToken': refreshToken},
    );
    return AuthResult.fromJson(res.data as Map<String, dynamic>);
  }

  // GET /api/auth/list → lista de usuarios (solo root).
}

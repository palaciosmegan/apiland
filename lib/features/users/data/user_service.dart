import 'package:dio/dio.dart';
import 'package:apiland/core/network/dio_client.dart';
import 'package:apiland/features/login/data/user.dart';

/// Acceso a los endpoints de usuarios.
class UserService {
  UserService({Dio? dio}) : _dio = dio ?? DioClient.instance;

  final Dio _dio;

  static const String _path = '/api/users';

  /// GET /api/users → lista de usuarios.
  Future<List<User>> getUsers() async {
    final res = await _dio.get(_path);
    final data = res.data as List<dynamic>;
    return data
        .map((e) => User.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// POST /api/users → crea un usuario y devuelve el creado.
  /// Endpoint dedicado (protegido a root en el backend), NO el register público.
  /// Usa User.toJson() (username, lastName, email, position, password, role).
  Future<User> createUser(User user) async {
    final res = await _dio.post(_path, data: user.toJson());
    final data = res.data;
    if (data is Map<String, dynamic>) return User.fromJson(data);
    return user;
  }

  /// PUT /api/users → actualiza un usuario existente.
  /// Si `password` viene vacío/null, no se manda (no se toca la contraseña).
  Future<User> updateUser(User user) async {
    final body = {'id': user.id, ...user.toJson()};
    if (user.password == null || user.password!.isEmpty) {
      body.remove('password');
    }
    final res = await _dio.put(_path, data: body);
    final data = res.data;
    if (data is Map<String, dynamic>) return User.fromJson(data);
    return user;
  }
}

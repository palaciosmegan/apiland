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
}

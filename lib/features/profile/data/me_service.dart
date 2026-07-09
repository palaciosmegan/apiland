import 'package:apiland/core/network/dio_client.dart';
import 'package:apiland/features/login/data/user.dart';
import 'package:dio/dio.dart';

typedef MeUpdate = ({String username, String lastName, String position});

class MeService {
  MeService({Dio? dio}) : _dio = dio ?? DioClient.instance;

  final Dio _dio;

  static const String _path = '/api/users/me';

  // GET /api/users/me → trae id, username, lastName, email, role y position.
  Future<User> getMe() async {
    final res = await _dio.get(_path);
    
    return User.fromJson(res.data as Map<String, dynamic>);
  }

  // PUT /api/users/me → solo modifica username, lastName y position.
  Future<User> updateMe(MeUpdate data) async {
    final res = await _dio.put(
      _path,
      data: {
        'username': data.username,
        'lastName': data.lastName,
        'position': data.position,
      },
    );
    return User.fromJson(res.data as Map<String, dynamic>);
  }
}
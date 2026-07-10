import 'package:apiland/core/network/dio_client.dart';
import 'package:apiland/features/monitored_apis/data/api_credentials.dart';
import 'package:apiland/features/monitored_apis/data/auth_type.dart';
import 'package:dio/dio.dart';

class ApiCredentialsService {
  ApiCredentialsService({Dio? dio}) : _dio = dio ?? DioClient.instance;

  final Dio _dio;

  static const String _path = '/api/apicredentials';

  // PUT /api/apicredentials → crea o reemplaza las credenciales de un
  // monitoredApi. Solo root puede llamarlo (lo filtra el backend).
  Future<ApiCredentials> setCredentials({
    required int monitoredApiId,
    required AuthType authType,
    String? bearerToken,
    String? tokenEndpoint,
    String? username,
    String? password,
  }) async {
    final res = await _dio.put(
      _path,
      data: {
        'monitoredApiId': monitoredApiId,
        'authType': authType.value,
        'bearerToken': bearerToken,
        'tokenEndpoint': tokenEndpoint,
        'username': username,
        'password': password,
      },
    );
    return ApiCredentials.fromJson(res.data as Map<String, dynamic>);
  }

  // GET /api/apicredentialss/{monitoredApiId} → null si no tiene credenciales
  // configuradas todavía.
  Future<ApiCredentials?> getByMonitoredApiId(int monitoredApiId) async {
    try {
      final res = await _dio.get('$_path/$monitoredApiId');
      return ApiCredentials.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      rethrow;
    }
  }
}

import 'package:apiland/core/network/dio_client.dart';
import 'package:apiland/features/monitored_apis/data/monitored_api.dart';
import 'package:dio/dio.dart';

class MonitoredApiService {
  MonitoredApiService({Dio? dio}) : _dio = dio ?? DioClient.instance;

  final Dio _dio;

  static const String _path = '/api/monitoredapis';

  // GET /api/monitoredapis → lista de APIs monitoreadas.
  Future<List<MonitoredApi>> getMonitoredApis() async {
    final res = await _dio.get(_path);
    final data = res.data as List<dynamic>;
    return data
        .map((e) => MonitoredApi.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // POST /api/monitored-apis → crea un monitoredApi y devuelve el creado.
  Future<MonitoredApi> createMonitoredApi(MonitoredApi monitoredApi) async {
    final res = await _dio.post(_path, data: monitoredApi.toJson());
    final data = res.data;
    if (data is Map<String, dynamic>) return MonitoredApi.fromJson(data);
    // Si el backend no devuelve cuerpo, regresamos la que enviamos.
    return monitoredApi;
  }
}

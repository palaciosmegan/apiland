import 'package:apiland/features/monitored_apis/data/endpoint.dart';
import 'package:dio/dio.dart';
import 'package:apiland/core/network/dio_client.dart';

class EndpointService {
  EndpointService({Dio? dio}) : _dio = dio ?? DioClient.instance;

  final Dio _dio;

  static const String _path = '/api/monitoredapis';

  /// POST /api/monitoredapis/{id}/endpoints → crea un endpoint.
  Future<Endpoint> createEndpoint(Endpoint newEndpoint) async {
    final res = await _dio.post(
      '$_path/${newEndpoint.parentApiId}/endpoints',
      data: {
        'name': newEndpoint.name,
        'method': newEndpoint.method,
        'url': newEndpoint.url,
        'checkInterval': newEndpoint.checkInterval,
        'isManualOnly': newEndpoint.isManualOnly,
      },
    );
    final data = res.data;
    if (data is Map<String, dynamic>) return Endpoint.fromJson(data);
    return newEndpoint;
  }

  /// PUT /api/monitoredapis/{id}/endpoints → actualiza un endpoint existente.
  /// El id va en el body, no en la ruta (mismo patrón que monitoredapis y
  /// users tras el cambio de convención del backend).
  Future<Endpoint> updateEndpoint(Endpoint endpoint) async {
    final res = await _dio.put(
      '$_path/${endpoint.parentApiId}/endpoints',
      data: {
        'id': endpoint.id,
        'name': endpoint.name,
        'method': endpoint.method,
        'url': endpoint.url,
        'checkInterval': endpoint.checkInterval,
        'isManualOnly': endpoint.isManualOnly,
      },
    );
    final data = res.data;
    if (data is Map<String, dynamic>) return Endpoint.fromJson(data);
    return endpoint;
  }

  /// GET /api/monitoredapis/id/endpoints → todos los endpoints de una api.
  Future<List<Endpoint>> getAllEndpointsFromApi(int monitoredApiId) async {
    final res = await _dio.get('$_path/$monitoredApiId/endpoints');
    final data = res.data as List<dynamic>;
    return data
        .map((e) => Endpoint.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// POST /api/endpoints/{id}/check → chequeo manual, sin body.
  /// Puede devolver 429 si se llama antes de 10s del último check.
  Future<dynamic> checkEndpoint(int endpointId) async {
    final res = await _dio.post('/api/endpoints/$endpointId/check');
    return res.data;
  }
}

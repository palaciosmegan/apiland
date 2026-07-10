import 'package:apiland/features/audit_log/data/audit_log_entry.dart';
import 'package:dio/dio.dart';
import 'package:apiland/core/network/dio_client.dart';

class AuditLogService {
  AuditLogService({Dio? dio}) : _dio = dio ?? DioClient.instance;

  final Dio _dio;

  static const String _path = '/api/auditlogs';

  /// GET /api/auditlogs → todos los audit logs.
  Future<List<AuditLogEntry>> getAuditLogs() async {
    final res = await _dio.get(_path);
    final data = res.data as List<dynamic>;
    return data
        .map((e) => AuditLogEntry.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

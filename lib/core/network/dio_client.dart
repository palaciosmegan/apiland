import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:apiland/core/network/api_constants.dart';

/// Cliente Dio único y ya configurado para toda la app.
class DioClient {
  DioClient._();

  static final Dio instance = _build();

  static Dio _build() {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: ApiConstants.timeout,
        receiveTimeout: ApiConstants.timeout,
        headers: {'Content-Type': 'application/json'},
      ),
    );

    // Inyecta el Bearer token (del .env) en cada request.
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = dotenv.env['API_BEARER_TOKEN'];
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
      ),
    );

    // Logs de red solo en debug (útil para ver requests/responses).
    if (kDebugMode) {
      dio.interceptors.add(
        LogInterceptor(requestBody: true, responseBody: true),
      );

      // SOLO en debug: acepta el certificado autofirmado del dev server .NET
      // (https://10.0.2.2). NUNCA hacer esto en release.
      dio.httpClientAdapter = IOHttpClientAdapter(
        createHttpClient: () {
          final client = HttpClient();
          client.badCertificateCallback = (cert, host, port) => true;
          return client;
        },
      );
    }

    return dio;
  }
}

import 'package:dio/dio.dart';

/// DEBUG: ponlo en `false` (o comenta el early-return de abajo) para ver el
/// error CRUDO en la UI y saber exactamente dónde se rompe algo.
bool _prettifyErrors = true;

/// Mensaje de error para mostrar al usuario.
/// Prioriza SIEMPRE el mensaje que manda el backend (validaciones, mensajes de
/// negocio, etc.). Solo cae a un genérico cuando no hay respuesta útil.
String apiErrorMessage(Object error) {
  if (!_prettifyErrors) return error.toString(); // 👈 comenta para forzar bonito

  if (error is DioException) {
    // Sin respuesta del server → problema de conexión.
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.connectionError:
        return 'No se pudo conectar con el servidor.';
      default:
        break;
    }

    // 1) Lo que mande el backend, si es usable.
    final serverMessage = _serverMessage(error.response?.data);
    if (serverMessage != null) return serverMessage;

    // 2) Fallback por status code.
    final code = error.response?.statusCode;
    if (code == 401) return 'Sesión inválida o expirada.';
    if (code == 403) return 'No tienes permiso para esta acción.';
    if (code == 404) return 'No se encontró el recurso.';
    if (code == 400) return 'Datos inválidos. Revisa los campos.';
    if (code != null && code >= 500) {
      return 'Error del servidor. Intenta más tarde.';
    }
  }
  return 'Algo salió mal. Intenta de nuevo.';
}

/// Extrae un mensaje legible del cuerpo de la respuesta de error.
/// Cubre los shapes más comunes de .NET y APIs REST.
String? _serverMessage(dynamic data) {
  if (data is String) {
    final s = data.trim();
    return s.isEmpty ? null : s;
  }
  if (data is Map) {
    // ValidationProblemDetails: { "errors": { "Campo": ["msg", ...] } }
    final errors = data['errors'];
    if (errors is Map) {
      final messages = errors.values
          .whereType<List>()
          .expand((list) => list)
          .map((m) => m.toString())
          .toList();
      if (messages.isNotEmpty) return messages.join('\n');
    }
    // Otros shapes: { message } / ProblemDetails { detail } / { title }.
    for (final key in ['message', 'detail', 'title']) {
      final v = data[key];
      if (v is String && v.trim().isNotEmpty) return v.trim();
    }
  }
  return null;
}

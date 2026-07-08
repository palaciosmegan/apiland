import 'dart:convert';

/// Decodifica el payload (claims) de un JWT.
///
/// NO valida la firma — eso es responsabilidad del backend. Solo lee los claims
/// para uso en cliente (ej. el rol). Devuelve `{}` si el token es inválido.
Map<String, dynamic> decodeJwtPayload(String token) {
  final parts = token.split('.');
  if (parts.length != 3) return {};
  try {
    // El segmento del medio es base64url (a veces sin padding).
    final normalized = base64Url.normalize(parts[1]);
    final decoded = utf8.decode(base64Url.decode(normalized));
    final map = jsonDecode(decoded);
    return map is Map<String, dynamic> ? map : {};
  } catch (_) {
    return {};
  }
}

DateTime? jwtExpiry(String token) {
  final exp = decodeJwtPayload(token)['exp'];
  if (exp is int) {
    return DateTime.fromMillisecondsSinceEpoch(exp * 1000, isUtc: true);
  }
  return null;
}

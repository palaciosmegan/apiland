/// Respuesta de /api/auth/register y /api/auth/login.
/// Mapea el TokenResponseDto del backend: { userId, accessToken, refreshToken }.
class AuthResult {
  const AuthResult({
    required this.userId,
    required this.accessToken,
    required this.refreshToken,
  });

  final String userId; // Guid → string
  final String accessToken;
  final String refreshToken;

  factory AuthResult.fromJson(Map<String, dynamic> json) {
    return AuthResult(
      userId: (json['userId'] ?? '') as String,
      accessToken: (json['accessToken'] ?? '') as String,
      refreshToken: (json['refreshToken'] ?? '') as String,
    );
  }
}

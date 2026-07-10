import 'package:apiland/features/monitored_apis/data/auth_type.dart';

class ApiCredentials {
  const ApiCredentials({
    this.id,
    required this.monitoredApiId,
    required this.authType,
    this.tokenEndpoint,
    required this.hasBearerToken,
    required this.hasUsername,
    required this.hasPassword,
  });

  final String? id;
  final int monitoredApiId;
  final AuthType authType;
  final String? tokenEndpoint;
  final bool hasBearerToken;
  final bool hasUsername;
  final bool hasPassword;

  factory ApiCredentials.fromJson(Map<String, dynamic> json) {
    return ApiCredentials(
      id: json['id'] as String?,
      monitoredApiId: json['monitoredApiId'] as int,
      authType: AuthType.fromJsonValue(json['authType']),
      tokenEndpoint: json['tokenEndpoint'] as String?,
      hasBearerToken: (json['hasBearerToken'] ?? false) as bool,
      hasUsername: (json['hasUsername'] ?? false) as bool,
      hasPassword: (json['hasPassword'] ?? false) as bool,
    );
  }
}
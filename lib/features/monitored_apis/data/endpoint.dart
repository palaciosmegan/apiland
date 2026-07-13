class Endpoint {
  const Endpoint({
    this.id,
    required this.name,
    required this.method,
    required this.url,
    required this.checkInterval,
    required this.parentApiId,
    required this.isManualOnly,
  });

  final int? id;
  final String name;
  final String method;
  final String url;
  final int checkInterval;
  final int parentApiId;
  final bool isManualOnly;

  factory Endpoint.fromJson(Map<String, dynamic> json) {
    return Endpoint(
      id: json['id'] as int?,
      name: (json['name'] ?? '') as String,
      method: (json['method'] ?? '') as String,
      url: (json['url'] ?? '') as String,
      checkInterval: (json['checkInterval'] ?? 1) as int,
      parentApiId: json['parentApiId'] as int,
      isManualOnly: (json['isManualOnly'] ?? false) as bool,
    );
  }

  // Para el POST no mandamos el id (lo genera el backend).
  Map<String, dynamic> toJson() => {
    'name': name,
    'method': method,
    'url': url,
    'checkInterval': checkInterval,
    'parentApiId': parentApiId,
    'isManualOnly': isManualOnly,
  };
}
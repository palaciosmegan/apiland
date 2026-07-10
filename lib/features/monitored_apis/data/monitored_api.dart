class MonitoredApi {
  const MonitoredApi({
    this.id,
    required this.name,
    required this.description,
    required this.url,
    required this.companyId,
    this.pictureUrl,
    // required this.interval,
  });

  final int? id;
  final String name;
  final String description;
  final String url;
  final int companyId;
  final String? pictureUrl;
  // final String interval;

  factory MonitoredApi.fromJson(Map<String, dynamic> json) {
    return MonitoredApi(
      id: json['id'] as int?,
      description: (json['description'] ?? '') as String,
      name: (json['name'] ?? '') as String,
      url: (json['url'] ?? '') as String,
      companyId: json['companyId'] as int,
      pictureUrl: json['pictureUrl'] as String?,
      // interval: (json['interval'] ?? '') as String,
    );
  }

  // Para el POST no mandamos el id (lo genera el backend).
  Map<String, dynamic> toJson() => {
    'name': name,
    'description': description,
    'url': url,
    'pictureUrl': pictureUrl,
    'companyId': companyId,
    // 'interval': interval,
  };
}
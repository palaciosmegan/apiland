class MonitoredApi {
  const MonitoredApi({
    this.id,
    required this.name,
    required this.url,
    required this.companyId,
    // required this.interval,
  });

  final int? id;
  final String name;
  final String url;
  final int companyId;
  // final String interval;

  factory MonitoredApi.fromJson(Map<String, dynamic> json) {
    return MonitoredApi(
      id: json['id'] as int?,
      name: (json['name'] ?? '') as String,
      url: (json['url'] ?? '') as String,
      companyId: json['companyId'] as int,
      // interval: (json['interval'] ?? '') as String,
    );
  }

  // Para el POST no mandamos el id (lo genera el backend).
  Map<String, dynamic> toJson() => {
    'name': name,
    'url': url,
    'pictureUrl': 'https://www.patasencasa.com/sites/default/files/styles/gallery_crop/public/2024-01/Poodle%20filhote.jpg.webp?itok=70n5Bzqd',
    'companyId': companyId,
    // 'interval': interval,
  };
}
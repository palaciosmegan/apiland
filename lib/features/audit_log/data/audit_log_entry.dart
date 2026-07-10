class AuditLogEntry {
  const AuditLogEntry({
    required this.id,
    required this.timestamp,
    required this.userId,
    required this.username,
    required this.action,
    required this.entityName,
    required this.entityId,
    required this.details,
  });

  final int id;
  final DateTime timestamp;
  final String userId;
  final String username;
  final String action;
  final String entityName;
  final String entityId;
  final String? details;

  factory AuditLogEntry.fromJson(Map<String, dynamic> json) {
    return AuditLogEntry(
      id: json['id'] as int,
      timestamp:
          DateTime.tryParse(json['timestamp'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      userId: (json['userId'] ?? '') as String,
      username: (json['username'] ?? '') as String,
      action: (json['action'] ?? '') as String,
      entityName: (json['entityName'] ?? '') as String,
      entityId: (json['entityId'] ?? '') as String,
      details: (json['details'] ?? '') as String,
    );
  }
}

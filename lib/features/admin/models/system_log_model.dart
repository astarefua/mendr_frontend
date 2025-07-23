class SystemLog {
  final int id;
  final String action;
  final String performedBy;
  final DateTime timestamp;

  SystemLog({
    required this.id,
    required this.action,
    required this.performedBy,
    required this.timestamp,
  });

  factory SystemLog.fromJson(Map<String, dynamic> json) {
    return SystemLog(
      id: json['id'],
      action: json['action'],
      performedBy: json['performedBy'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}

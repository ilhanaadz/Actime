/// Participation model representing a user's participation in an event
/// Maps to backend Participation entity
class Participation {
  final int id;
  final int userId;
  final int eventId;
  final DateTime registeredAt;
  final bool attended;
  final DateTime createdAt;
  final DateTime? lastModifiedAt;

  Participation({
    required this.id,
    required this.userId,
    required this.eventId,
    required this.registeredAt,
    this.attended = false,
    required this.createdAt,
    this.lastModifiedAt,
  });

  factory Participation.fromJson(Map<String, dynamic> json) {
    return Participation(
      id: _parseInt(json['Id'] ?? json['id']) ?? 0,
      userId: _parseInt(json['UserId'] ?? json['userId']) ?? 0,
      eventId: _parseInt(json['EventId'] ?? json['eventId']) ?? 0,
      registeredAt: _parseDateTime(json['RegisteredAt'] ?? json['registeredAt']) ?? DateTime.now(),
      attended: json['Attended'] as bool? ?? json['attended'] as bool? ?? false,
      createdAt: _parseDateTime(json['CreatedAt'] ?? json['createdAt']) ?? DateTime.now(),
      lastModifiedAt: _parseDateTime(json['LastModifiedAt'] ?? json['lastModifiedAt']),
    );
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'Id': id,
      'UserId': userId,
      'EventId': eventId,
      'RegisteredAt': registeredAt.toIso8601String(),
      'Attended': attended,
      'CreatedAt': createdAt.toIso8601String(),
      'LastModifiedAt': lastModifiedAt?.toIso8601String(),
    };
  }

  Participation copyWith({
    int? id,
    int? userId,
    int? eventId,
    DateTime? registeredAt,
    bool? attended,
    DateTime? createdAt,
    DateTime? lastModifiedAt,
  }) {
    return Participation(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      eventId: eventId ?? this.eventId,
      registeredAt: registeredAt ?? this.registeredAt,
      attended: attended ?? this.attended,
      createdAt: createdAt ?? this.createdAt,
      lastModifiedAt: lastModifiedAt ?? this.lastModifiedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Participation && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

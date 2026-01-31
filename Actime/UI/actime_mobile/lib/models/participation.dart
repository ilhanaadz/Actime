/// Participation model
/// Maps to backend Participation entity
class Participation {
  final int id;
  final int userId;
  final int eventId;
  final int attendanceStatusId;
  final int paymentStatusId;
  final int? paymentMethodId;
  final DateTime createdAt;
  final DateTime? lastModifiedAt;

  Participation({
    required this.id,
    required this.userId,
    required this.eventId,
    required this.attendanceStatusId,
    required this.paymentStatusId,
    this.paymentMethodId,
    required this.createdAt,
    this.lastModifiedAt,
  });

  factory Participation.fromJson(Map<String, dynamic> json) {
    return Participation(
      id: _parseInt(json['Id'] ?? json['id']) ?? 0,
      userId: _parseInt(json['UserId'] ?? json['userId']) ?? 0,
      eventId: _parseInt(json['EventId'] ?? json['eventId']) ?? 0,
      attendanceStatusId: _parseInt(json['AttendanceStatusId'] ?? json['attendanceStatusId']) ?? 0,
      paymentStatusId: _parseInt(json['PaymentStatusId'] ?? json['paymentStatusId']) ?? 0,
      paymentMethodId: _parseInt(json['PaymentMethodId'] ?? json['paymentMethodId']),
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
      'AttendanceStatusId': attendanceStatusId,
      'PaymentStatusId': paymentStatusId,
      'PaymentMethodId': paymentMethodId,
      'CreatedAt': createdAt.toIso8601String(),
      'LastModifiedAt': lastModifiedAt?.toIso8601String(),
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Participation && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// Notification model
/// Maps to backend Notification entity
class AppNotification {
  final int id;
  final int userId;
  final String title;
  final String? message;
  final bool isRead;
  final DateTime createdAt;
  final DateTime? readAt;

  AppNotification({
    required this.id,
    required this.userId,
    required this.title,
    this.message,
    this.isRead = false,
    required this.createdAt,
    this.readAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    final String? titleFromJson = json['Title'] as String? ?? json['title'] as String?;
    final String? messageFromJson = json['Message'] as String? ?? json['message'] as String?;

    // If Title is missing, use Message as title
    final String effectiveTitle = titleFromJson?.isNotEmpty == true
        ? titleFromJson!
        : (messageFromJson ?? '');

    return AppNotification(
      id: _parseInt(json['Id'] ?? json['id']) ?? 0,
      userId: _parseInt(json['UserId'] ?? json['userId']) ?? 0,
      title: effectiveTitle,
      message: messageFromJson,
      isRead: json['IsRead'] as bool? ?? json['isRead'] as bool? ?? false,
      createdAt: _parseDateTime(json['CreatedAt'] ?? json['createdAt']) ?? DateTime.now(),
      readAt: _parseDateTime(json['ReadAt'] ?? json['readAt']),
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
      'Title': title,
      'Message': message,
      'IsRead': isRead,
      'CreatedAt': createdAt.toIso8601String(),
      'ReadAt': readAt?.toIso8601String(),
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppNotification && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

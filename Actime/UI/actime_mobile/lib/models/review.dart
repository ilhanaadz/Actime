/// Review model
/// Maps to backend Review entity
class Review {
  final int id;
  final int userId;
  final int organizationId;
  final int rating;
  final String? comment;
  final DateTime createdAt;
  final DateTime? lastModifiedAt;

  Review({
    required this.id,
    required this.userId,
    required this.organizationId,
    required this.rating,
    this.comment,
    required this.createdAt,
    this.lastModifiedAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: _parseInt(json['Id'] ?? json['id']) ?? 0,
      userId: _parseInt(json['UserId'] ?? json['userId']) ?? 0,
      organizationId: _parseInt(json['OrganizationId'] ?? json['organizationId']) ?? 0,
      rating: _parseInt(json['Rating'] ?? json['rating']) ?? 0,
      comment: json['Comment'] as String? ?? json['comment'] as String?,
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
      'OrganizationId': organizationId,
      'Rating': rating,
      'Comment': comment,
      'CreatedAt': createdAt.toIso8601String(),
      'LastModifiedAt': lastModifiedAt?.toIso8601String(),
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Review && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

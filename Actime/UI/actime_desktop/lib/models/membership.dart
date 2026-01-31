/// Membership model representing a user's membership in an organization
/// Maps to backend Membership entity
class Membership {
  final int id;
  final int userId;
  final int organizationId;
  final DateTime joinedAt;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? lastModifiedAt;

  Membership({
    required this.id,
    required this.userId,
    required this.organizationId,
    required this.joinedAt,
    this.isActive = true,
    required this.createdAt,
    this.lastModifiedAt,
  });

  factory Membership.fromJson(Map<String, dynamic> json) {
    return Membership(
      id: _parseInt(json['Id'] ?? json['id']) ?? 0,
      userId: _parseInt(json['UserId'] ?? json['userId']) ?? 0,
      organizationId: _parseInt(json['OrganizationId'] ?? json['organizationId']) ?? 0,
      joinedAt: _parseDateTime(json['JoinedAt'] ?? json['joinedAt']) ?? DateTime.now(),
      isActive: json['IsActive'] as bool? ?? json['isActive'] as bool? ?? true,
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
      'JoinedAt': joinedAt.toIso8601String(),
      'IsActive': isActive,
      'CreatedAt': createdAt.toIso8601String(),
      'LastModifiedAt': lastModifiedAt?.toIso8601String(),
    };
  }

  Membership copyWith({
    int? id,
    int? userId,
    int? organizationId,
    DateTime? joinedAt,
    bool? isActive,
    DateTime? createdAt,
    DateTime? lastModifiedAt,
  }) {
    return Membership(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      organizationId: organizationId ?? this.organizationId,
      joinedAt: joinedAt ?? this.joinedAt,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      lastModifiedAt: lastModifiedAt ?? this.lastModifiedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Membership && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

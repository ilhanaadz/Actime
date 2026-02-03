import 'user.dart';
import 'organization.dart';

/// Membership model
/// Maps to backend Membership entity
class Membership {
  final int id;
  final int userId;
  final int organizationId;
  final int membershipStatusId;
  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime createdAt;
  final DateTime? lastModifiedAt;
  final User? user;
  final Organization? organization;

  Membership({
    required this.id,
    required this.userId,
    required this.organizationId,
    required this.membershipStatusId,
    this.startDate,
    this.endDate,
    required this.createdAt,
    this.lastModifiedAt,
    this.user,
    this.organization,
  });

  factory Membership.fromJson(Map<String, dynamic> json) {
    return Membership(
      id: _parseInt(json['Id'] ?? json['id']) ?? 0,
      userId: _parseInt(json['UserId'] ?? json['userId']) ?? 0,
      organizationId: _parseInt(json['OrganizationId'] ?? json['organizationId']) ?? 0,
      membershipStatusId: _parseInt(json['MembershipStatusId'] ?? json['membershipStatusId']) ?? 0,
      startDate: _parseDateTime(json['StartDate'] ?? json['startDate']),
      endDate: _parseDateTime(json['EndDate'] ?? json['endDate']),
      createdAt: _parseDateTime(json['CreatedAt'] ?? json['createdAt']) ?? DateTime.now(),
      lastModifiedAt: _parseDateTime(json['LastModifiedAt'] ?? json['lastModifiedAt']),
      user: json['User'] != null
          ? User.fromJson(json['User'] as Map<String, dynamic>)
          : json['user'] != null
              ? User.fromJson(json['user'] as Map<String, dynamic>)
              : null,
      organization: json['Organization'] != null
          ? Organization.fromJson(json['Organization'] as Map<String, dynamic>)
          : json['organization'] != null
              ? Organization.fromJson(json['organization'] as Map<String, dynamic>)
              : null,
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
      'MembershipStatusId': membershipStatusId,
      'StartDate': startDate?.toIso8601String(),
      'EndDate': endDate?.toIso8601String(),
      'CreatedAt': createdAt.toIso8601String(),
      'LastModifiedAt': lastModifiedAt?.toIso8601String(),
      'User': user?.toJson(),
      'Organization': organization?.toJson(),
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Membership && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

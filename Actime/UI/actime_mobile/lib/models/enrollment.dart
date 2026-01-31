import 'user.dart';
import 'organization.dart';

/// Enrollment application for joining an organization
class Enrollment {
  final String id;
  final String userId;
  final String organizationId;
  final User? user;
  final Organization? organization;
  final String? message;
  final EnrollmentStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? reviewedAt;
  final String? reviewedBy;
  final String? rejectionReason;

  Enrollment({
    required this.id,
    required this.userId,
    required this.organizationId,
    this.user,
    this.organization,
    this.message,
    this.status = EnrollmentStatus.pending,
    required this.createdAt,
    this.updatedAt,
    this.reviewedAt,
    this.reviewedBy,
    this.rejectionReason,
  });

  factory Enrollment.fromJson(Map<String, dynamic> json) {
    return Enrollment(
      id: (json['Id'] ?? json['id'])?.toString() ?? '0',
      userId: (json['UserId'] ?? json['userId'])?.toString() ?? '0',
      organizationId: (json['OrganizationId'] ?? json['organizationId'])?.toString() ?? '0',
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
      message: json['Message'] as String? ?? json['message'] as String?,
      status: EnrollmentStatus.fromString(json['Status'] as String? ?? json['status'] as String? ?? 'pending'),
      createdAt: _parseDateTime(json['CreatedAt'] ?? json['createdAt']) ?? DateTime.now(),
      updatedAt: _parseDateTime(json['UpdatedAt'] ?? json['updatedAt']),
      reviewedAt: _parseDateTime(json['ReviewedAt'] ?? json['reviewedAt']),
      reviewedBy: json['ReviewedBy'] as String? ?? json['reviewedBy'] as String?,
      rejectionReason: json['RejectionReason'] as String? ?? json['rejectionReason'] as String?,
    );
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
      'User': user?.toJson(),
      'Organization': organization?.toJson(),
      'Message': message,
      'Status': status.value,
      'CreatedAt': createdAt.toIso8601String(),
      'UpdatedAt': updatedAt?.toIso8601String(),
      'ReviewedAt': reviewedAt?.toIso8601String(),
      'ReviewedBy': reviewedBy,
      'RejectionReason': rejectionReason,
    };
  }

  Enrollment copyWith({
    String? id,
    String? userId,
    String? organizationId,
    User? user,
    Organization? organization,
    String? message,
    EnrollmentStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? reviewedAt,
    String? reviewedBy,
    String? rejectionReason,
  }) {
    return Enrollment(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      organizationId: organizationId ?? this.organizationId,
      user: user ?? this.user,
      organization: organization ?? this.organization,
      message: message ?? this.message,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      reviewedBy: reviewedBy ?? this.reviewedBy,
      rejectionReason: rejectionReason ?? this.rejectionReason,
    );
  }
}

/// Enrollment status
enum EnrollmentStatus {
  pending('pending'),
  approved('approved'),
  rejected('rejected'),
  cancelled('cancelled');

  final String value;
  const EnrollmentStatus(this.value);

  static EnrollmentStatus fromString(String value) {
    return EnrollmentStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => EnrollmentStatus.pending,
    );
  }

  String get displayName {
    switch (this) {
      case EnrollmentStatus.pending:
        return 'Na čekanju';
      case EnrollmentStatus.approved:
        return 'Odobren';
      case EnrollmentStatus.rejected:
        return 'Odbijen';
      case EnrollmentStatus.cancelled:
        return 'Otkazan';
    }
  }
}

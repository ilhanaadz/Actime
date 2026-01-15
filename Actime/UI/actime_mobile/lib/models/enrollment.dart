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
      id: json['id'] as String,
      userId: json['userId'] as String,
      organizationId: json['organizationId'] as String,
      user: json['user'] != null
          ? User.fromJson(json['user'] as Map<String, dynamic>)
          : null,
      organization: json['organization'] != null
          ? Organization.fromJson(json['organization'] as Map<String, dynamic>)
          : null,
      message: json['message'] as String?,
      status: EnrollmentStatus.fromString(json['status'] as String? ?? 'pending'),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      reviewedAt: json['reviewedAt'] != null
          ? DateTime.parse(json['reviewedAt'] as String)
          : null,
      reviewedBy: json['reviewedBy'] as String?,
      rejectionReason: json['rejectionReason'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'organizationId': organizationId,
      'user': user?.toJson(),
      'organization': organization?.toJson(),
      'message': message,
      'status': status.value,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'reviewedAt': reviewedAt?.toIso8601String(),
      'reviewedBy': reviewedBy,
      'rejectionReason': rejectionReason,
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

import '../config/api_config.dart';
import '../models/models.dart';
import 'api_service.dart';
import 'auth_service.dart';

/// Enrollment service for managing club membership applications
/// Uses /Membership endpoint on backend
class EnrollmentService {
  static final EnrollmentService _instance = EnrollmentService._internal();
  factory EnrollmentService() => _instance;
  EnrollmentService._internal();

  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();

  // MembershipStatus IDs from backend
  static const int statusPending = 1;
  static const int statusActive = 2;
  static const int statusSuspended = 3;
  static const int statusCancelled = 4;
  static const int statusExpired = 5;
  static const int statusRejected = 6;

  /// Create enrollment (apply to join organization)
  /// Calls POST /Membership with MembershipStatusId = 1 (Pending)
  Future<ApiResponse<Membership>> createEnrollment({
    required String organizationId,
    String? message,
  }) async {
    final userId = _authService.currentUserId;
    if (userId == null) {
      return ApiResponse.error('Morate biti prijavljeni');
    }

    return await _apiService.post<Membership>(
      ApiConfig.membership,
      body: {
        'UserId': userId,
        'OrganizationId': int.tryParse(organizationId) ?? 0,
        'MembershipStatusId': statusPending,
        'StartDate': DateTime.now().toIso8601String(),
      },
      fromJson: (json) => Membership.fromJson(json),
    );
  }

  /// Cancel enrollment (delete membership)
  Future<ApiResponse<void>> cancelEnrollment(String id) async {
    return await _apiService.delete('${ApiConfig.membership}/$id');
  }

  /// Get user's enrollments (memberships)
  Future<ApiResponse<PaginatedResponse<Membership>>> getUserEnrollments({
    int page = 1,
    int pageSize = 10,
    EnrollmentStatus? status,
  }) async {
    final userId = _authService.currentUserId;
    if (userId == null) {
      return ApiResponse.error('Morate biti prijavljeni');
    }

    // Map EnrollmentStatus to MembershipStatusId
    int? membershipStatusId;
    if (status != null) {
      membershipStatusId = _mapEnrollmentStatusToMembershipStatusId(status);
    }

    return await _apiService.get<PaginatedResponse<Membership>>(
      ApiConfig.membership,
      queryParams: {
        'Page': page.toString(),
        'PageSize': pageSize.toString(),
        'UserId': userId.toString(),
        if (membershipStatusId != null) 'MembershipStatusId': membershipStatusId.toString(),
      },
      fromJson: (json) => PaginatedResponse.fromJson(json, Membership.fromJson),
    );
  }

  /// Map EnrollmentStatus to MembershipStatusId
  int _mapEnrollmentStatusToMembershipStatusId(EnrollmentStatus status) {
    switch (status) {
      case EnrollmentStatus.pending:
        return statusPending;
      case EnrollmentStatus.approved:
        return statusActive;
      case EnrollmentStatus.rejected:
        return statusRejected;
      case EnrollmentStatus.cancelled:
        return statusCancelled;
    }
  }

  /// Map MembershipStatusId to EnrollmentStatus
  static EnrollmentStatus mapMembershipStatusIdToEnrollmentStatus(int statusId) {
    switch (statusId) {
      case statusPending:
        return EnrollmentStatus.pending;
      case statusActive:
        return EnrollmentStatus.approved;
      case statusRejected:
        return EnrollmentStatus.rejected;
      case statusCancelled:
        return EnrollmentStatus.cancelled;
      default:
        return EnrollmentStatus.pending;
    }
  }
}

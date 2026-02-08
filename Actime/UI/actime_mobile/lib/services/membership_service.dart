import '../config/api_config.dart';
import '../models/api_response.dart';
import '../models/paginated_response.dart';
import '../models/membership.dart';
import 'api_service.dart';

/// Membership service
/// Communicates with backend MembershipController
class MembershipService {
  static final MembershipService _instance = MembershipService._internal();
  factory MembershipService() => _instance;
  MembershipService._internal();

  final ApiService _apiService = ApiService();

  /// Get memberships (paginated)
  Future<ApiResponse<PaginatedResponse<Membership>>> getMemberships({
    int? userId,
    int page = 1,
    int pageSize = 10,
    bool includeTotalCount = true,
  }) async {
    return await _apiService.get<PaginatedResponse<Membership>>(
      ApiConfig.membership,
      queryParams: {
        if (userId != null) 'UserId': userId.toString(),
        'Page': page.toString(),
        'PageSize': pageSize.toString(),
        'IncludeTotalCount': includeTotalCount.toString(),
      },
      fromJson: (json) => PaginatedResponse.fromJson(json, Membership.fromJson),
    );
  }

  /// Get membership by ID
  Future<ApiResponse<Membership>> getMembershipById(int id) async {
    return await _apiService.get<Membership>(
      ApiConfig.membershipById(id),
      fromJson: (json) => Membership.fromJson(json),
    );
  }

  /// Create membership
  Future<ApiResponse<Membership>> createMembership({
    required int userId,
    required int organizationId,
    required int membershipStatusId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return await _apiService.post<Membership>(
      ApiConfig.membership,
      body: {
        'UserId': userId,
        'OrganizationId': organizationId,
        'MembershipStatusId': membershipStatusId,
        if (startDate != null) 'StartDate': startDate.toIso8601String(),
        if (endDate != null) 'EndDate': endDate.toIso8601String(),
      },
      fromJson: (json) => Membership.fromJson(json),
    );
  }

  /// Update membership
  Future<ApiResponse<Membership>> updateMembership(
    int id, {
    int? membershipStatusId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return await _apiService.put<Membership>(
      ApiConfig.membershipById(id),
      body: {
        if (membershipStatusId != null) 'MembershipStatusId': membershipStatusId,
        if (startDate != null) 'StartDate': startDate.toIso8601String(),
        if (endDate != null) 'EndDate': endDate.toIso8601String(),
      },
      fromJson: (json) => Membership.fromJson(json),
    );
  }

  /// Delete membership
  Future<ApiResponse<void>> deleteMembership(int id) async {
    return await _apiService.delete(ApiConfig.membershipById(id));
  }
}

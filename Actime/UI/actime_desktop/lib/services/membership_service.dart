import '../config/api_config.dart';
import '../models/models.dart';
import 'api_service.dart';

class MembershipService {
  static final MembershipService _instance = MembershipService._internal();
  factory MembershipService() => _instance;
  MembershipService._internal();

  final ApiService _apiService = ApiService();

  Future<ApiResponse<PaginatedResponse<Membership>>> getMemberships({
    int page = 1,
    int pageSize = 10,
    int? userId,
    int? organizationId,
  }) async {
    final queryParams = <String, String>{
      'Page': page.toString(),
      'PageSize': pageSize.toString(),
    };

    if (userId != null) {
      queryParams['UserId'] = userId.toString();
    }
    if (organizationId != null) {
      queryParams['OrganizationId'] = organizationId.toString();
    }

    return await _apiService.get<PaginatedResponse<Membership>>(
      ApiConfig.membership,
      queryParams: queryParams,
      fromJson: (json) => PaginatedResponse.fromJson(json, Membership.fromJson),
    );
  }

  Future<ApiResponse<Membership>> getMembershipById(int id) async {
    return await _apiService.get<Membership>(
      ApiConfig.membershipById(id),
      fromJson: (json) => Membership.fromJson(json),
    );
  }

  Future<ApiResponse<Membership>> createMembership({
    required int userId,
    required int organizationId,
  }) async {
    return await _apiService.post<Membership>(
      ApiConfig.membership,
      body: {
        'UserId': userId,
        'OrganizationId': organizationId,
      },
      fromJson: (json) => Membership.fromJson(json),
    );
  }

  Future<ApiResponse<Membership>> updateMembership({
    required int id,
    bool? isActive,
  }) async {
    final body = <String, dynamic>{};
    if (isActive != null) body['IsActive'] = isActive;

    return await _apiService.put<Membership>(
      ApiConfig.membershipById(id),
      body: body,
      fromJson: (json) => Membership.fromJson(json),
    );
  }

  Future<ApiResponse<void>> deleteMembership(int id) async {
    return await _apiService.delete<void>(
      ApiConfig.membershipById(id),
    );
  }
}

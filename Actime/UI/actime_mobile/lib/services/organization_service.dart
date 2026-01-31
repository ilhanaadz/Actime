import '../config/api_config.dart';
import '../models/models.dart';
import 'api_service.dart';
import 'mock_api_service.dart';

/// Organization (club) service
/// Communicates with backend OrganizationController
class OrganizationService {
  static final OrganizationService _instance = OrganizationService._internal();
  factory OrganizationService() => _instance;
  OrganizationService._internal();

  final ApiService _apiService = ApiService();
  final MockApiService _mockService = MockApiService();

  /// Get organizations (paginated)
  /// Backend uses TextSearchObject for filtering
  Future<ApiResponse<PaginatedResponse<Organization>>> getOrganizations({
    int page = 1,
    int pageSize = 10,
    int? perPage,
    String? text,
    String? search,
    String? sortBy,
    bool sortDescending = false,
    bool includeTotalCount = true,
  }) async {
    final effectivePageSize = perPage ?? pageSize;
    final effectiveSearch = search ?? text;

    if (ApiConfig.useMockApi) {
      return await _mockService.getOrganizations(
        page: page,
        perPage: effectivePageSize,
        search: effectiveSearch,
        sortBy: sortBy,
      );
    }

    return await _apiService.get<PaginatedResponse<Organization>>(
      ApiConfig.organization,
      queryParams: {
        'Page': page.toString(),
        'PageSize': effectivePageSize.toString(),
        'IncludeTotalCount': includeTotalCount.toString(),
        if (effectiveSearch != null && effectiveSearch.isNotEmpty) 'Text': effectiveSearch,
        if (sortBy != null) 'SortBy': sortBy,
        'SortDescending': sortDescending.toString(),
      },
      fromJson: (json) => PaginatedResponse.fromJson(json, Organization.fromJson),
    );
  }

  /// Get organization by ID
  Future<ApiResponse<Organization>> getOrganizationById(String id) async {
    if (ApiConfig.useMockApi) {
      return await _mockService.getOrganizationById(id);
    }

    return await _apiService.get<Organization>(
      '${ApiConfig.organization}/$id',
      fromJson: (json) => Organization.fromJson(json),
    );
  }

  /// Update my organization (for organization role)
  Future<ApiResponse<Organization>> updateMyOrganization(Map<String, dynamic> data) async {
    if (ApiConfig.useMockApi) {
      return await _mockService.updateOrganization('1', data);
    }

    return await _apiService.put<Organization>(
      ApiConfig.organizationMy(),
      body: data,
      fromJson: (json) => Organization.fromJson(json),
    );
  }

  /// Update organization by ID (admin only)
  Future<ApiResponse<Organization>> updateOrganization(
    String id,
    Map<String, dynamic> data,
  ) async {
    if (ApiConfig.useMockApi) {
      return await _mockService.updateOrganization(id, data);
    }

    return await _apiService.put<Organization>(
      '${ApiConfig.organization}/$id',
      body: data,
      fromJson: (json) => Organization.fromJson(json),
    );
  }

  /// Delete organization by ID (admin only)
  Future<ApiResponse<void>> deleteOrganization(String id) async {
    if (ApiConfig.useMockApi) {
      return ApiResponse.success(null, message: 'Organizacija je uspješno obrisana');
    }

    return await _apiService.delete('${ApiConfig.organization}/$id');
  }

  /// Delete my organization (for organization role)
  Future<ApiResponse<void>> deleteMyOrganization() async {
    if (ApiConfig.useMockApi) {
      return ApiResponse.success(null, message: 'Organizacija je uspješno obrisana');
    }

    return await _apiService.delete(ApiConfig.organizationMy());
  }

  /// Get organization enrollments (applications to join)
  Future<ApiResponse<PaginatedResponse<Enrollment>>> getOrganizationEnrollments(
    String organizationId, {
    int page = 1,
    int perPage = 10,
    EnrollmentStatus? status,
  }) async {
    if (ApiConfig.useMockApi) {
      return await _mockService.getOrganizationEnrollments(
        organizationId,
        page: page,
        perPage: perPage,
        status: status,
      );
    }

    return await _apiService.get<PaginatedResponse<Enrollment>>(
      '${ApiConfig.organization}/$organizationId/enrollments',
      queryParams: {
        'page': page.toString(),
        'perPage': perPage.toString(),
        if (status != null) 'status': status.value,
      },
      fromJson: (json) => PaginatedResponse.fromJson(json, Enrollment.fromJson),
    );
  }

  /// Approve enrollment
  Future<ApiResponse<Enrollment>> approveEnrollment(String enrollmentId) async {
    if (ApiConfig.useMockApi) {
      return await _mockService.approveEnrollment(enrollmentId);
    }

    return await _apiService.post<Enrollment>(
      '${ApiConfig.enrollments}/$enrollmentId/approve',
      fromJson: (json) => Enrollment.fromJson(json),
    );
  }

  /// Reject enrollment
  Future<ApiResponse<Enrollment>> rejectEnrollment(String enrollmentId, {String? reason}) async {
    if (ApiConfig.useMockApi) {
      return await _mockService.rejectEnrollment(enrollmentId, reason: reason);
    }

    return await _apiService.post<Enrollment>(
      '${ApiConfig.enrollments}/$enrollmentId/reject',
      body: reason != null ? {'Reason': reason} : null,
      fromJson: (json) => Enrollment.fromJson(json),
    );
  }

  /// Get organization participations summary
  Future<ApiResponse<PaginatedResponse<EventParticipation>>> getOrganizationParticipations(
    String organizationId, {
    int page = 1,
    int perPage = 10,
  }) async {
    if (ApiConfig.useMockApi) {
      return await _mockService.getOrganizationParticipations(
        organizationId,
        page: page,
        perPage: perPage,
      );
    }

    return await _apiService.get<PaginatedResponse<EventParticipation>>(
      '${ApiConfig.organization}/$organizationId/participations',
      queryParams: {
        'page': page.toString(),
        'perPage': perPage.toString(),
      },
      fromJson: (json) => PaginatedResponse.fromJson(json, EventParticipation.fromJson),
    );
  }
}

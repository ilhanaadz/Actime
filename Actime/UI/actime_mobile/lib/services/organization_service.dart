import '../config/api_config.dart';
import '../models/models.dart';
import 'api_service.dart';
import 'mock_api_service.dart';

/// Organization (club) service
class OrganizationService {
  static final OrganizationService _instance = OrganizationService._internal();
  factory OrganizationService() => _instance;
  OrganizationService._internal();

  final ApiService _apiService = ApiService();
  final MockApiService _mockService = MockApiService();

  /// Get organizations (paginated)
  Future<ApiResponse<PaginatedResponse<Organization>>> getOrganizations({
    int page = 1,
    int perPage = 10,
    String? search,
    String? categoryId,
    String? sortBy,
  }) async {
    if (ApiConfig.useMockApi) {
      return await _mockService.getOrganizations(
        page: page,
        perPage: perPage,
        search: search,
        categoryId: categoryId,
        sortBy: sortBy,
      );
    }

    return await _apiService.get<PaginatedResponse<Organization>>(
      ApiConfig.organizations,
      queryParams: {
        'page': page.toString(),
        'perPage': perPage.toString(),
        if (search != null) 'search': search,
        if (categoryId != null) 'categoryId': categoryId,
        if (sortBy != null) 'sortBy': sortBy,
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
      ApiConfig.organizationById(id),
      fromJson: (json) => Organization.fromJson(json),
    );
  }

  /// Get organization members
  Future<ApiResponse<PaginatedResponse<User>>> getOrganizationMembers(
    String organizationId, {
    int page = 1,
    int perPage = 10,
  }) async {
    if (ApiConfig.useMockApi) {
      return await _mockService.getOrganizationMembers(
        organizationId,
        page: page,
        perPage: perPage,
      );
    }

    return await _apiService.get<PaginatedResponse<User>>(
      ApiConfig.organizationMembers(organizationId),
      queryParams: {
        'page': page.toString(),
        'perPage': perPage.toString(),
      },
      fromJson: (json) => PaginatedResponse.fromJson(json, User.fromJson),
    );
  }

  /// Create organization
  Future<ApiResponse<Organization>> createOrganization(Map<String, dynamic> data) async {
    if (ApiConfig.useMockApi) {
      return await _mockService.createOrganization(data);
    }

    return await _apiService.post<Organization>(
      ApiConfig.organizations,
      body: data,
      fromJson: (json) => Organization.fromJson(json),
    );
  }

  /// Update organization
  Future<ApiResponse<Organization>> updateOrganization(
    String id,
    Map<String, dynamic> data,
  ) async {
    if (ApiConfig.useMockApi) {
      return await _mockService.updateOrganization(id, data);
    }

    return await _apiService.put<Organization>(
      ApiConfig.organizationById(id),
      body: data,
      fromJson: (json) => Organization.fromJson(json),
    );
  }

  /// Delete organization
  Future<ApiResponse<void>> deleteOrganization(String id) async {
    if (ApiConfig.useMockApi) {
      return ApiResponse.success(null, message: 'Organizacija je uspješno obrisana');
    }

    return await _apiService.delete(ApiConfig.organizationById(id));
  }

  /// Get organization event participations (events with participant counts)
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
      ApiConfig.organizationParticipations(organizationId),
      queryParams: {
        'page': page.toString(),
        'perPage': perPage.toString(),
      },
      fromJson: (json) => PaginatedResponse.fromJson(json, EventParticipation.fromJson),
    );
  }

  /// Get organization enrollments
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
      ApiConfig.organizationEnrollments(organizationId),
      queryParams: {
        'page': page.toString(),
        'perPage': perPage.toString(),
        if (status != null) 'status': status.value,
      },
      fromJson: (json) => PaginatedResponse.fromJson(json, Enrollment.fromJson),
    );
  }

  /// Approve enrollment
  Future<ApiResponse<Enrollment>> approveEnrollment(String id) async {
    if (ApiConfig.useMockApi) {
      return await _mockService.approveEnrollment(id);
    }

    return await _apiService.post<Enrollment>(
      '${ApiConfig.enrollments}/$id/approve',
      fromJson: (json) => Enrollment.fromJson(json),
    );
  }

  /// Reject enrollment
  Future<ApiResponse<Enrollment>> rejectEnrollment(String id, {String? reason}) async {
    if (ApiConfig.useMockApi) {
      return await _mockService.rejectEnrollment(id, reason: reason);
    }

    return await _apiService.post<Enrollment>(
      '${ApiConfig.enrollments}/$id/reject',
      body: reason != null ? {'reason': reason} : null,
      fromJson: (json) => Enrollment.fromJson(json),
    );
  }
}

import '../config/api_config.dart';
import '../models/models.dart';
import 'api_service.dart';
import 'enrollment_service.dart';
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

    if (data.containsKey('LogoUrl')) {
      final path = data['LogoUrl'] as String?;
      if (path != null && !path.startsWith(RegExp(r'https?:\/\/'))) {
        data['LogoUrl'] = '${ApiConfig.baseUrl}$path';
      }
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

  /// Get organization enrollments (memberships/applications to join)
  /// Uses /Membership endpoint with OrganizationId filter
  Future<ApiResponse<PaginatedResponse<Membership>>> getOrganizationEnrollments(
    String organizationId, {
    int page = 1,
    int pageSize = 999999,
    EnrollmentStatus? status,
  }) async {
    if (ApiConfig.useMockApi) {
      final mockResponse = await _mockService.getOrganizationEnrollments(
        organizationId,
        page: page,
        perPage: pageSize,
        status: status,
      );
      // Convert mock Enrollments to Memberships
      if (mockResponse.success && mockResponse.data != null) {
        final memberships = mockResponse.data!.data.map((e) => Membership(
          id: int.tryParse(e.id) ?? 0,
          userId: int.tryParse(e.userId) ?? 0,
          organizationId: int.tryParse(e.organizationId) ?? 0,
          membershipStatusId: _mapEnrollmentStatusToMembershipStatusId(e.status),
          createdAt: e.createdAt,
        )).toList();
        return ApiResponse.success(PaginatedResponse(
          data: memberships,
          currentPage: mockResponse.data!.currentPage,
          lastPage: mockResponse.data!.lastPage,
          perPage: mockResponse.data!.perPage,
          total: mockResponse.data!.total,
        ));
      }
      return ApiResponse.error(mockResponse.message ?? 'Greška');
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
        'OrganizationId': organizationId,
        'IncludeUser': 'true',
        if (membershipStatusId != null) 'MembershipStatusId': membershipStatusId.toString(),
      },
      fromJson: (json) => PaginatedResponse.fromJson(json, Membership.fromJson),
    );
  }

  /// Approve enrollment (set MembershipStatusId to Active)
  /// Uses PUT /Membership/{id}
  Future<ApiResponse<Membership>> approveEnrollment(String membershipId) async {
    if (ApiConfig.useMockApi) {
      final mockResponse = await _mockService.approveEnrollment(membershipId);
      if (mockResponse.success && mockResponse.data != null) {
        return ApiResponse.success(Membership(
          id: int.tryParse(mockResponse.data!.id) ?? 0,
          userId: int.tryParse(mockResponse.data!.userId) ?? 0,
          organizationId: int.tryParse(mockResponse.data!.organizationId) ?? 0,
          membershipStatusId: EnrollmentService.statusActive,
          createdAt: mockResponse.data!.createdAt,
        ));
      }
      return ApiResponse.error(mockResponse.message ?? 'Greška');
    }

    return await _apiService.put<Membership>(
      '${ApiConfig.membership}/$membershipId',
      body: {
        'MembershipStatusId': EnrollmentService.statusActive,
        'StartDate': DateTime.now().toIso8601String(),
      },
      fromJson: (json) => Membership.fromJson(json),
    );
  }

  /// Reject enrollment (set MembershipStatusId to Rejected)
  /// Uses PUT /Membership/{id}
  Future<ApiResponse<Membership>> rejectEnrollment(String membershipId, {String? reason}) async {
    if (ApiConfig.useMockApi) {
      final mockResponse = await _mockService.rejectEnrollment(membershipId, reason: reason);
      if (mockResponse.success && mockResponse.data != null) {
        return ApiResponse.success(Membership(
          id: int.tryParse(mockResponse.data!.id) ?? 0,
          userId: int.tryParse(mockResponse.data!.userId) ?? 0,
          organizationId: int.tryParse(mockResponse.data!.organizationId) ?? 0,
          membershipStatusId: EnrollmentService.statusRejected,
          createdAt: mockResponse.data!.createdAt,
        ));
      }
      return ApiResponse.error(mockResponse.message ?? 'Greška');
    }

    return await _apiService.put<Membership>(
      '${ApiConfig.membership}/$membershipId',
      body: {
        'MembershipStatusId': EnrollmentService.statusRejected,
        'StartDate': DateTime.now().toIso8601String(),
      },
      fromJson: (json) => Membership.fromJson(json),
    );
  }

  /// Map EnrollmentStatus to MembershipStatusId
  int _mapEnrollmentStatusToMembershipStatusId(EnrollmentStatus status) {
    switch (status) {
      case EnrollmentStatus.pending:
        return EnrollmentService.statusPending;
      case EnrollmentStatus.approved:
        return EnrollmentService.statusActive;
      case EnrollmentStatus.rejected:
        return EnrollmentService.statusRejected;
      case EnrollmentStatus.cancelled:
        return EnrollmentService.statusCancelled;
    }
  }

  /// Get organization participations summary
  Future<ApiResponse<List<EventParticipation>>> getOrganizationParticipations(
    String organizationId,
  ) async {
    if (ApiConfig.useMockApi) {
      final mockResponse = await _mockService.getOrganizationParticipations(
        organizationId,
        page: 1,
        perPage: 999999,
      );
      if (mockResponse.success && mockResponse.data != null) {
        return ApiResponse.success(mockResponse.data!.data);
      }
      return ApiResponse.error(mockResponse.message ?? 'Greška');
    }

    return await _apiService.get<List<EventParticipation>>(
      '${ApiConfig.organization}/$organizationId/participations',
      fromJson: (json) => (json as List).map((item) => EventParticipation.fromJson(item)).toList(),
    );
  }

  /// Get organization participations by month
  Future<ApiResponse<List<ParticipationByMonth>>> getOrganizationParticipationsByMonth(
    String organizationId,
  ) async {
    return await _apiService.get<List<ParticipationByMonth>>(
      '${ApiConfig.organization}/$organizationId/participations/by-month',
      fromJson: (json) => (json as List).map((item) => ParticipationByMonth.fromJson(item)).toList(),
    );
  }

  /// Get organization participations by year
  Future<ApiResponse<List<ParticipationByYear>>> getOrganizationParticipationsByYear(
    String organizationId,
  ) async {
    return await _apiService.get<List<ParticipationByYear>>(
      '${ApiConfig.organization}/$organizationId/participations/by-year',
      fromJson: (json) => (json as List).map((item) => ParticipationByYear.fromJson(item)).toList(),
    );
  }

  /// Get participants for a specific month
  Future<ApiResponse<List<User>>> getParticipantsByMonth(
    String organizationId,
    int month,
  ) async {
    return await _apiService.get<List<User>>(
      '${ApiConfig.organization}/$organizationId/participants/month/$month',
      fromJson: (json) => (json as List).map((item) => User.fromJson(item)).toList(),
    );
  }

  /// Get participants for a specific year
  Future<ApiResponse<List<User>>> getParticipantsByYear(
    String organizationId,
    int year,
  ) async {
    return await _apiService.get<List<User>>(
      '${ApiConfig.organization}/$organizationId/participants/year/$year',
      fromJson: (json) => (json as List).map((item) => User.fromJson(item)).toList(),
    );
  }

  /// Get organization enrollments by month
  Future<ApiResponse<List<EnrollmentByMonth>>> getOrganizationEnrollmentsByMonth(
    String organizationId,
  ) async {
    return await _apiService.get<List<EnrollmentByMonth>>(
      '${ApiConfig.organization}/$organizationId/enrollments/by-month',
      fromJson: (json) => (json as List).map((item) => EnrollmentByMonth.fromJson(item)).toList(),
    );
  }

  /// Get organization enrollments by year
  Future<ApiResponse<List<EnrollmentByYear>>> getOrganizationEnrollmentsByYear(
    String organizationId,
  ) async {
    return await _apiService.get<List<EnrollmentByYear>>(
      '${ApiConfig.organization}/$organizationId/enrollments/by-year',
      fromJson: (json) => (json as List).map((item) => EnrollmentByYear.fromJson(item)).toList(),
    );
  }

  /// Get members for a specific month
  Future<ApiResponse<List<User>>> getMembersByMonth(
    String organizationId,
    int month,
  ) async {
    return await _apiService.get<List<User>>(
      '${ApiConfig.organization}/$organizationId/members/month/$month',
      fromJson: (json) => (json as List).map((item) => User.fromJson(item)).toList(),
    );
  }

  /// Get members for a specific year
  Future<ApiResponse<List<User>>> getMembersByYear(
    String organizationId,
    int year,
  ) async {
    return await _apiService.get<List<User>>(
      '${ApiConfig.organization}/$organizationId/members/year/$year',
      fromJson: (json) => (json as List).map((item) => User.fromJson(item)).toList(),
    );
  }
}

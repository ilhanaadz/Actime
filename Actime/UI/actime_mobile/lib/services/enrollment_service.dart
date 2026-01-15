import '../config/api_config.dart';
import '../models/models.dart';
import 'api_service.dart';
import 'mock_api_service.dart';

/// Enrollment service for managing club membership applications
class EnrollmentService {
  static final EnrollmentService _instance = EnrollmentService._internal();
  factory EnrollmentService() => _instance;
  EnrollmentService._internal();

  final ApiService _apiService = ApiService();
  final MockApiService _mockService = MockApiService();

  /// Create enrollment (apply to join organization)
  Future<ApiResponse<Enrollment>> createEnrollment({
    required String organizationId,
    String? message,
  }) async {
    if (ApiConfig.useMockApi) {
      return await _mockService.createEnrollment(
        organizationId: organizationId,
        message: message,
      );
    }

    return await _apiService.post<Enrollment>(
      ApiConfig.enrollments,
      body: {
        'organizationId': organizationId,
        if (message != null) 'message': message,
      },
      fromJson: (json) => Enrollment.fromJson(json),
    );
  }

  /// Cancel enrollment
  Future<ApiResponse<void>> cancelEnrollment(String id) async {
    if (ApiConfig.useMockApi) {
      return ApiResponse.success(null, message: 'Prijava je uspješno otkazana');
    }

    return await _apiService.delete('${ApiConfig.enrollments}/$id');
  }

  /// Get user's enrollments
  Future<ApiResponse<PaginatedResponse<Enrollment>>> getUserEnrollments({
    int page = 1,
    int perPage = 10,
    EnrollmentStatus? status,
  }) async {
    if (ApiConfig.useMockApi) {
      // Return mock enrollments for current user
      return ApiResponse.success(PaginatedResponse(
        data: [],
        currentPage: page,
        lastPage: 1,
        perPage: perPage,
        total: 0,
      ));
    }

    return await _apiService.get<PaginatedResponse<Enrollment>>(
      '${ApiConfig.enrollments}/my',
      queryParams: {
        'page': page.toString(),
        'perPage': perPage.toString(),
        if (status != null) 'status': status.value,
      },
      fromJson: (json) => PaginatedResponse.fromJson(json, Enrollment.fromJson),
    );
  }
}

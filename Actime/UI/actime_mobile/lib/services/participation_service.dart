import '../config/api_config.dart';
import '../models/api_response.dart';
import '../models/paginated_response.dart';
import '../models/participation.dart';
import 'api_service.dart';

/// Participation service
/// Communicates with backend ParticipationController
class ParticipationService {
  static final ParticipationService _instance = ParticipationService._internal();
  factory ParticipationService() => _instance;
  ParticipationService._internal();

  final ApiService _apiService = ApiService();

  /// Get participations (paginated)
  Future<ApiResponse<PaginatedResponse<Participation>>> getParticipations({
    int page = 1,
    int pageSize = 10,
    bool includeTotalCount = true,
  }) async {
    if (ApiConfig.useMockApi) {
      return ApiResponse.success(PaginatedResponse(items: [], totalCount: 0));
    }

    return await _apiService.get<PaginatedResponse<Participation>>(
      ApiConfig.participation,
      queryParams: {
        'Page': page.toString(),
        'PageSize': pageSize.toString(),
        'IncludeTotalCount': includeTotalCount.toString(),
      },
      fromJson: (json) => PaginatedResponse.fromJson(json, Participation.fromJson),
    );
  }

  /// Get participation by ID
  Future<ApiResponse<Participation>> getParticipationById(int id) async {
    if (ApiConfig.useMockApi) {
      return ApiResponse.error('Mock nije dostupan');
    }

    return await _apiService.get<Participation>(
      ApiConfig.participationById(id),
      fromJson: (json) => Participation.fromJson(json),
    );
  }

  /// Create participation
  Future<ApiResponse<Participation>> createParticipation({
    required int userId,
    required int eventId,
    required int attendanceStatusId,
    required int paymentStatusId,
    int? paymentMethodId,
  }) async {
    if (ApiConfig.useMockApi) {
      return ApiResponse.error('Mock nije dostupan');
    }

    return await _apiService.post<Participation>(
      ApiConfig.participation,
      body: {
        'UserId': userId,
        'EventId': eventId,
        'AttendanceStatusId': attendanceStatusId,
        'PaymentStatusId': paymentStatusId,
        if (paymentMethodId != null) 'PaymentMethodId': paymentMethodId,
      },
      fromJson: (json) => Participation.fromJson(json),
    );
  }

  /// Update attendance status
  Future<ApiResponse<bool>> updateAttendanceStatus(int id, int statusId) async {
    if (ApiConfig.useMockApi) {
      return ApiResponse.success(true);
    }

    return await _apiService.put<bool>(
      ApiConfig.participationAttendanceStatus(id, statusId),
      fromJson: (_) => true,
    );
  }

  /// Update payment status
  Future<ApiResponse<bool>> updatePaymentStatus(int id, int statusId) async {
    if (ApiConfig.useMockApi) {
      return ApiResponse.success(true);
    }

    return await _apiService.put<bool>(
      ApiConfig.participationPaymentStatus(id, statusId),
      fromJson: (_) => true,
    );
  }

  /// Get participation count for event
  Future<ApiResponse<int>> getEventParticipationCount(int eventId) async {
    if (ApiConfig.useMockApi) {
      return ApiResponse.success(0);
    }

    return await _apiService.get<int>(
      ApiConfig.participationEventCount(eventId),
      fromJson: (json) => json['count'] as int? ?? 0,
    );
  }

  /// Get participations by user
  Future<ApiResponse<List<Participation>>> getParticipationsByUser(int userId) async {
    if (ApiConfig.useMockApi) {
      return ApiResponse.success([]);
    }

    return await _apiService.get<List<Participation>>(
      ApiConfig.participationByUser(userId),
      fromJson: (json) {
        final list = json['items'] as List? ?? json as List? ?? [];
        return list.map((item) => Participation.fromJson(item as Map<String, dynamic>)).toList();
      },
    );
  }

  /// Delete participation
  Future<ApiResponse<void>> deleteParticipation(int id) async {
    if (ApiConfig.useMockApi) {
      return ApiResponse.success(null);
    }

    return await _apiService.delete(ApiConfig.participationById(id));
  }
}

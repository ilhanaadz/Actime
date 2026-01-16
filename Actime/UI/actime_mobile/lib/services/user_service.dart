import '../config/api_config.dart';
import '../models/models.dart';
import 'api_service.dart';
import 'mock_api_service.dart';

/// User service for user-related operations
class UserService {
  static final UserService _instance = UserService._internal();
  factory UserService() => _instance;
  UserService._internal();

  final ApiService _apiService = ApiService();
  final MockApiService _mockService = MockApiService();

  /// Get user by ID
  Future<ApiResponse<User>> getUserById(String id) async {
    if (ApiConfig.useMockApi) {
      return await _mockService.getUserById(id);
    }

    return await _apiService.get<User>(
      ApiConfig.userById(id),
      fromJson: (json) => User.fromJson(json),
    );
  }

  /// Get current user profile
  Future<ApiResponse<User>> getCurrentUser() async {
    if (ApiConfig.useMockApi) {
      return await _mockService.getCurrentUser();
    }

    return await _apiService.get<User>(
      ApiConfig.userProfile,
      fromJson: (json) => User.fromJson(json),
    );
  }

  /// Update user profile
  Future<ApiResponse<User>> updateUser(String id, Map<String, dynamic> data) async {
    if (ApiConfig.useMockApi) {
      return await _mockService.updateUser(id, data);
    }

    return await _apiService.put<User>(
      ApiConfig.userById(id),
      body: data,
      fromJson: (json) => User.fromJson(json),
    );
  }

  /// Get users list (paginated)
  Future<ApiResponse<PaginatedResponse<User>>> getUsers({
    int page = 1,
    int perPage = 10,
    String? search,
    String? sortBy,
  }) async {
    if (ApiConfig.useMockApi) {
      return await _mockService.getUsers(
        page: page,
        perPage: perPage,
        search: search,
        sortBy: sortBy,
      );
    }

    return await _apiService.get<PaginatedResponse<User>>(
      ApiConfig.users,
      queryParams: {
        'page': page.toString(),
        'perPage': perPage.toString(),
        if (search != null) 'search': search,
        if (sortBy != null) 'sortBy': sortBy,
      },
      fromJson: (json) => PaginatedResponse.fromJson(json, User.fromJson),
    );
  }

  /// Get user's events
  Future<ApiResponse<PaginatedResponse<Event>>> getUserEvents(
    String userId, {
    int page = 1,
    int perPage = 10,
    EventStatus? status,
  }) async {
    if (ApiConfig.useMockApi) {
      return await _mockService.getUserEvents(
        userId,
        page: page,
        perPage: perPage,
        status: status,
      );
    }

    return await _apiService.get<PaginatedResponse<Event>>(
      ApiConfig.userEvents(userId),
      queryParams: {
        'page': page.toString(),
        'perPage': perPage.toString(),
        if (status != null) 'status': status.value,
      },
      fromJson: (json) => PaginatedResponse.fromJson(json, Event.fromJson),
    );
  }

  /// Get user's event history
  Future<ApiResponse<PaginatedResponse<Event>>> getUserEventHistory(
    String userId, {
    int page = 1,
    int perPage = 10,
  }) async {
    if (ApiConfig.useMockApi) {
      return await _mockService.getUserEventHistory(
        userId,
        page: page,
        perPage: perPage,
      );
    }

    return await _apiService.get<PaginatedResponse<Event>>(
      ApiConfig.userHistory(userId),
      queryParams: {
        'page': page.toString(),
        'perPage': perPage.toString(),
      },
      fromJson: (json) => PaginatedResponse.fromJson(json, Event.fromJson),
    );
  }

  /// Get user's memberships (approved enrollments)
  Future<ApiResponse<PaginatedResponse<Enrollment>>> getUserMemberships(
    String userId, {
    int page = 1,
    int perPage = 10,
  }) async {
    if (ApiConfig.useMockApi) {
      return await _mockService.getUserMemberships(
        userId,
        page: page,
        perPage: perPage,
      );
    }

    return await _apiService.get<PaginatedResponse<Enrollment>>(
      '${ApiConfig.userById(userId)}/memberships',
      queryParams: {
        'page': page.toString(),
        'perPage': perPage.toString(),
      },
      fromJson: (json) => PaginatedResponse.fromJson(json, Enrollment.fromJson),
    );
  }

  /// Cancel membership
  Future<ApiResponse<void>> cancelMembership(String enrollmentId) async {
    if (ApiConfig.useMockApi) {
      return await _mockService.cancelMembership(enrollmentId);
    }

    return await _apiService.delete('${ApiConfig.enrollments}/$enrollmentId');
  }
}

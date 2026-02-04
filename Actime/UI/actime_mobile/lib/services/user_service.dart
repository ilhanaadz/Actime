import '../config/api_config.dart';
import '../models/models.dart';
import 'api_service.dart';
import 'auth_service.dart';
import 'mock_api_service.dart';

/// User service for user-related operations
/// Communicates with backend UserController
class UserService {
  static final UserService _instance = UserService._internal();
  factory UserService() => _instance;
  UserService._internal();

  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();
  final MockApiService _mockService = MockApiService();

  /// Get user by ID
  Future<ApiResponse<User>> getUserById(String id) async {
    if (ApiConfig.useMockApi) {
      return await _mockService.getUserById(id);
    }

    return await _apiService.get<User>(
      '${ApiConfig.user}/$id',
      fromJson: (json) => User.fromJson(json),
    );
  }

  /// Get current user profile
  /// Uses /me endpoint via AuthService and converts AuthResponse to User
  Future<ApiResponse<User>> getCurrentUser() async {
    if (ApiConfig.useMockApi) {
      return await _mockService.getCurrentUser();
    }

    // Call /me endpoint which returns AuthResponse
    final authResponse = await _authService.getCurrentUser();

    if (!authResponse.success || authResponse.data == null) {
      return ApiResponse.error(
        authResponse.message ?? 'Failed to get current user',
        statusCode: authResponse.statusCode,
      );
    }

    // Convert AuthResponse to User using the built-in getter
    final user = authResponse.data!.user;
    return ApiResponse.success(user, statusCode: authResponse.statusCode);
  }

  /// Update user profile (own profile)
  Future<ApiResponse<User>> updateProfile(Map<String, dynamic> data) async {
    if (ApiConfig.useMockApi) {
      return await _mockService.updateUser('1', data);
    }

    if (data.containsKey('ProfileImageUrl')) {
      final path = data['ProfileImageUrl'] as String?;
      if (path != null && !path.startsWith(RegExp(r'https?:\/\/'))) {
        data['ProfileImageUrl'] = '${ApiConfig.baseUrl}$path';
      }
    }

    return await _apiService.put<User>(
      ApiConfig.userProfile(),
      body: data,
      fromJson: (json) => User.fromJson(json),
    );
  }

  /// Update user by ID (admin only)
  Future<ApiResponse<User>> updateUser(
    String id,
    Map<String, dynamic> data,
  ) async {
    if (ApiConfig.useMockApi) {
      return await _mockService.updateUser(id, data);
    }

    return await _apiService.put<User>(
      '${ApiConfig.user}/$id',
      body: data,
      fromJson: (json) => User.fromJson(json),
    );
  }

  /// Delete user (admin only)
  Future<ApiResponse<void>> deleteUser(String id) async {
    if (ApiConfig.useMockApi) {
      return ApiResponse.success(null, message: 'Korisnik je obrisan');
    }

    return await _apiService.delete('${ApiConfig.user}/$id');
  }

  /// Get users list (paginated)
  /// Backend uses TextSearchObject for filtering
  Future<ApiResponse<PaginatedResponse<User>>> getUsers({
    int page = 1,
    int pageSize = 10,
    String? text,
    String? sortBy,
    bool sortDescending = false,
    bool includeTotalCount = true,
  }) async {
    if (ApiConfig.useMockApi) {
      return await _mockService.getUsers(
        page: page,
        perPage: pageSize,
        search: text,
        sortBy: sortBy,
      );
    }

    return await _apiService.get<PaginatedResponse<User>>(
      ApiConfig.user,
      queryParams: {
        'Page': page.toString(),
        'PageSize': pageSize.toString(),
        'IncludeTotalCount': includeTotalCount.toString(),
        if (text != null && text.isNotEmpty) 'Text': text,
        if (sortBy != null) 'SortBy': sortBy,
        'SortDescending': sortDescending.toString(),
      },
      fromJson: (json) => PaginatedResponse.fromJson(json, User.fromJson),
    );
  }

  /// Get user's memberships (organizations they belong to)
  Future<ApiResponse<PaginatedResponse<Enrollment>>> getUserMemberships({
    int page = 1,
    int perPage = 10,
  }) async {
    if (ApiConfig.useMockApi) {
      return await _mockService.getUserMemberships(
        '1',
        page: page,
        perPage: perPage,
      );
    }

    return await _apiService.get<PaginatedResponse<Enrollment>>(
      '${ApiConfig.membership}/my',
      queryParams: {'page': page.toString(), 'perPage': perPage.toString()},
      fromJson: (json) => PaginatedResponse.fromJson(json, Enrollment.fromJson),
    );
  }

  /// Cancel membership (leave organization) by enrollment ID
  Future<ApiResponse<void>> cancelMembership(String enrollmentId) async {
    if (ApiConfig.useMockApi) {
      return await _mockService.cancelMembership(enrollmentId);
    }

    return await _apiService.delete('${ApiConfig.membership}/$enrollmentId');
  }

  /// Cancel membership by organization ID
  Future<ApiResponse<void>> cancelMembershipByOrganization(
    String organizationId,
  ) async {
    if (ApiConfig.useMockApi) {
      return await _mockService.cancelMembership(organizationId);
    }

    return await _apiService.delete(
      ApiConfig.membershipByOrganization(int.parse(organizationId)),
    );
  }

  /// Get user's event history (past events)
  Future<ApiResponse<PaginatedResponse<Event>>> getUserEventHistory({
    int page = 1,
    int perPage = 10,
  }) async {
    if (ApiConfig.useMockApi) {
      // Return mock events filtered as past events
      final eventsResponse = await _mockService.getEvents(
        page: page,
        perPage: perPage,
      );
      if (eventsResponse.success && eventsResponse.data != null) {
        final pastEvents = eventsResponse.data!.items
            .where((e) => e.status == EventStatus.completed)
            .toList();
        return ApiResponse.success(
          PaginatedResponse<Event>(
            items: pastEvents,
            totalCount: pastEvents.length,
            page: page,
            pageSize: perPage,
          ),
        );
      }
      return eventsResponse;
    }

    return await _apiService.get<PaginatedResponse<Event>>(
      '${ApiConfig.participation}/my/history',
      queryParams: {'page': page.toString(), 'perPage': perPage.toString()},
      fromJson: (json) => PaginatedResponse.fromJson(json, Event.fromJson),
    );
  }

  /// Get user's upcoming events
  Future<ApiResponse<PaginatedResponse<Event>>> getUserEvents({
    int page = 1,
    int perPage = 10,
  }) async {
    if (ApiConfig.useMockApi) {
      // Return mock events filtered as upcoming
      final eventsResponse = await _mockService.getEvents(
        page: page,
        perPage: perPage,
      );
      if (eventsResponse.success && eventsResponse.data != null) {
        final upcomingEvents = eventsResponse.data!.items
            .where((e) => e.status == EventStatus.upcoming)
            .toList();
        return ApiResponse.success(
          PaginatedResponse<Event>(
            items: upcomingEvents,
            totalCount: upcomingEvents.length,
            page: page,
            pageSize: perPage,
          ),
        );
      }
      return eventsResponse;
    }

    return await _apiService.get<PaginatedResponse<Event>>(
      '${ApiConfig.participation}/my',
      queryParams: {'page': page.toString(), 'perPage': perPage.toString()},
      fromJson: (json) => PaginatedResponse.fromJson(json, Event.fromJson),
    );
  }
}

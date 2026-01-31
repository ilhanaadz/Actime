import '../config/api_config.dart';
import 'api_service.dart';
import 'mock_api_service.dart';
import 'user_service.dart';
import 'organization_service.dart';
import 'event_service.dart';

class DashboardStats {
  final int totalUsers;
  final int totalOrganizations;
  final int totalEvents;

  DashboardStats({
    required this.totalUsers,
    required this.totalOrganizations,
    required this.totalEvents,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      totalUsers: json['TotalUsers'] ?? json['totalUsers'] ?? json['total_users'] ?? 0,
      totalOrganizations: json['TotalOrganizations'] ?? json['totalOrganizations'] ?? json['total_organizations'] ?? 0,
      totalEvents: json['TotalEvents'] ?? json['totalEvents'] ?? json['total_events'] ?? 0,
    );
  }
}

class UserGrowthData {
  final String month;
  final int count;

  UserGrowthData({
    required this.month,
    required this.count,
  });

  factory UserGrowthData.fromJson(Map<String, dynamic> json) {
    return UserGrowthData(
      month: json['Month'] ?? json['month'] ?? '',
      count: json['Count'] ?? json['count'] ?? 0,
    );
  }
}

class DashboardService {
  static final DashboardService _instance = DashboardService._internal();
  factory DashboardService() => _instance;
  DashboardService._internal();

  final ApiService _apiService = ApiService();
  final MockApiService _mockService = MockApiService();
  final UserService _userService = UserService();
  final OrganizationService _organizationService = OrganizationService();
  final EventService _eventService = EventService();

  Future<ApiResponse<DashboardStats>> getStats() async {
    if (ApiConfig.useMockApi) {
      return await _mockService.getDashboardStats();
    }

    // Aggregate stats from individual endpoints since backend may not have a dashboard endpoint
    try {
      final usersResponse = await _userService.getUsers(pageSize: 1);
      final orgsResponse = await _organizationService.getOrganizations(pageSize: 1);
      final eventsResponse = await _eventService.getEvents(pageSize: 1);

      return ApiResponse(
        success: true,
        data: DashboardStats(
          totalUsers: usersResponse.data?.totalCount ?? 0,
          totalOrganizations: orgsResponse.data?.totalCount ?? 0,
          totalEvents: eventsResponse.data?.totalCount ?? 0,
        ),
        statusCode: 200,
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Failed to fetch dashboard stats: $e',
        statusCode: 500,
      );
    }
  }

  Future<ApiResponse<List<UserGrowthData>>> getUserGrowth({
    int months = 12,
  }) async {
    if (ApiConfig.useMockApi) {
      return await _mockService.getUserGrowth();
    }

    // Backend may not have this endpoint, return mock data for now
    return ApiResponse(
      success: true,
      data: [
        UserGrowthData(month: 'Jan', count: 0),
        UserGrowthData(month: 'Feb', count: 0),
        UserGrowthData(month: 'Mar', count: 0),
        UserGrowthData(month: 'Apr', count: 0),
        UserGrowthData(month: 'May', count: 0),
        UserGrowthData(month: 'Jun', count: 0),
        UserGrowthData(month: 'Jul', count: 0),
        UserGrowthData(month: 'Aug', count: 0),
        UserGrowthData(month: 'Sep', count: 0),
        UserGrowthData(month: 'Oct', count: 0),
        UserGrowthData(month: 'Nov', count: 0),
        UserGrowthData(month: 'Dec', count: 0),
      ],
      statusCode: 200,
    );
  }
}

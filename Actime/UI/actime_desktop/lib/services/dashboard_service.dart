import '../config/api_config.dart';
import 'api_service.dart';
import 'mock_api_service.dart';

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

  Future<ApiResponse<DashboardStats>> getStats() async {
    if (ApiConfig.useMockApi) {
      return await _mockService.getDashboardStats();
    }

    try {
      final response = await _apiService.get<DashboardStats>(
        '/Dashboard/stats',
        fromJson: (json) => DashboardStats.fromJson(json),
      );
      return response;
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Failed to fetch dashboard stats: $e',
        statusCode: 500,
      );
    }
  }

  Future<ApiResponse<List<UserGrowthData>>> getUserGrowth({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    if (ApiConfig.useMockApi) {
      return await _mockService.getUserGrowth();
    }

    try {
      final queryParams = <String, String>{};
      if (startDate != null) {
        queryParams['startDate'] = startDate.toIso8601String();
      }
      if (endDate != null) {
        queryParams['endDate'] = endDate.toIso8601String();
      }

      final response = await _apiService.get<List<UserGrowthData>>(
        '/Dashboard/user-growth',
        queryParams: queryParams,
        fromJson: (json) {
          if (json is List) {
            return json.map((item) => UserGrowthData.fromJson(item)).toList();
          }
          return [];
        },
      );
      return response;
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Failed to fetch user growth data: $e',
        statusCode: 500,
      );
    }
  }
}

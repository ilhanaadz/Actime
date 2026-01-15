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
      totalUsers: json['total_users'] ?? json['totalUsers'] ?? 0,
      totalOrganizations: json['total_organizations'] ?? json['totalOrganizations'] ?? 0,
      totalEvents: json['total_events'] ?? json['totalEvents'] ?? 0,
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
      month: json['month'] ?? '',
      count: json['count'] ?? 0,
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

    return await _apiService.get<DashboardStats>(
      ApiConfig.dashboardStats,
      fromJson: (json) => DashboardStats.fromJson(json),
    );
  }

  Future<ApiResponse<List<UserGrowthData>>> getUserGrowth({
    int months = 12,
  }) async {
    if (ApiConfig.useMockApi) {
      return await _mockService.getUserGrowth();
    }

    return await _apiService.get<List<UserGrowthData>>(
      ApiConfig.dashboardUserGrowth,
      queryParams: {'months': months.toString()},
      fromJson: (json) {
        if (json is List) {
          return json.map((item) => UserGrowthData.fromJson(item)).toList();
        }
        if (json is Map && json.containsKey('data')) {
          return (json['data'] as List)
              .map((item) => UserGrowthData.fromJson(item))
              .toList();
        }
        return <UserGrowthData>[];
      },
    );
  }
}

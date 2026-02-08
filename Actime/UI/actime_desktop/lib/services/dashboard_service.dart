import 'api_service.dart';

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

class OrganizationUserData {
  final String organizationName;
  final int memberCount;
  final int eventParticipantCount;
  final int totalUsers;

  OrganizationUserData({
    required this.organizationName,
    required this.memberCount,
    required this.eventParticipantCount,
    required this.totalUsers,
  });

  factory OrganizationUserData.fromJson(Map<String, dynamic> json) {
    return OrganizationUserData(
      organizationName: json['OrganizationName'] ?? json['organizationName'] ?? '',
      memberCount: json['MemberCount'] ?? json['memberCount'] ?? 0,
      eventParticipantCount: json['EventParticipantCount'] ?? json['eventParticipantCount'] ?? 0,
      totalUsers: json['TotalUsers'] ?? json['totalUsers'] ?? 0,
    );
  }
}

class DashboardService {
  static final DashboardService _instance = DashboardService._internal();
  factory DashboardService() => _instance;
  DashboardService._internal();

  final ApiService _apiService = ApiService();

  Future<ApiResponse<DashboardStats>> getStats() async {
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

  Future<ApiResponse<List<OrganizationUserData>>> getUsersPerOrganization() async {
    try {
      final response = await _apiService.get<List<OrganizationUserData>>(
        '/Dashboard/users-per-organization',
        fromJson: (json) {
          if (json is List) {
            return json.map((item) => OrganizationUserData.fromJson(item)).toList();
          }
          return [];
        },
      );
      return response;
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Failed to fetch users per organization: $e',
        statusCode: 500,
      );
    }
  }
}

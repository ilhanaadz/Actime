import '../config/api_config.dart';
import '../models/models.dart';
import 'api_service.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final ApiService _apiService = ApiService();

  Future<ApiResponse<PaginatedResponse<AppNotification>>> getNotifications({
    int page = 1,
    int pageSize = 10,
    int? userId,
    bool? isRead,
  }) async {
    final queryParams = <String, String>{
      'Page': page.toString(),
      'PageSize': pageSize.toString(),
      'IncludeTotalCount': 'true',
    };

    if (userId != null) {
      queryParams['UserId'] = userId.toString();
    }
    if (isRead != null) {
      queryParams['IsRead'] = isRead.toString();
    }

    return await _apiService.get<PaginatedResponse<AppNotification>>(
      ApiConfig.notification,
      queryParams: queryParams,
      fromJson: (json) => PaginatedResponse.fromJson(json, AppNotification.fromJson),
    );
  }

  Future<ApiResponse<int>> getUnreadCount(int userId) async {
    return await _apiService.get<int>(
      ApiConfig.notificationUnreadCount(userId),
      fromJson: (json) {
        if (json is int) return json;
        if (json is Map) {
          return (json['Count'] ?? json['count'] ?? 0) as int;
        }
        return 0;
      },
    );
  }

  Future<ApiResponse<AppNotification>> getNotificationById(int id) async {
    return await _apiService.get<AppNotification>(
      ApiConfig.notificationById(id),
      fromJson: (json) => AppNotification.fromJson(json),
    );
  }

  Future<ApiResponse<AppNotification>> createNotification({
    required int userId,
    required String title,
    required String message,
  }) async {
    return await _apiService.post<AppNotification>(
      ApiConfig.notification,
      body: {
        'UserId': userId,
        'Title': title,
        'Message': message,
      },
      fromJson: (json) => AppNotification.fromJson(json),
    );
  }

  Future<ApiResponse<AppNotification>> markAsRead(int id) async {
    return await _apiService.put<AppNotification>(
      ApiConfig.notificationById(id),
      body: {
        'IsRead': true,
      },
      fromJson: (json) => AppNotification.fromJson(json),
    );
  }

  Future<ApiResponse<void>> deleteNotification(int id) async {
    return await _apiService.delete<void>(
      ApiConfig.notificationById(id),
    );
  }
}

import '../config/api_config.dart';
import '../models/api_response.dart';
import '../models/paginated_response.dart';
import '../models/notification.dart';
import 'api_service.dart';

/// Notification service
/// Communicates with backend NotificationController
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final ApiService _apiService = ApiService();

  /// Get notifications (paginated)
  Future<ApiResponse<PaginatedResponse<AppNotification>>> getNotifications({
    int page = 1,
    int pageSize = 10,
    bool includeTotalCount = true,
  }) async {
    return await _apiService.get<PaginatedResponse<AppNotification>>(
      ApiConfig.notification,
      queryParams: {
        'Page': page.toString(),
        'PageSize': pageSize.toString(),
        'IncludeTotalCount': includeTotalCount.toString(),
      },
      fromJson: (json) => PaginatedResponse.fromJson(json, AppNotification.fromJson),
    );
  }

  /// Get notification by ID
  Future<ApiResponse<AppNotification>> getNotificationById(int id) async {
    return await _apiService.get<AppNotification>(
      ApiConfig.notificationById(id),
      fromJson: (json) => AppNotification.fromJson(json),
    );
  }

  /// Create notification
  Future<ApiResponse<AppNotification>> createNotification({
    required int userId,
    required String title,
    String? message,
  }) async {
    return await _apiService.post<AppNotification>(
      ApiConfig.notification,
      body: {
        'UserId': userId,
        'Title': title,
        if (message != null) 'Message': message,
      },
      fromJson: (json) => AppNotification.fromJson(json),
    );
  }

  /// Mark notification as read
  Future<ApiResponse<bool>> markAsRead(int id) async {
    return await _apiService.put<bool>(
      ApiConfig.notificationMarkAsRead(id),
      fromJson: (_) => true,
    );
  }

  /// Mark all notifications as read for user
  Future<ApiResponse<bool>> markAllAsRead(int userId) async {
    return await _apiService.put<bool>(
      ApiConfig.notificationMarkAllAsRead(userId),
      fromJson: (_) => true,
    );
  }

  /// Get unread notification count
  Future<ApiResponse<int>> getUnreadCount(int userId) async {
    return await _apiService.get<int>(
      ApiConfig.notificationUnreadCount(userId),
      fromJson: (json) {
        // Backend returns the count directly as a number
        if (json is int) return json;
        // Or as an object with 'count' key
        if (json is Map<String, dynamic>) {
          return json['count'] as int? ?? json['Count'] as int? ?? 0;
        }
        return 0;
      },
    );
  }

  /// Delete notification
  Future<ApiResponse<void>> deleteNotification(int id) async {
    return await _apiService.delete(ApiConfig.notificationById(id));
  }
}

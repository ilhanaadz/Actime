class ApiConfig {
  static const String baseUrl = 'http://localhost:8080';
  static const String apiVersion = '/api/v1';

  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Auth endpoints
  static const String login = '/auth/login';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh';

  // User endpoints
  static const String users = '/users';
  static String userById(String id) => '/users/$id';

  // Organization endpoints
  static const String organizations = '/organizations';
  static String organizationById(String id) => '/organizations/$id';

  // Event endpoints
  static const String events = '/events';
  static String eventById(String id) => '/events/$id';

  // Category endpoints
  static const String categories = '/categories';
  static String categoryById(String id) => '/categories/$id';

  // Dashboard endpoints
  static const String dashboardStats = '/dashboard/stats';
  static const String dashboardUserGrowth = '/dashboard/user-growth';

  // Full URL helpers
  static String fullUrl(String endpoint) => '$baseUrl$apiVersion$endpoint';
}

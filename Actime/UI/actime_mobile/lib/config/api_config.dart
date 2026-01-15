/// API Configuration for Actime Mobile
///
/// This class contains all API-related configuration settings.
/// Toggle [useMockApi] to switch between mock and real API.
class ApiConfig {
  // Toggle this to switch between mock and real API
  static const bool useMockApi = true;

  // Base URL for the API
  static const String baseUrl = 'http://localhost:8080';
  static const String apiVersion = '/api/v1';

  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Auth endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String refreshToken = '/auth/refresh';
  static const String logout = '/auth/logout';

  // User endpoints
  static const String users = '/users';
  static const String userProfile = '/users/profile';

  // Organization endpoints
  static const String organizations = '/organizations';

  // Event endpoints
  static const String events = '/events';

  // Category endpoints
  static const String categories = '/categories';

  // Club/Organization membership
  static const String memberships = '/memberships';
  static const String enrollments = '/enrollments';

  // Dashboard endpoints
  static const String dashboardStats = '/dashboard/stats';
  static const String dashboardUserGrowth = '/dashboard/user-growth';

  // Helper methods
  static String get fullUrl => '$baseUrl$apiVersion';

  static String userById(String id) => '$users/$id';
  static String organizationById(String id) => '$organizations/$id';
  static String eventById(String id) => '$events/$id';
  static String categoryById(String id) => '$categories/$id';

  // Organization specific endpoints
  static String organizationEvents(String orgId) => '$organizations/$orgId/events';
  static String organizationMembers(String orgId) => '$organizations/$orgId/members';
  static String organizationEnrollments(String orgId) => '$organizations/$orgId/enrollments';

  // Event specific endpoints
  static String eventParticipants(String eventId) => '$events/$eventId/participants';
  static String joinEvent(String eventId) => '$events/$eventId/join';
  static String leaveEvent(String eventId) => '$events/$eventId/leave';

  // User specific endpoints
  static String userEvents(String userId) => '$users/$userId/events';
  static String userOrganizations(String userId) => '$users/$userId/organizations';
  static String userHistory(String userId) => '$users/$userId/history';
}

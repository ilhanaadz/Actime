/// API Configuration for Actime Mobile
///
/// This class contains all API-related configuration settings.
/// Toggle [useMockApi] to switch between mock and real API.
class ApiConfig {
  // Toggle this to switch between mock and real API
  // Set to false to use real backend API
  static const bool useMockApi = false;

  // Base URL for the API - Update this to match your backend server
  // For Android emulator use: http://10.0.2.2:5000
  // For iOS simulator use: http://localhost:5000
  // For physical device use your computer's IP: http://192.168.x.x:5000
  static const String baseUrl = 'http://10.0.2.2:5171';

  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Auth endpoints (backend: AuthController)
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String refreshToken = '/auth/refresh-token';
  static const String logout = '/auth/logout';
  static const String me = '/auth/me';
  static const String completeOrganization = '/auth/complete-organization';
  static const String confirmEmail = '/auth/confirm-email';
  static const String resendConfirmationEmail = '/auth/resend-confirmation-email';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  static const String changePassword = '/auth/change-password';

  // User endpoints (backend: UserController)
  static const String user = '/user';

  // Organization endpoints (backend: OrganizationController)
  static const String organization = '/organization';

  // Event endpoints (backend: EventController)
  static const String event = '/event';

  // Category endpoints (backend: CategoryController)
  static const String category = '/category';

  // Favorite endpoints (backend: FavoriteController)
  static const String favorite = '/favorite';

  // Membership endpoints (backend: MembershipController)
  static const String membership = '/membership';

  // Enrollment endpoints (backend: EnrollmentController)
  static const String enrollments = '/enrollment';

  // Participation endpoints (backend: ParticipationController)
  static const String participation = '/participation';

  // Review endpoints (backend: ReviewController)
  static const String review = '/review';

  // Notification endpoints (backend: NotificationController)
  static const String notification = '/notification';

  // Schedule endpoints (backend: ScheduleController)
  static const String schedule = '/schedule';

  // Report endpoints (backend: ReportController)
  static const String report = '/report';

  // Location endpoints (backend: LocationController)
  static const String location = '/location';

  // City endpoints (backend: CityController)
  static const String city = '/city';

  // Country endpoints (backend: CountryController)
  static const String country = '/country';

  // Address endpoints (backend: AddressController)
  static const String address = '/address';

  // Health check
  static const String health = '/health';

  // Helper method - no API version prefix needed
  static String get fullUrl => baseUrl;

  // User endpoints
  static String userById(int id) => '$user/$id';
  static String userProfile() => '$user/profile';

  // Organization endpoints
  static String organizationById(int id) => '$organization/$id';
  static String organizationMy() => '$organization/my';

  // Event endpoints
  static String eventById(int id) => '$event/$id';

  // Category endpoints
  static String categoryById(int id) => '$category/$id';

  // Favorite endpoints
  static String favoriteById(int id) => '$favorite/$id';

  // Membership endpoints
  static String membershipById(int id) => '$membership/$id';

  // Participation endpoints
  static String participationById(int id) => '$participation/$id';
  static String participationAttendanceStatus(int id, int statusId) =>
      '$participation/$id/attendance-status/$statusId';
  static String participationPaymentStatus(int id, int statusId) =>
      '$participation/$id/payment-status/$statusId';
  static String participationEventCount(int eventId) =>
      '$participation/event/$eventId/count';
  static String participationByUser(int userId) => '$participation/user/$userId';

  // Review endpoints
  static String reviewById(int id) => '$review/$id';
  static String reviewByOrganization(int orgId) => '$review/organization/$orgId';
  static String reviewOrganizationAverage(int orgId) =>
      '$review/organization/$orgId/average';
  static String reviewByUser(int userId) => '$review/user/$userId';

  // Notification endpoints
  static String notificationById(int id) => '$notification/$id';
  static String notificationMarkAsRead(int id) => '$notification/$id/mark-as-read';
  static String notificationMarkAllAsRead(int userId) =>
      '$notification/mark-all-as-read/$userId';
  static String notificationUnreadCount(int userId) =>
      '$notification/unread-count/$userId';

  // Schedule endpoints
  static String scheduleById(int id) => '$schedule/$id';
  static String scheduleByOrganization(int orgId) => '$schedule/organization/$orgId';
  static String scheduleByDay(int dayOfWeek) => '$schedule/day/$dayOfWeek';
  static String scheduleByLocation(int locationId) => '$schedule/location/$locationId';

  // Report endpoints
  static String reportById(int id) => '$report/$id';
  static String reportByOrganization(int orgId) => '$report/organization/$orgId';
  static String reportByType(int typeId) => '$report/type/$typeId';

  // Location endpoints
  static String locationById(int id) => '$location/$id';

  // City endpoints
  static String cityById(int id) => '$city/$id';

  // Country endpoints
  static String countryById(int id) => '$country/$id';

  // Address endpoints
  static String addressById(int id) => '$address/$id';
}

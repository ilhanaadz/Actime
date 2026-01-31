/// API Configuration for Actime Desktop (Admin Panel)
///
/// This class contains all API-related configuration settings.
/// Toggle [useMockApi] to switch between mock and real API.
class ApiConfig {
  // Toggle this to switch between mock and real API
  // Set to false to use real backend API
  static const bool useMockApi = false;

  // Base URL for the API - Update this to match your backend server
  static const String baseUrl = 'http://localhost:5000';

  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Auth endpoints (backend: AuthController)
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String refreshToken = '/auth/refresh-token';
  static const String logout = '/auth/logout';
  static const String me = '/auth/me';

  // User endpoints (backend: UserController)
  static const String user = '/user';
  static String userById(int id) => '$user/$id';

  // Organization endpoints (backend: OrganizationController)
  static const String organization = '/organization';
  static String organizationById(int id) => '$organization/$id';

  // Event endpoints (backend: EventController)
  static const String event = '/event';
  static String eventById(int id) => '$event/$id';

  // Category endpoints (backend: CategoryController)
  static const String category = '/category';
  static String categoryById(int id) => '$category/$id';

  // Favorite endpoints (backend: FavoriteController)
  static const String favorite = '/favorite';
  static String favoriteById(int id) => '$favorite/$id';

  // Membership endpoints (backend: MembershipController)
  static const String membership = '/membership';
  static String membershipById(int id) => '$membership/$id';

  // Participation endpoints (backend: ParticipationController)
  static const String participation = '/participation';
  static String participationById(int id) => '$participation/$id';

  // Review endpoints (backend: ReviewController)
  static const String review = '/review';
  static String reviewById(int id) => '$review/$id';
  static String reviewByOrganization(int orgId) => '$review/organization/$orgId';
  static String reviewOrganizationAverage(int orgId) => '$review/organization/$orgId/average';

  // Notification endpoints (backend: NotificationController)
  static const String notification = '/notification';
  static String notificationById(int id) => '$notification/$id';
  static String notificationUnreadCount(int userId) => '$notification/unread-count/$userId';

  // Schedule endpoints (backend: ScheduleController)
  static const String schedule = '/schedule';
  static String scheduleById(int id) => '$schedule/$id';

  // Report endpoints (backend: ReportController)
  static const String report = '/report';
  static String reportById(int id) => '$report/$id';

  // Location endpoints (backend: LocationController)
  static const String location = '/location';
  static String locationById(int id) => '$location/$id';

  // City endpoints (backend: CityController)
  static const String city = '/city';
  static String cityById(int id) => '$city/$id';

  // Country endpoints (backend: CountryController)
  static const String country = '/country';
  static String countryById(int id) => '$country/$id';

  // Address endpoints (backend: AddressController)
  static const String address = '/address';
  static String addressById(int id) => '$address/$id';

  // Health check
  static const String health = '/health';

  // Helper method - no API version prefix needed
  static String get fullUrl => baseUrl;
}

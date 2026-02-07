/// API Configuration for Actime Mobile
///
/// This class contains all API-related configuration settings.
/// Toggle [useMockApi] to switch between mock and real API.
class ApiConfig {
  // Toggle this to switch between mock and real API
  // Set to false to use real backend API
  static const bool useMockApi = false;

  // Base URL for the API - Can be overridden at compile time
  // Default: http://10.0.2.2:5171 (Android emulator)
  // For Android emulator use: http://10.0.2.2:8080
  // For iOS simulator use: http://localhost:8080
  // For physical device use your computer's IP: http://192.168.x.x:8080
  //
  // To override at compile/run time, use:
  // flutter run --dart-define=BASE_URL=http://your-api-url:port
  // flutter build apk --dart-define=BASE_URL=http://your-api-url:port
  static const String baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'http://10.0.2.2:5171',
  );

  // SignalR Hub URL for real-time notifications
  static const String signalRHubUrl = '$baseUrl/notificationHub';

  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 60);
  static const Duration receiveTimeout = Duration(seconds: 60);

  // Auth endpoints (backend: AuthController)
  static const String login = '/login';
  static const String register = '/register';
  static const String refreshToken = '/refresh-token';
  static const String logout = '/logout';
  static const String me = '/me';
  static const String completeOrganization = '/complete-organization';
  static const String confirmEmail = '/confirm-email';
  static const String resendConfirmationEmail = '/resend-confirmation-email';
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';
  static const String changePassword = '/change-password';
  static const String deleteMyAccount = '/delete-my-account';

  // User endpoints (backend: UserController)
  static const String user = '/User';

  // Organization endpoints (backend: OrganizationController)
  static const String organization = '/Organization';

  // Event endpoints (backend: EventController)
  static const String event = '/Event';

  // Category endpoints (backend: CategoryController)
  static const String category = '/Category';

  // Favorite endpoints (backend: FavoriteController)
  static const String favorite = '/Favorite';

  // Membership endpoints (backend: MembershipController)
  static const String membership = '/Membership';

  // Enrollment endpoints (backend: EnrollmentController)
  static const String enrollments = '/Enrollment';

  // Participation endpoints (backend: ParticipationController)
  static const String participation = '/Participation';

  // Review endpoints (backend: ReviewController)
  static const String review = '/Review';

  // Notification endpoints (backend: NotificationController)
  static const String notification = '/Notification';

  // Schedule endpoints (backend: ScheduleController)
  static const String schedule = '/Schedule';

  // Report endpoints (backend: ReportController)
  static const String report = '/Report';

  // Location endpoints (backend: LocationController)
  static const String location = '/Location';

  // City endpoints (backend: CityController)
  static const String city = '/City';

  // Country endpoints (backend: CountryController)
  static const String country = '/Country';

  // Address endpoints (backend: AddressController)
  static const String address = '/Address';

  // Recommendation endpoints (backend: RecommendationController)
  static const String recommendations = '/api/recommendations';

  // Payment endpoints (backend: PaymentController)
  static const String payment = '/Payment';
  static const String paymentCreateIntent = '$payment/create-intent';

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
  static String membershipByOrganization(int organizationId) =>
      '$membership/organization/$organizationId';

  // Participation endpoints
  static String participationById(int id) => '$participation/$id';
  static String participationAttendanceStatus(int id, int statusId) =>
      '$participation/$id/attendance-status/$statusId';
  static String participationPaymentStatus(int id, int statusId) =>
      '$participation/$id/payment-status/$statusId';
  static String participationEventCount(int eventId) =>
      '$participation/event/$eventId/count';
  static String participationByUser(int userId) => '$participation/user/$userId';
  static String participationEventByUser(int userId) => '$participation/event/$userId';

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

  // Recommendation endpoints
  static String recommendedEvents(int userId, {int top = 5}) =>
      '$recommendations/events/$userId?top=$top';
}

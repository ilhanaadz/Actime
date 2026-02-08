/// API Configuration for Actime Desktop (Admin Panel)
///
/// This class contains all API-related configuration settings.
class ApiConfig {
  // Base URL for the API - Update this to match your backend server
  static const String baseUrl = 'http://localhost:5171';

  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

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

  // User endpoints (backend: UserController)
  static const String user = '/User';
  static String userById(int id) => '$user/$id';
  static String userProfile() => '$user/profile';

  // Organization endpoints (backend: OrganizationController)
  static const String organization = '/Organization';
  static String organizationById(int id) => '$organization/$id';
  static String organizationMy() => '$organization/my';

  // Event endpoints (backend: EventController)
  static const String event = '/Event';
  static String eventById(int id) => '$event/$id';

  // Category endpoints (backend: CategoryController)
  static const String category = '/Category';
  static String categoryById(int id) => '$category/$id';

  // Favorite endpoints (backend: FavoriteController)
  static const String favorite = '/Favorite';
  static String favoriteById(int id) => '$favorite/$id';

  // Membership endpoints (backend: MembershipController)
  static const String membership = '/Membership';
  static String membershipById(int id) => '$membership/$id';
  static String membershipByOrganization(int organizationId) =>
      '$membership/organization/$organizationId';

  // Enrollment endpoints (backend: EnrollmentController)
  static const String enrollments = '/Enrollment';

  // Participation endpoints (backend: ParticipationController)
  static const String participation = '/Participation';
  static String participationById(int id) => '$participation/$id';
  static String participationAttendanceStatus(int id, int statusId) =>
      '$participation/$id/attendance-status/$statusId';
  static String participationPaymentStatus(int id, int statusId) =>
      '$participation/$id/payment-status/$statusId';
  static String participationEventCount(int eventId) =>
      '$participation/event/$eventId/count';
  static String participationByUser(int userId) => '$participation/user/$userId';
  static String participationEventByUser(int userId) => '$participation/event/$userId';

  // Review endpoints (backend: ReviewController)
  static const String review = '/Review';
  static String reviewById(int id) => '$review/$id';
  static String reviewByOrganization(int orgId) => '$review/organization/$orgId';
  static String reviewOrganizationAverage(int orgId) =>
      '$review/organization/$orgId/average';
  static String reviewByUser(int userId) => '$review/user/$userId';

  // Notification endpoints (backend: NotificationController)
  static const String notification = '/Notification';
  static String notificationById(int id) => '$notification/$id';
  static String notificationMarkAsRead(int id) => '$notification/$id/mark-as-read';
  static String notificationMarkAllAsRead(int userId) =>
      '$notification/mark-all-as-read/$userId';
  static String notificationUnreadCount(int userId) =>
      '$notification/unread-count/$userId';

  // Schedule endpoints (backend: ScheduleController)
  static const String schedule = '/Schedule';
  static String scheduleById(int id) => '$schedule/$id';
  static String scheduleByOrganization(int orgId) => '$schedule/organization/$orgId';
  static String scheduleByDay(int dayOfWeek) => '$schedule/day/$dayOfWeek';
  static String scheduleByLocation(int locationId) => '$schedule/location/$locationId';

  // Report endpoints (backend: ReportController)
  static const String report = '/Report';
  static String reportById(int id) => '$report/$id';
  static String reportByOrganization(int orgId) => '$report/organization/$orgId';
  static String reportByType(int typeId) => '$report/type/$typeId';

  // Location endpoints (backend: LocationController)
  static const String location = '/Location';
  static String locationById(int id) => '$location/$id';

  // City endpoints (backend: CityController)
  static const String city = '/City';
  static String cityById(int id) => '$city/$id';

  // Country endpoints (backend: CountryController)
  static const String country = '/Country';
  static String countryById(int id) => '$country/$id';

  // Address endpoints (backend: AddressController)
  static const String address = '/Address';
  static String addressById(int id) => '$address/$id';

  // Recommendation endpoints (backend: RecommendationController)
  static const String recommendations = '/api/recommendations';
  static String recommendedEvents(int userId, {int top = 5}) =>
      '$recommendations/events/$userId?top=$top';

  // Health check
  static const String health = '/health';

  // Helper method - no API version prefix needed
  static String fullUrl(String endpoint) => '$baseUrl$endpoint';
}

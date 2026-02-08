import '../config/api_config.dart';
import '../models/models.dart';
import 'api_service.dart';
import 'signalr_service.dart';
import 'token_service.dart';
import 'navigation_service.dart';

/// Authentication service
/// Handles login, register, logout, and token management
class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal() {
    _setupApiCallbacks();
  }

  final ApiService _apiService = ApiService();
  final TokenService _tokenService = TokenService();
  final SignalRService _signalRService = SignalRService();
  final NavigationService _navigationService = NavigationService();

  AuthResponse? _currentAuth;

  /// Setup callbacks for ApiService to handle token expiration
  void _setupApiCallbacks() {
    _apiService.onTokenRefresh = () async {
      if (!isLoggedIn) return false;

      try {
        final response = await refreshToken();
        return response.success;
      } catch (e) {
        return false;
      }
    };

    _apiService.onAuthenticationFailed = () async {
      await _handleExpiredSession();
    };
  }

  bool _isLoggingOut = false;

  /// Handle expired session - logout and navigate to login
  Future<void> _handleExpiredSession() async {
    if (!isLoggedIn || _isLoggingOut) return;

    _isLoggingOut = true;

    try {
      await logout();

      _navigationService.navigateToAndClearStack('/sign-in');
    } finally {
      _isLoggingOut = false;
    }
  }

  AuthResponse? get currentAuth => _currentAuth;

  int? get currentUserId => _currentAuth?.userId;

  String? get currentUserIdString => _currentAuth?.id;

  User? get currentUser => _currentAuth?.user;

  bool get isLoggedIn => _currentAuth != null;

  bool get isAdmin => _currentAuth?.isAdmin ?? false;

  bool get isOrganization => _currentAuth?.isOrganization ?? false;

  Future<ApiResponse<AuthResponse>> login(String emailOrUsername, String password) async {
    final response = await _apiService.post<AuthResponse>(
      ApiConfig.login,
      body: {'EmailOrUsername': emailOrUsername, 'Password': password},
      fromJson: (json) => AuthResponse.fromJson(json),
    );

    if (response.success && response.data != null) {
      _currentAuth = response.data;
      await _tokenService.saveTokens(
        accessToken: response.data!.accessToken,
        refreshToken: response.data!.refreshToken,
        expiry: response.data!.expiresAt,
      );

      // Connect to SignalR for real-time notifications
      await _signalRService.connect(response.data!.userId);
    }

    return response;
  }

  Future<ApiResponse<AuthResponse>> register(RegisterRequest request) async {
    final response = await _apiService.post<AuthResponse>(
      ApiConfig.register,
      body: request.toJson(),
      fromJson: (json) => AuthResponse.fromJson(json),
    );

    if (response.success && response.data != null) {
      _currentAuth = response.data;
      await _tokenService.saveTokens(
        accessToken: response.data!.accessToken,
        refreshToken: response.data!.refreshToken,
        expiry: response.data!.expiresAt,
      );
    }

    return response;
  }

  Future<void> logout() async {
    // Disconnect from SignalR
    await _signalRService.disconnect();

    await _apiService.post<Map<String, dynamic>>(
      ApiConfig.logout,
      fromJson: (json) => json,
    );

    _currentAuth = null;
    await _tokenService.clearTokens();
  }

  Future<ApiResponse<AuthResponse>> refreshToken() async {
    final response = await _apiService.post<AuthResponse>(
      ApiConfig.refreshToken,
      fromJson: (json) => AuthResponse.fromJson(json),
    );

    if (response.success && response.data != null) {
      _currentAuth = response.data;
      await _tokenService.saveTokens(
        accessToken: response.data!.accessToken,
        refreshToken: response.data!.refreshToken,
        expiry: response.data!.expiresAt,
      );
    }

    return response;
  }

  Future<ApiResponse<AuthResponse>> getCurrentUser() async {
    final response = await _apiService.get<AuthResponse>(
      ApiConfig.me,
      fromJson: (json) => AuthResponse.fromJson(json),
    );

    if (response.success && response.data != null) {
      _currentAuth = response.data;

      // Connect to SignalR for real-time notifications
      await _signalRService.connect(response.data!.userId);
    }

    return response;
  }

  Future<bool> hasValidSession() async {
    return await _tokenService.hasValidToken();
  }

  Future<ApiResponse<AuthResponse>?> loadCurrentUser() async {
    final hasToken = await _tokenService.hasValidToken();
    if (!hasToken) return null;

    return await getCurrentUser();
  }

  Future<ApiResponse<AuthResponse>> completeOrganization(
    CompleteOrganizationRequest request,
  ) async {
    final requestData = request.toJson();
    if (requestData.containsKey('LogoUrl')) {
      final path = requestData['LogoUrl'] as String?;
      if (path != null && !path.startsWith(RegExp(r'https?:\/\/'))) {
        requestData['LogoUrl'] = '${ApiConfig.baseUrl}$path';
      }
    }

    final response = await _apiService.post<AuthResponse>(
      ApiConfig.completeOrganization,
      body: requestData,
      fromJson: (json) => AuthResponse.fromJson(json),
    );

    if (response.success && response.data != null) {
      _currentAuth = response.data;
    }

    return response;
  }

  Future<ApiResponse<Map<String, dynamic>>> changePassword(
    ChangePasswordRequest request,
  ) async {
    return await _apiService.post<Map<String, dynamic>>(
      ApiConfig.changePassword,
      body: request.toJson(),
      fromJson: (json) => json,
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> forgotPassword(String email) async {
    return await _apiService.post<Map<String, dynamic>>(
      ApiConfig.forgotPassword,
      body: {'Email': email},
      fromJson: (json) => json,
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> resetPassword(
    ResetPasswordRequest request,
  ) async {
    return await _apiService.post<Map<String, dynamic>>(
      ApiConfig.resetPassword,
      body: request.toJson(),
      fromJson: (json) => json,
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> confirmEmail(
    ConfirmEmailRequest request,
  ) async {
    return await _apiService.post<Map<String, dynamic>>(
      ApiConfig.confirmEmail,
      body: request.toJson(),
      fromJson: (json) => json,
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> resendConfirmationEmail(
    String email,
  ) async {
    return await _apiService.post<Map<String, dynamic>>(
      ApiConfig.resendConfirmationEmail,
      body: {'Email': email},
      fromJson: (json) => json,
    );
  }

  Future<ApiResponse<void>> deleteMyAccount({bool hardDelete = false}) async {
    final endpoint = hardDelete
        ? '${ApiConfig.deleteMyAccount}?hardDelete=true'
        : ApiConfig.deleteMyAccount;

    final response = await _apiService.delete(endpoint);

    if (response.success) {
      _currentAuth = null;
      await _tokenService.clearTokens();
      await _signalRService.disconnect();
    }

    return response;
  }
}

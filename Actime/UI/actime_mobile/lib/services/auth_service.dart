import '../config/api_config.dart';
import '../models/models.dart';
import 'api_service.dart';
import 'mock_api_service.dart';
import 'signalr_service.dart';
import 'token_service.dart';

/// Authentication service
/// Handles login, register, logout, and token management
class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final ApiService _apiService = ApiService();
  final MockApiService _mockService = MockApiService();
  final TokenService _tokenService = TokenService();
  final SignalRService _signalRService = SignalRService();

  AuthResponse? _currentAuth;

  /// Get current auth response
  AuthResponse? get currentAuth => _currentAuth;

  /// Get current user ID
  int? get currentUserId => _currentAuth?.userId;

  /// Get current user ID as String
  String? get currentUserIdString => _currentAuth?.id;

  /// Get current user
  User? get currentUser => _currentAuth?.user;

  /// Check if user is logged in
  bool get isLoggedIn => _currentAuth != null;

  /// Check if user is admin
  bool get isAdmin => _currentAuth?.isAdmin ?? false;

  /// Check if user is organization
  bool get isOrganization => _currentAuth?.isOrganization ?? false;

  /// Login with email and password
  Future<ApiResponse<AuthResponse>> login(String email, String password) async {
    ApiResponse<AuthResponse> response;

    if (ApiConfig.useMockApi) {
      response = await _mockService.login(email, password);
    } else {
      response = await _apiService.post<AuthResponse>(
        ApiConfig.login,
        body: {'Email': email, 'Password': password},
        fromJson: (json) => AuthResponse.fromJson(json),
      );
    }

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

  /// Register new user
  Future<ApiResponse<AuthResponse>> register(RegisterRequest request) async {
    ApiResponse<AuthResponse> response;

    if (ApiConfig.useMockApi) {
      response = await _mockService.register(request);
    } else {
      response = await _apiService.post<AuthResponse>(
        ApiConfig.register,
        body: request.toJson(),
        fromJson: (json) => AuthResponse.fromJson(json),
      );
    }

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

  /// Logout
  Future<void> logout() async {
    // Disconnect from SignalR
    await _signalRService.disconnect();

    if (!ApiConfig.useMockApi) {
      // Call backend logout endpoint
      await _apiService.post<Map<String, dynamic>>(
        ApiConfig.logout,
        fromJson: (json) => json,
      );
    }
    _currentAuth = null;
    await _tokenService.clearTokens();
  }

  /// Refresh access token
  Future<ApiResponse<AuthResponse>> refreshToken() async {
    if (ApiConfig.useMockApi) {
      return ApiResponse.error('Mock API ne podržava refresh token');
    }

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

  /// Get current user info from /auth/me
  Future<ApiResponse<AuthResponse>> getCurrentUser() async {
    if (ApiConfig.useMockApi) {
      return await _mockService.getCurrentUserAuth();
    }

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

  /// Check if user has valid session
  Future<bool> hasValidSession() async {
    return await _tokenService.hasValidToken();
  }

  /// Load current user from stored token
  Future<ApiResponse<AuthResponse>?> loadCurrentUser() async {
    final hasToken = await _tokenService.hasValidToken();
    if (!hasToken) return null;

    return await getCurrentUser();
  }

  /// Complete organization setup
  Future<ApiResponse<AuthResponse>> completeOrganization(
    CompleteOrganizationRequest request,
  ) async {
    if (ApiConfig.useMockApi) {
      return ApiResponse.error('Mock API ne podržava ovu funkciju');
    }

    final response = await _apiService.post<AuthResponse>(
      ApiConfig.completeOrganization,
      body: request.toJson(),
      fromJson: (json) => AuthResponse.fromJson(json),
    );

    if (response.success && response.data != null) {
      _currentAuth = response.data;
    }

    return response;
  }

  /// Change password
  Future<ApiResponse<Map<String, dynamic>>> changePassword(
    ChangePasswordRequest request,
  ) async {
    if (ApiConfig.useMockApi) {
      return ApiResponse.success({'message': 'Lozinka je uspješno promijenjena'});
    }

    return await _apiService.post<Map<String, dynamic>>(
      ApiConfig.changePassword,
      body: request.toJson(),
      fromJson: (json) => json,
    );
  }

  /// Forgot password - request reset email
  Future<ApiResponse<Map<String, dynamic>>> forgotPassword(String email) async {
    if (ApiConfig.useMockApi) {
      return ApiResponse.success({'message': 'Email za resetiranje lozinke je poslan'});
    }

    return await _apiService.post<Map<String, dynamic>>(
      ApiConfig.forgotPassword,
      body: {'Email': email},
      fromJson: (json) => json,
    );
  }

  /// Reset password with token
  Future<ApiResponse<Map<String, dynamic>>> resetPassword(
    ResetPasswordRequest request,
  ) async {
    if (ApiConfig.useMockApi) {
      return ApiResponse.success({'message': 'Lozinka je uspješno resetirana'});
    }

    return await _apiService.post<Map<String, dynamic>>(
      ApiConfig.resetPassword,
      body: request.toJson(),
      fromJson: (json) => json,
    );
  }
}

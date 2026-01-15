import '../config/api_config.dart';
import '../models/models.dart';
import 'api_service.dart';
import 'mock_api_service.dart';
import 'token_service.dart';

/// Authentication service
class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final ApiService _apiService = ApiService();
  final MockApiService _mockService = MockApiService();
  final TokenService _tokenService = TokenService();

  User? _currentUser;

  /// Get current logged in user
  User? get currentUser => _currentUser;

  /// Check if user is logged in
  bool get isLoggedIn => _currentUser != null;

  /// Login with email and password
  Future<ApiResponse<AuthResponse>> login(String email, String password) async {
    ApiResponse<AuthResponse> response;

    if (ApiConfig.useMockApi) {
      response = await _mockService.login(email, password);
    } else {
      response = await _apiService.post<AuthResponse>(
        ApiConfig.login,
        body: {'email': email, 'password': password},
        fromJson: (json) => AuthResponse.fromJson(json),
      );
    }

    if (response.success && response.data != null) {
      _currentUser = response.data!.user;
      await _tokenService.saveTokens(
        accessToken: response.data!.accessToken,
        refreshToken: response.data!.refreshToken,
        expiry: response.data!.expiresAt,
      );
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
      _currentUser = response.data!.user;
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
    _currentUser = null;
    await _tokenService.clearTokens();
  }

  /// Check if user has valid session
  Future<bool> hasValidSession() async {
    return await _tokenService.hasValidToken();
  }

  /// Load current user from stored token
  Future<ApiResponse<User>?> loadCurrentUser() async {
    final hasToken = await _tokenService.hasValidToken();
    if (!hasToken) return null;

    ApiResponse<User> response;

    if (ApiConfig.useMockApi) {
      response = await _mockService.getCurrentUser();
    } else {
      response = await _apiService.get<User>(
        ApiConfig.userProfile,
        fromJson: (json) => User.fromJson(json),
      );
    }

    if (response.success && response.data != null) {
      _currentUser = response.data;
    }

    return response;
  }
}

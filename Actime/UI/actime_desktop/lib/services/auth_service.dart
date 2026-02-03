import '../config/api_config.dart';
import '../models/models.dart';
import 'api_service.dart';
import 'token_service.dart';
import 'mock_api_service.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final ApiService _apiService = ApiService();
  final MockApiService _mockService = MockApiService();
  final TokenService _tokenService = TokenService();

  User? _currentUser;
  User? get currentUser => _currentUser;

  Future<ApiResponse<AuthResponse>> login({
    required String email,
    required String password,
  }) async {
    // Use mock API if enabled
    if (ApiConfig.useMockApi) {
      final response = await _mockService.login(email, password);
      if (response.success && response.data != null) {
        await _tokenService.saveTokens(
          accessToken: response.data!.accessToken,
          refreshToken: response.data!.refreshToken,
          expiry: response.data!.expiresAt,
        );
        _currentUser = response.data!.user;
      }
      return response;
    }

    final response = await _apiService.post<AuthResponse>(
      ApiConfig.login,
      body: {
        'Email': email,
        'Password': password,
      },
      requiresAuth: false,
      fromJson: (json) => AuthResponse.fromJson(json),
    );

    if (response.success && response.data != null) {
      await _tokenService.saveTokens(
        accessToken: response.data!.accessToken,
        refreshToken: response.data!.refreshToken,
        expiry: response.data!.expiresAt,
      );
      _currentUser = response.data!.user;
    }

    return response;
  }

  Future<ApiResponse<void>> logout() async {
    await _tokenService.clearTokens();
    _currentUser = null;

    if (ApiConfig.useMockApi) {
      return ApiResponse(success: true, statusCode: 200);
    }

    return await _apiService.post<void>(
      ApiConfig.logout,
      requiresAuth: true,
    );
  }

  Future<bool> isAuthenticated() async {
    return await _tokenService.hasValidToken();
  }

  Future<ApiResponse<AuthResponse>> refreshToken() async {
    final refreshToken = await _tokenService.getRefreshToken();

    if (refreshToken == null) {
      return ApiResponse<AuthResponse>(
        success: false,
        message: 'No refresh token available',
        statusCode: 401,
      );
    }

    final response = await _apiService.post<AuthResponse>(
      ApiConfig.refreshToken,
      body: {'RefreshToken': refreshToken},
      requiresAuth: false,
      fromJson: (json) => AuthResponse.fromJson(json),
    );

    if (response.success && response.data != null) {
      await _tokenService.saveTokens(
        accessToken: response.data!.accessToken,
        refreshToken: response.data!.refreshToken,
        expiry: response.data!.expiresAt,
      );
    }

    return response;
  }

  void setCurrentUser(User user) {
    _currentUser = user;
  }

  void clearCurrentUser() {
    _currentUser = null;
  }
}

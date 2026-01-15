import 'package:shared_preferences/shared_preferences.dart';

/// Service for managing authentication tokens
class TokenService {
  static final TokenService _instance = TokenService._internal();
  factory TokenService() => _instance;
  TokenService._internal();

  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _tokenExpiryKey = 'token_expiry';

  SharedPreferences? _prefs;

  /// Initialize shared preferences
  Future<void> _ensureInitialized() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// Save access token
  Future<void> saveAccessToken(String token) async {
    await _ensureInitialized();
    await _prefs!.setString(_accessTokenKey, token);
  }

  /// Get access token
  Future<String?> getAccessToken() async {
    await _ensureInitialized();
    return _prefs!.getString(_accessTokenKey);
  }

  /// Save refresh token
  Future<void> saveRefreshToken(String token) async {
    await _ensureInitialized();
    await _prefs!.setString(_refreshTokenKey, token);
  }

  /// Get refresh token
  Future<String?> getRefreshToken() async {
    await _ensureInitialized();
    return _prefs!.getString(_refreshTokenKey);
  }

  /// Save token expiry time
  Future<void> saveTokenExpiry(DateTime expiry) async {
    await _ensureInitialized();
    await _prefs!.setString(_tokenExpiryKey, expiry.toIso8601String());
  }

  /// Get token expiry time
  Future<DateTime?> getTokenExpiry() async {
    await _ensureInitialized();
    final expiryString = _prefs!.getString(_tokenExpiryKey);
    if (expiryString != null) {
      return DateTime.parse(expiryString);
    }
    return null;
  }

  /// Save all tokens at once
  Future<void> saveTokens({
    required String accessToken,
    String? refreshToken,
    DateTime? expiry,
  }) async {
    await saveAccessToken(accessToken);
    if (refreshToken != null) {
      await saveRefreshToken(refreshToken);
    }
    if (expiry != null) {
      await saveTokenExpiry(expiry);
    }
  }

  /// Check if token exists and is valid
  Future<bool> hasValidToken() async {
    final token = await getAccessToken();
    if (token == null) return false;

    final expiry = await getTokenExpiry();
    if (expiry != null && expiry.isBefore(DateTime.now())) {
      return false;
    }

    return true;
  }

  /// Clear all tokens (logout)
  Future<void> clearTokens() async {
    await _ensureInitialized();
    await _prefs!.remove(_accessTokenKey);
    await _prefs!.remove(_refreshTokenKey);
    await _prefs!.remove(_tokenExpiryKey);
  }
}

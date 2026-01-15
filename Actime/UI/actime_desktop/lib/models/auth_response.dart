import 'user.dart';

class AuthResponse {
  final String accessToken;
  final String? refreshToken;
  final DateTime? expiresAt;
  final User? user;

  AuthResponse({
    required this.accessToken,
    this.refreshToken,
    this.expiresAt,
    this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    DateTime? expiresAt;

    if (json['expires_at'] != null) {
      expiresAt = DateTime.tryParse(json['expires_at']);
    } else if (json['expires_in'] != null) {
      expiresAt = DateTime.now().add(
        Duration(seconds: json['expires_in']),
      );
    }

    return AuthResponse(
      accessToken: json['access_token'] ?? json['accessToken'] ?? json['token'] ?? '',
      refreshToken: json['refresh_token'] ?? json['refreshToken'],
      expiresAt: expiresAt,
      user: json['user'] != null ? User.fromJson(json['user']) : null,
    );
  }
}

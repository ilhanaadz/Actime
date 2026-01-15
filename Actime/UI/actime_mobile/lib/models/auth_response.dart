import 'user.dart';

/// Authentication response containing user and tokens
class AuthResponse {
  final User user;
  final String accessToken;
  final String? refreshToken;
  final DateTime? expiresAt;

  AuthResponse({
    required this.user,
    required this.accessToken,
    this.refreshToken,
    this.expiresAt,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      user: User.fromJson(json['user'] as Map<String, dynamic>),
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String?,
      expiresAt: json['expiresAt'] != null
          ? DateTime.parse(json['expiresAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': user.toJson(),
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'expiresAt': expiresAt?.toIso8601String(),
    };
  }
}

/// Registration request data
class RegisterRequest {
  final String name;
  final String email;
  final String password;
  final String? phone;
  final UserRole role;

  RegisterRequest({
    required this.name,
    required this.email,
    required this.password,
    this.phone,
    this.role = UserRole.user,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'password': password,
      'phone': phone,
      'role': role.value,
    };
  }
}

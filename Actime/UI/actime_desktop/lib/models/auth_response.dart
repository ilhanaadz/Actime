import 'organization.dart';

/// Authentication response from backend
/// Maps to backend AuthResponse
class AuthResponse {
  final int userId;
  final String email;
  final String? firstName;
  final String? lastName;
  final String accessToken;
  final String refreshToken;
  final DateTime expiresAt;
  final List<String> roles;
  final bool requiresOrganizationSetup;
  final Organization? organization;

  AuthResponse({
    required this.userId,
    required this.email,
    this.firstName,
    this.lastName,
    required this.accessToken,
    required this.refreshToken,
    required this.expiresAt,
    required this.roles,
    this.requiresOrganizationSetup = false,
    this.organization,
  });

  /// Get full name
  String get fullName {
    if (firstName != null && lastName != null) {
      return '$firstName $lastName';
    }
    if (firstName != null) return firstName!;
    if (lastName != null) return lastName!;
    return email;
  }

  /// Check if user has a specific role
  bool hasRole(String role) => roles.contains(role);

  /// Check if user is admin
  bool get isAdmin => hasRole('Admin');

  /// Check if user is organization
  bool get isOrganization => hasRole('Organization');

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      userId: _parseInt(json['UserId'] ?? json['userId']) ?? 0,
      email: json['Email'] as String? ?? json['email'] as String? ?? '',
      firstName: json['FirstName'] as String? ?? json['firstName'] as String?,
      lastName: json['LastName'] as String? ?? json['lastName'] as String?,
      accessToken: json['AccessToken'] as String? ?? json['accessToken'] as String? ?? '',
      refreshToken: json['RefreshToken'] as String? ?? json['refreshToken'] as String? ?? '',
      expiresAt: _parseDateTime(json['ExpiresAt'] ?? json['expiresAt']) ?? DateTime.now(),
      roles: _parseStringList(json['Roles'] ?? json['roles']),
      requiresOrganizationSetup:
          json['RequiresOrganizationSetup'] as bool? ??
          json['requiresOrganizationSetup'] as bool? ??
          false,
      organization: json['Organization'] != null
          ? Organization.fromJson(json['Organization'] as Map<String, dynamic>)
          : json['organization'] != null
              ? Organization.fromJson(json['organization'] as Map<String, dynamic>)
              : null,
    );
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  static List<String> _parseStringList(dynamic value) {
    if (value == null) return [];
    if (value is List) {
      return value.map((e) => e.toString()).toList();
    }
    return [];
  }

  Map<String, dynamic> toJson() {
    return {
      'UserId': userId,
      'Email': email,
      'FirstName': firstName,
      'LastName': lastName,
      'AccessToken': accessToken,
      'RefreshToken': refreshToken,
      'ExpiresAt': expiresAt.toIso8601String(),
      'Roles': roles,
      'RequiresOrganizationSetup': requiresOrganizationSetup,
      'Organization': organization?.toJson(),
    };
  }
}

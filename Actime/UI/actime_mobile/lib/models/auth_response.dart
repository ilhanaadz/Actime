import 'organization.dart';
import 'user.dart';

/// Authentication response from backend
/// Maps to backend AuthResponse
class AuthResponse {
  final String id;
  final String email;
  final String? firstName;
  final String? lastName;
  final String? name;
  final String accessToken;
  final String refreshToken;
  final DateTime expiresAt;
  final List<String> roles;
  final bool requiresOrganizationSetup;
  final Organization? organization;

  AuthResponse({
    required this.id,
    required this.email,
    this.firstName,
    this.lastName,
    this.name,
    required this.accessToken,
    required this.refreshToken,
    required this.expiresAt,
    required this.roles,
    this.requiresOrganizationSetup = false,
    this.organization,
  });

  /// Get full name
  String get fullName {
    if (name != null && name!.isNotEmpty) return name!;
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
  bool get isAdmin => hasRole('Admin') || hasRole('admin');

  /// Check if user is organization
  bool get isOrganization => hasRole('Organization') || hasRole('organization');

  /// Get user role
  UserRole get role {
    if (isAdmin) return UserRole.admin;
    if (isOrganization) return UserRole.organizer;
    return UserRole.user;
  }

  /// Get user object from auth response
  User get user {
    return User(
      id: id,
      name: fullName,
      email: email,
      role: role,
      createdAt: DateTime.now(),
      firstName: firstName,
      lastName: lastName,
    );
  }

  /// Legacy getter for userId
  int get userId => int.tryParse(id) ?? 0;

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      id: (json['UserId'] ?? json['userId'] ?? json['Id'] ?? json['id'])?.toString() ?? '0',
      email: json['Email'] as String? ?? json['email'] as String? ?? '',
      firstName: json['FirstName'] as String? ?? json['firstName'] as String?,
      lastName: json['LastName'] as String? ?? json['lastName'] as String?,
      name: json['Name'] as String? ?? json['name'] as String?,
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
      'UserId': id,
      'Id': id,
      'Email': email,
      'FirstName': firstName,
      'LastName': lastName,
      'Name': name ?? fullName,
      'AccessToken': accessToken,
      'RefreshToken': refreshToken,
      'ExpiresAt': expiresAt.toIso8601String(),
      'Roles': roles,
      'RequiresOrganizationSetup': requiresOrganizationSetup,
      'Organization': organization?.toJson(),
    };
  }
}

/// Registration request data
class RegisterRequest {
  final String name;
  final String email;
  final String password;
  final String confirmPassword;
  final UserRole role;
  final bool isOrganization;
  final DateTime? dateOfBirth;

  // Legacy field aliases
  final String? username;

  RegisterRequest({
    required this.name,
    required this.email,
    required this.password,
    String? confirmPassword,
    this.role = UserRole.user,
    bool? isOrganization,
    this.dateOfBirth,
    this.username,
  }) : confirmPassword = confirmPassword ?? password,
       isOrganization = isOrganization ?? (role == UserRole.organizer);

  Map<String, dynamic> toJson() {
    return {
      'Username': username ?? email,
      'Name': name,
      'Email': email,
      'Password': password,
      'ConfirmPassword': confirmPassword,
      'IsOrganization': isOrganization,
      'Role': role.name,
      'DateOfBirth': dateOfBirth?.toIso8601String(),
    };
  }
}

/// Login request data
class LoginRequest {
  final String email;
  final String password;

  LoginRequest({
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'Email': email,
      'Password': password,
    };
  }
}

/// Complete organization setup request
class CompleteOrganizationRequest {
  final String name;
  final String? description;
  final String? logoUrl;
  final String? phoneNumber;
  final int categoryId;
  final int? addressId;

  CompleteOrganizationRequest({
    required this.name,
    this.description,
    this.logoUrl,
    this.phoneNumber,
    required this.categoryId,
    this.addressId,
  });

  Map<String, dynamic> toJson() {
    return {
      'Name': name,
      'Description': description,
      'LogoUrl': logoUrl,
      'PhoneNumber': phoneNumber,
      'CategoryId': categoryId,
      'AddressId': addressId,
    };
  }
}

/// Change password request
class ChangePasswordRequest {
  final String currentPassword;
  final String newPassword;
  final String confirmNewPassword;

  ChangePasswordRequest({
    required this.currentPassword,
    required this.newPassword,
    required this.confirmNewPassword,
  });

  Map<String, dynamic> toJson() {
    return {
      'CurrentPassword': currentPassword,
      'NewPassword': newPassword,
      'ConfirmPassword': confirmNewPassword,
    };
  }
}

/// Forgot password request
class ForgotPasswordRequest {
  final String email;

  ForgotPasswordRequest({required this.email});

  Map<String, dynamic> toJson() => {'Email': email};
}

/// Reset password request
class ResetPasswordRequest {
  final String email;
  final String token;
  final String newPassword;
  final String confirmPassword;

  ResetPasswordRequest({
    required this.email,
    required this.token,
    required this.newPassword,
    required this.confirmPassword,
  });

  Map<String, dynamic> toJson() {
    return {
      'Email': email,
      'Token': token,
      'NewPassword': newPassword,
      'ConfirmPassword': confirmPassword,
    };
  }
}

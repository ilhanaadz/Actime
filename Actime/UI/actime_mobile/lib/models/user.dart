/// User role enum
enum UserRole {
  user,
  organizer,
  admin;

  static UserRole fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'organizer':
      case 'organization':
        return UserRole.organizer;
      case 'admin':
        return UserRole.admin;
      default:
        return UserRole.user;
    }
  }

  String get displayName {
    switch (this) {
      case UserRole.user:
        return 'Korisnik';
      case UserRole.organizer:
        return 'Organizator';
      case UserRole.admin:
        return 'Administrator';
    }
  }
}

/// User model representing an application user
/// Maps to backend User entity
class User {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? bio;
  final String? profileImageUrl;
  final String? address;
  final UserRole role;
  final int organizationsCount;
  final int eventsCount;
  final DateTime? dateOfBirth;
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime? lastModifiedAt;

  // Backend field aliases
  final String? firstName;
  final String? lastName;
  final String? username;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.bio,
    this.profileImageUrl,
    this.address,
    this.role = UserRole.user,
    this.organizationsCount = 0,
    this.eventsCount = 0,
    this.dateOfBirth,
    this.isDeleted = false,
    required this.createdAt,
    this.lastModifiedAt,
    this.firstName,
    this.lastName,
    this.username,
  });

  /// Alias for profileImageUrl
  String? get avatar => profileImageUrl;

  /// Get full name (for compatibility)
  String get fullName => name.isNotEmpty ? name : (username ?? email);

  /// Get display name (prefer full name, fallback to username)
  String get displayName => fullName;

  factory User.fromJson(Map<String, dynamic> json) {
    // Parse ID - can be int or String
    final id = (json['Id'] ?? json['id'])?.toString() ?? '0';

    // Parse name - can be direct 'name' or combined firstName/lastName
    final firstName = json['FirstName'] as String? ?? json['firstName'] as String?;
    final lastName = json['LastName'] as String? ?? json['lastName'] as String?;
    final directName = json['Name'] as String? ?? json['name'] as String?;

    String name;
    if (directName != null && directName.isNotEmpty) {
      name = directName;
    } else if (firstName != null || lastName != null) {
      name = [firstName, lastName].where((s) => s != null && s.isNotEmpty).join(' ');
    } else {
      name = json['Username'] as String? ?? json['username'] as String? ?? '';
    }

    // Parse role from string or list of roles
    UserRole role = UserRole.user;
    if (json['Role'] != null || json['role'] != null) {
      role = UserRole.fromString((json['Role'] ?? json['role'])?.toString());
    } else if (json['Roles'] != null || json['roles'] != null) {
      final roles = json['Roles'] ?? json['roles'];
      if (roles is List && roles.isNotEmpty) {
        if (roles.contains('Admin') || roles.contains('admin')) {
          role = UserRole.admin;
        } else if (roles.contains('Organization') || roles.contains('organization') ||
                   roles.contains('Organizer') || roles.contains('organizer')) {
          role = UserRole.organizer;
        }
      }
    }

    return User(
      id: id,
      name: name,
      email: json['Email'] as String? ?? json['email'] as String? ?? '',
      phone: json['PhoneNumber'] as String? ?? json['phoneNumber'] as String? ??
             json['Phone'] as String? ?? json['phone'] as String?,
      bio: json['Bio'] as String? ?? json['bio'] as String?,
      profileImageUrl: json['ProfileImageUrl'] as String? ?? json['profileImageUrl'] as String? ??
                       json['Avatar'] as String? ?? json['avatar'] as String?,
      address: json['Address'] as String? ?? json['address'] as String?,
      role: role,
      organizationsCount: _parseInt(json['OrganizationsCount'] ?? json['organizationsCount']) ?? 0,
      eventsCount: _parseInt(json['EventsCount'] ?? json['eventsCount']) ?? 0,
      dateOfBirth: _parseDateTime(json['DateOfBirth'] ?? json['dateOfBirth']),
      isDeleted: json['IsDeleted'] as bool? ?? json['isDeleted'] as bool? ?? false,
      createdAt: _parseDateTime(json['CreatedAt'] ?? json['createdAt']) ?? DateTime.now(),
      lastModifiedAt: _parseDateTime(json['LastModifiedAt'] ?? json['lastModifiedAt']),
      firstName: firstName,
      lastName: lastName,
      username: json['Username'] as String? ?? json['username'] as String?,
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

  Map<String, dynamic> toJson() {
    return {
      'Id': id,
      'Name': name,
      'FirstName': firstName ?? name.split(' ').firstOrNull,
      'LastName': lastName ?? (name.split(' ').length > 1 ? name.split(' ').skip(1).join(' ') : null),
      'Username': username ?? email,
      'Email': email,
      'PhoneNumber': phone,
      'Phone': phone,
      'Bio': bio,
      'ProfileImageUrl': profileImageUrl,
      'Avatar': profileImageUrl,
      'Address': address,
      'Role': role.name,
      'OrganizationsCount': organizationsCount,
      'EventsCount': eventsCount,
      'DateOfBirth': dateOfBirth?.toIso8601String(),
      'IsDeleted': isDeleted,
      'CreatedAt': createdAt.toIso8601String(),
      'LastModifiedAt': lastModifiedAt?.toIso8601String(),
    };
  }

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? bio,
    String? profileImageUrl,
    String? address,
    UserRole? role,
    int? organizationsCount,
    int? eventsCount,
    DateTime? dateOfBirth,
    bool? isDeleted,
    DateTime? createdAt,
    DateTime? lastModifiedAt,
    String? firstName,
    String? lastName,
    String? username,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      bio: bio ?? this.bio,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      address: address ?? this.address,
      role: role ?? this.role,
      organizationsCount: organizationsCount ?? this.organizationsCount,
      eventsCount: eventsCount ?? this.eventsCount,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt ?? this.createdAt,
      lastModifiedAt: lastModifiedAt ?? this.lastModifiedAt,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      username: username ?? this.username,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

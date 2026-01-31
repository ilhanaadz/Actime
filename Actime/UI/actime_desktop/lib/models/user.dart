/// User model representing an application user
/// Maps to backend User entity
class User {
  final int id;
  final String? firstName;
  final String? lastName;
  final String username;
  final String email;
  final String? phoneNumber;
  final String? profileImageUrl;
  final DateTime? dateOfBirth;
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime? lastModifiedAt;

  User({
    required this.id,
    this.firstName,
    this.lastName,
    required this.username,
    required this.email,
    this.phoneNumber,
    this.profileImageUrl,
    this.dateOfBirth,
    this.isDeleted = false,
    required this.createdAt,
    this.lastModifiedAt,
  });

  /// Get full name
  String get fullName {
    if (firstName != null && lastName != null) {
      return '$firstName $lastName';
    }
    if (firstName != null) return firstName!;
    if (lastName != null) return lastName!;
    return username;
  }

  /// Get display name (prefer full name, fallback to username)
  String get displayName => fullName.isNotEmpty ? fullName : username;

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: _parseInt(json['Id'] ?? json['id']) ?? 0,
      firstName: json['FirstName'] as String? ?? json['firstName'] as String?,
      lastName: json['LastName'] as String? ?? json['lastName'] as String?,
      username: json['Username'] as String? ?? json['username'] as String? ?? '',
      email: json['Email'] as String? ?? json['email'] as String? ?? '',
      phoneNumber: json['PhoneNumber'] as String? ?? json['phoneNumber'] as String?,
      profileImageUrl: json['ProfileImageUrl'] as String? ?? json['profileImageUrl'] as String?,
      dateOfBirth: _parseDateTime(json['DateOfBirth'] ?? json['dateOfBirth']),
      isDeleted: json['IsDeleted'] as bool? ?? json['isDeleted'] as bool? ?? false,
      createdAt: _parseDateTime(json['CreatedAt'] ?? json['createdAt']) ?? DateTime.now(),
      lastModifiedAt: _parseDateTime(json['LastModifiedAt'] ?? json['lastModifiedAt']),
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
      'FirstName': firstName,
      'LastName': lastName,
      'Username': username,
      'Email': email,
      'PhoneNumber': phoneNumber,
      'ProfileImageUrl': profileImageUrl,
      'DateOfBirth': dateOfBirth?.toIso8601String(),
      'IsDeleted': isDeleted,
      'CreatedAt': createdAt.toIso8601String(),
      'LastModifiedAt': lastModifiedAt?.toIso8601String(),
    };
  }

  User copyWith({
    int? id,
    String? firstName,
    String? lastName,
    String? username,
    String? email,
    String? phoneNumber,
    String? profileImageUrl,
    DateTime? dateOfBirth,
    bool? isDeleted,
    DateTime? createdAt,
    DateTime? lastModifiedAt,
  }) {
    return User(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      username: username ?? this.username,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt ?? this.createdAt,
      lastModifiedAt: lastModifiedAt ?? this.lastModifiedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

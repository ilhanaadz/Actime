/// User model representing an application user
class User {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? avatar;
  final String? bio;
  final DateTime? dateOfBirth;
  final String? address;
  final UserRole role;
  final int organizationsCount;
  final int eventsCount;
  final DateTime createdAt;
  final DateTime? updatedAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.avatar,
    this.bio,
    this.dateOfBirth,
    this.address,
    this.role = UserRole.user,
    this.organizationsCount = 0,
    this.eventsCount = 0,
    required this.createdAt,
    this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      avatar: json['avatar'] as String?,
      bio: json['bio'] as String?,
      dateOfBirth: json['dateOfBirth'] != null
          ? DateTime.parse(json['dateOfBirth'] as String)
          : null,
      address: json['address'] as String?,
      role: UserRole.fromString(json['role'] as String? ?? 'user'),
      organizationsCount: json['organizationsCount'] as int? ?? 0,
      eventsCount: json['eventsCount'] as int? ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'avatar': avatar,
      'bio': bio,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'address': address,
      'role': role.value,
      'organizationsCount': organizationsCount,
      'eventsCount': eventsCount,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? avatar,
    String? bio,
    DateTime? dateOfBirth,
    String? address,
    UserRole? role,
    int? organizationsCount,
    int? eventsCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      avatar: avatar ?? this.avatar,
      bio: bio ?? this.bio,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      address: address ?? this.address,
      role: role ?? this.role,
      organizationsCount: organizationsCount ?? this.organizationsCount,
      eventsCount: eventsCount ?? this.eventsCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// User roles in the application
enum UserRole {
  user('user'),
  organizer('organizer'),
  admin('admin');

  final String value;
  const UserRole(this.value);

  static UserRole fromString(String value) {
    return UserRole.values.firstWhere(
      (role) => role.value == value,
      orElse: () => UserRole.user,
    );
  }
}

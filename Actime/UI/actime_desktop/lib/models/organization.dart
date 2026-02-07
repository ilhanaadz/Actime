/// Organization model representing a club/organization
/// Maps to backend Organization entity
class Organization {
  final int id;
  final String name;
  final String email;
  final String? description;
  final String? logoUrl;
  final String? phoneNumber;
  final int userId;
  final int categoryId;
  final int addressId;
  final DateTime createdAt;
  final DateTime? lastModifiedAt;

  // Additional properties from API responses
  final String? categoryName;
  final String? address;
  final String? website;
  final List<String>? gallery;
  final int? eventsCount;
  final int? membersCount;
  final bool emailConfirmed;

  Organization({
    required this.id,
    required this.name,
    required this.email,
    this.description,
    this.logoUrl,
    this.phoneNumber,
    required this.userId,
    required this.categoryId,
    required this.addressId,
    required this.createdAt,
    this.lastModifiedAt,
    this.categoryName,
    this.address,
    this.website,
    this.gallery,
    this.eventsCount,
    this.membersCount,
    this.emailConfirmed = false,
  });

  /// Alias for phoneNumber (used in admin screens)
  String? get phone => phoneNumber;

  /// Alias for logoUrl (used in admin screens)
  String? get logo => logoUrl;

  factory Organization.fromJson(Map<String, dynamic> json) {
    return Organization(
      id: _parseInt(json['Id'] ?? json['id']) ?? 0,
      name: json['Name'] as String? ?? json['name'] as String? ?? '',
      email: json['Email'] as String? ?? json['email'] as String? ?? '',
      description: json['Description'] as String? ?? json['description'] as String?,
      logoUrl: json['LogoUrl'] as String? ?? json['logoUrl'] as String?,
      phoneNumber: json['PhoneNumber'] as String? ?? json['phoneNumber'] as String?,
      userId: _parseInt(json['UserId'] ?? json['userId']) ?? 0,
      categoryId: _parseInt(json['CategoryId'] ?? json['categoryId']) ?? 0,
      addressId: _parseInt(json['AddressId'] ?? json['addressId']) ?? 0,
      createdAt: _parseDateTime(json['CreatedAt'] ?? json['createdAt']) ?? DateTime.now(),
      lastModifiedAt: _parseDateTime(json['LastModifiedAt'] ?? json['lastModifiedAt']),
      categoryName: json['CategoryName'] as String? ?? json['categoryName'] as String?,
      address: json['Address'] as String? ?? json['address'] as String?,
      website: json['Website'] as String? ?? json['website'] as String?,
      gallery: _parseStringList(json['Gallery'] ?? json['gallery']),
      eventsCount: _parseInt(json['EventsCount'] ?? json['eventsCount']),
      membersCount: _parseInt(json['MembersCount'] ?? json['membersCount']),
      emailConfirmed: json['EmailConfirmed'] as bool? ?? json['emailConfirmed'] as bool? ?? false,
    );
  }

  static List<String>? _parseStringList(dynamic value) {
    if (value == null) return null;
    if (value is List) {
      return value.map((e) => e.toString()).toList();
    }
    return null;
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
      'Email': email,
      'Description': description,
      'LogoUrl': logoUrl,
      'PhoneNumber': phoneNumber,
      'UserId': userId,
      'CategoryId': categoryId,
      'AddressId': addressId,
      'CreatedAt': createdAt.toIso8601String(),
      'LastModifiedAt': lastModifiedAt?.toIso8601String(),
      'CategoryName': categoryName,
      'Address': address,
      'Website': website,
      'Gallery': gallery,
      'EventsCount': eventsCount,
      'MembersCount': membersCount,
      'EmailConfirmed': emailConfirmed,
    };
  }

  Organization copyWith({
    int? id,
    String? name,
    String? email,
    String? description,
    String? logoUrl,
    String? phoneNumber,
    int? userId,
    int? categoryId,
    int? addressId,
    DateTime? createdAt,
    DateTime? lastModifiedAt,
    String? categoryName,
    String? address,
    String? website,
    List<String>? gallery,
    int? eventsCount,
    int? membersCount,
    bool? emailConfirmed,
  }) {
    return Organization(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      description: description ?? this.description,
      logoUrl: logoUrl ?? this.logoUrl,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      userId: userId ?? this.userId,
      categoryId: categoryId ?? this.categoryId,
      addressId: addressId ?? this.addressId,
      createdAt: createdAt ?? this.createdAt,
      lastModifiedAt: lastModifiedAt ?? this.lastModifiedAt,
      categoryName: categoryName ?? this.categoryName,
      address: address ?? this.address,
      website: website ?? this.website,
      gallery: gallery ?? this.gallery,
      eventsCount: eventsCount ?? this.eventsCount,
      membersCount: membersCount ?? this.membersCount,
      emailConfirmed: emailConfirmed ?? this.emailConfirmed,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Organization && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

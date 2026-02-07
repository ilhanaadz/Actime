/// Organization status enum
enum OrganizationStatus {
  pending,
  active,
  suspended,
  inactive;

  static OrganizationStatus fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'active':
        return OrganizationStatus.active;
      case 'suspended':
        return OrganizationStatus.suspended;
      case 'inactive':
        return OrganizationStatus.inactive;
      case 'pending':
      default:
        return OrganizationStatus.pending;
    }
  }

  String get displayName {
    switch (this) {
      case OrganizationStatus.pending:
        return 'Na čekanju';
      case OrganizationStatus.active:
        return 'Aktivna';
      case OrganizationStatus.suspended:
        return 'Suspendovana';
      case OrganizationStatus.inactive:
        return 'Neaktivna';
    }
  }
}

/// Organization model representing a club/organization
/// Maps to backend Organization entity
class Organization {
  final String id;
  final String name;
  final String email;
  final String? description;
  final String? logoUrl;
  final String? phone;
  final String? address;
  final String? website;
  final String? categoryId;
  final String? categoryName;
  final int membersCount;
  final int eventsCount;
  final bool isVerified;
  final bool isMember;
  final int? membershipStatusId;
  final OrganizationStatus status;
  final DateTime createdAt;
  final DateTime? lastModifiedAt;

  // Backend field aliases
  final int? userId;
  final int? addressId;

  Organization({
    required this.id,
    required this.name,
    required this.email,
    this.description,
    this.logoUrl,
    this.phone,
    this.address,
    this.website,
    this.categoryId,
    this.categoryName,
    this.membersCount = 0,
    this.eventsCount = 0,
    this.isVerified = false,
    this.isMember = false,
    this.membershipStatusId,
    this.status = OrganizationStatus.active,
    required this.createdAt,
    this.lastModifiedAt,
    this.userId,
    this.addressId,
  });

  /// Alias for logoUrl
  String? get logo => logoUrl;

  factory Organization.fromJson(Map<String, dynamic> json) {
    return Organization(
      id: (json['Id'] ?? json['id'])?.toString() ?? '0',
      name: json['Name'] as String? ?? json['name'] as String? ?? '',
      email: json['Email'] as String? ?? json['email'] as String? ?? '',
      description: json['Description'] as String? ?? json['description'] as String?,
      logoUrl: json['LogoUrl'] as String? ?? json['logoUrl'] as String?,
      phone: json['PhoneNumber'] as String? ?? json['phoneNumber'] as String? ??
             json['Phone'] as String? ?? json['phone'] as String?,
      address: json['Address'] as String? ?? json['address'] as String?,
      website: json['Website'] as String? ?? json['website'] as String?,
      categoryId: (json['CategoryId'] ?? json['categoryId'])?.toString(),
      categoryName: json['CategoryName'] as String? ?? json['categoryName'] as String?,
      membersCount: _parseInt(json['MembersCount'] ?? json['membersCount']) ?? 0,
      eventsCount: _parseInt(json['EventsCount'] ?? json['eventsCount']) ?? 0,
      isVerified: json['EmailConfirmed'] as bool? ?? json['emailConfirmed'] as bool? ??
                  json['IsVerified'] as bool? ?? json['isVerified'] as bool? ?? false,
      isMember: json['IsMember'] as bool? ?? json['isMember'] as bool? ?? false,
      membershipStatusId: _parseInt(json['MembershipStatusId'] ?? json['membershipStatusId']),
      status: OrganizationStatus.fromString(json['Status'] as String? ?? json['status'] as String?),
      createdAt: _parseDateTime(json['CreatedAt'] ?? json['createdAt']) ?? DateTime.now(),
      lastModifiedAt: _parseDateTime(json['LastModifiedAt'] ?? json['lastModifiedAt']),
      userId: _parseInt(json['UserId'] ?? json['userId']),
      addressId: _parseInt(json['AddressId'] ?? json['addressId']),
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
      'Email': email,
      'Description': description,
      'LogoUrl': logoUrl,
      'PhoneNumber': phone,
      'Phone': phone,
      'Address': address,
      'Website': website,
      'CategoryId': categoryId,
      'CategoryName': categoryName,
      'MembersCount': membersCount,
      'EventsCount': eventsCount,
      'EmailConfirmed': isVerified,
      'IsVerified': isVerified,
      'IsMember': isMember,
      'MembershipStatusId': membershipStatusId,
      'Logo': logoUrl,
      'Status': status.name,
      'CreatedAt': createdAt.toIso8601String(),
      'LastModifiedAt': lastModifiedAt?.toIso8601String(),
      'UserId': userId,
      'AddressId': addressId,
    };
  }

  Organization copyWith({
    String? id,
    String? name,
    String? email,
    String? description,
    String? logoUrl,
    String? phone,
    String? address,
    String? website,
    String? categoryId,
    String? categoryName,
    int? membersCount,
    int? eventsCount,
    bool? isVerified,
    bool? isMember,
    int? membershipStatusId,
    OrganizationStatus? status,
    DateTime? createdAt,
    DateTime? lastModifiedAt,
    int? userId,
    int? addressId,
  }) {
    return Organization(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      description: description ?? this.description,
      logoUrl: logoUrl ?? this.logoUrl,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      website: website ?? this.website,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      membersCount: membersCount ?? this.membersCount,
      eventsCount: eventsCount ?? this.eventsCount,
      isVerified: isVerified ?? this.isVerified,
      isMember: isMember ?? this.isMember,
      membershipStatusId: membershipStatusId ?? this.membershipStatusId,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      lastModifiedAt: lastModifiedAt ?? this.lastModifiedAt,
      userId: userId ?? this.userId,
      addressId: addressId ?? this.addressId,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Organization && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

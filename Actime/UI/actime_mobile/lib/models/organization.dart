/// Organization model representing a club/organization
class Organization {
  final String id;
  final String name;
  final String? description;
  final String? logo;
  final String? coverImage;
  final String? phone;
  final String? email;
  final String? address;
  final String? website;
  final String? categoryId;
  final String? categoryName;
  final int membersCount;
  final int eventsCount;
  final bool isVerified;
  final OrganizationStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Organization({
    required this.id,
    required this.name,
    this.description,
    this.logo,
    this.coverImage,
    this.phone,
    this.email,
    this.address,
    this.website,
    this.categoryId,
    this.categoryName,
    this.membersCount = 0,
    this.eventsCount = 0,
    this.isVerified = false,
    this.status = OrganizationStatus.active,
    required this.createdAt,
    this.updatedAt,
  });

  factory Organization.fromJson(Map<String, dynamic> json) {
    return Organization(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      logo: json['logo'] as String?,
      coverImage: json['coverImage'] as String?,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      address: json['address'] as String?,
      website: json['website'] as String?,
      categoryId: json['categoryId'] as String?,
      categoryName: json['categoryName'] as String?,
      membersCount: json['membersCount'] as int? ?? 0,
      eventsCount: json['eventsCount'] as int? ?? 0,
      isVerified: json['isVerified'] as bool? ?? false,
      status: OrganizationStatus.fromString(json['status'] as String? ?? 'active'),
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
      'description': description,
      'logo': logo,
      'coverImage': coverImage,
      'phone': phone,
      'email': email,
      'address': address,
      'website': website,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'membersCount': membersCount,
      'eventsCount': eventsCount,
      'isVerified': isVerified,
      'status': status.value,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  Organization copyWith({
    String? id,
    String? name,
    String? description,
    String? logo,
    String? coverImage,
    String? phone,
    String? email,
    String? address,
    String? website,
    String? categoryId,
    String? categoryName,
    int? membersCount,
    int? eventsCount,
    bool? isVerified,
    OrganizationStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Organization(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      logo: logo ?? this.logo,
      coverImage: coverImage ?? this.coverImage,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      website: website ?? this.website,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      membersCount: membersCount ?? this.membersCount,
      eventsCount: eventsCount ?? this.eventsCount,
      isVerified: isVerified ?? this.isVerified,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Organization status
enum OrganizationStatus {
  active('active'),
  inactive('inactive'),
  pending('pending'),
  suspended('suspended');

  final String value;
  const OrganizationStatus(this.value);

  static OrganizationStatus fromString(String value) {
    return OrganizationStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => OrganizationStatus.active,
    );
  }
}

class Organization {
  final String id;
  final String name;
  final String? description;
  final String? logo;
  final String? address;
  final String? phone;
  final String? email;
  final String? website;
  final int membersCount;
  final int eventsCount;
  final List<String> gallery;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Organization({
    required this.id,
    required this.name,
    this.description,
    this.logo,
    this.address,
    this.phone,
    this.email,
    this.website,
    this.membersCount = 0,
    this.eventsCount = 0,
    this.gallery = const [],
    this.createdAt,
    this.updatedAt,
  });

  factory Organization.fromJson(Map<String, dynamic> json) {
    return Organization(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      logo: json['logo'],
      address: json['address'],
      phone: json['phone'],
      email: json['email'],
      website: json['website'],
      membersCount: json['members_count'] ?? json['membersCount'] ?? 0,
      eventsCount: json['events_count'] ?? json['eventsCount'] ?? 0,
      gallery: json['gallery'] != null
          ? List<String>.from(json['gallery'])
          : [],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'logo': logo,
      'address': address,
      'phone': phone,
      'email': email,
      'website': website,
      'members_count': membersCount,
      'events_count': eventsCount,
      'gallery': gallery,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  Organization copyWith({
    String? id,
    String? name,
    String? description,
    String? logo,
    String? address,
    String? phone,
    String? email,
    String? website,
    int? membersCount,
    int? eventsCount,
    List<String>? gallery,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Organization(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      logo: logo ?? this.logo,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      website: website ?? this.website,
      membersCount: membersCount ?? this.membersCount,
      eventsCount: eventsCount ?? this.eventsCount,
      gallery: gallery ?? this.gallery,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

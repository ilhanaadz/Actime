/// Event model representing an event/activity
class Event {
  final String id;
  final String name;
  final String? description;
  final String? image;
  final String? location;
  final String? address;
  final DateTime startDate;
  final DateTime? endDate;
  final double? price;
  final String? currency;
  final int? maxParticipants;
  final int participantsCount;
  final String organizationId;
  final String? organizationName;
  final String? organizationLogo;
  final String? categoryId;
  final String? categoryName;
  final EventStatus status;
  final bool isFeatured;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Event({
    required this.id,
    required this.name,
    this.description,
    this.image,
    this.location,
    this.address,
    required this.startDate,
    this.endDate,
    this.price,
    this.currency = 'BAM',
    this.maxParticipants,
    this.participantsCount = 0,
    required this.organizationId,
    this.organizationName,
    this.organizationLogo,
    this.categoryId,
    this.categoryName,
    this.status = EventStatus.upcoming,
    this.isFeatured = false,
    required this.createdAt,
    this.updatedAt,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      image: json['image'] as String?,
      location: json['location'] as String?,
      address: json['address'] as String?,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: json['endDate'] != null
          ? DateTime.parse(json['endDate'] as String)
          : null,
      price: (json['price'] as num?)?.toDouble(),
      currency: json['currency'] as String? ?? 'BAM',
      maxParticipants: json['maxParticipants'] as int?,
      participantsCount: json['participantsCount'] as int? ?? 0,
      organizationId: json['organizationId'] as String,
      organizationName: json['organizationName'] as String?,
      organizationLogo: json['organizationLogo'] as String?,
      categoryId: json['categoryId'] as String?,
      categoryName: json['categoryName'] as String?,
      status: EventStatus.fromString(json['status'] as String? ?? 'upcoming'),
      isFeatured: json['isFeatured'] as bool? ?? false,
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
      'image': image,
      'location': location,
      'address': address,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'price': price,
      'currency': currency,
      'maxParticipants': maxParticipants,
      'participantsCount': participantsCount,
      'organizationId': organizationId,
      'organizationName': organizationName,
      'organizationLogo': organizationLogo,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'status': status.value,
      'isFeatured': isFeatured,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  Event copyWith({
    String? id,
    String? name,
    String? description,
    String? image,
    String? location,
    String? address,
    DateTime? startDate,
    DateTime? endDate,
    double? price,
    String? currency,
    int? maxParticipants,
    int? participantsCount,
    String? organizationId,
    String? organizationName,
    String? organizationLogo,
    String? categoryId,
    String? categoryName,
    EventStatus? status,
    bool? isFeatured,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Event(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      image: image ?? this.image,
      location: location ?? this.location,
      address: address ?? this.address,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      price: price ?? this.price,
      currency: currency ?? this.currency,
      maxParticipants: maxParticipants ?? this.maxParticipants,
      participantsCount: participantsCount ?? this.participantsCount,
      organizationId: organizationId ?? this.organizationId,
      organizationName: organizationName ?? this.organizationName,
      organizationLogo: organizationLogo ?? this.organizationLogo,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      status: status ?? this.status,
      isFeatured: isFeatured ?? this.isFeatured,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Check if event is free
  bool get isFree => price == null || price == 0;

  /// Check if event has available spots
  bool get hasAvailableSpots =>
      maxParticipants == null || participantsCount < maxParticipants!;

  /// Get formatted price
  String get formattedPrice {
    if (isFree) return 'Besplatno';
    return '${price!.toStringAsFixed(2)} $currency';
  }
}

/// Event status
enum EventStatus {
  draft('draft'),
  upcoming('upcoming'),
  active('active'),
  ongoing('ongoing'),
  completed('completed'),
  cancelled('cancelled'),
  closed('closed');

  final String value;
  const EventStatus(this.value);

  static EventStatus fromString(String value) {
    return EventStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => EventStatus.upcoming,
    );
  }

  String get displayName {
    switch (this) {
      case EventStatus.draft:
        return 'Nacrt';
      case EventStatus.upcoming:
        return 'Nadolazeći';
      case EventStatus.active:
        return 'Aktivan';
      case EventStatus.ongoing:
        return 'U toku';
      case EventStatus.completed:
        return 'Završen';
      case EventStatus.cancelled:
        return 'Otkazan';
      case EventStatus.closed:
        return 'Zatvoren';
    }
  }
}

/// Event status enum
enum EventStatus {
  draft,
  upcoming,
  ongoing,
  completed,
  cancelled;

  static EventStatus fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'upcoming':
        return EventStatus.upcoming;
      case 'ongoing':
      case 'active':
        return EventStatus.ongoing;
      case 'completed':
      case 'finished':
        return EventStatus.completed;
      case 'cancelled':
      case 'canceled':
        return EventStatus.cancelled;
      case 'draft':
      default:
        return EventStatus.draft;
    }
  }

  String get displayName {
    switch (this) {
      case EventStatus.draft:
        return 'Nacrt';
      case EventStatus.upcoming:
        return 'Nadolazeći';
      case EventStatus.ongoing:
        return 'U toku';
      case EventStatus.completed:
        return 'Završen';
      case EventStatus.cancelled:
        return 'Otkazan';
    }
  }
}

/// Event model representing an event/activity
/// Maps to backend Event entity
class Event {
  final String id;
  final String name;
  final String? description;
  final String? location;
  final String? address;
  final DateTime startDate;
  final DateTime? endDate;
  final double price;
  final String? currency;
  final int? maxParticipants;
  final int participantsCount;
  final String organizationId;
  final String? organizationName;
  final String? categoryId;
  final String? categoryName;
  final EventStatus status;
  final bool isFeatured;
  final bool isFree;
  final bool isEnrolled;
  final String? imageUrl;
  final DateTime createdAt;
  final DateTime? lastModifiedAt;

  // Backend field aliases
  final int? locationId;
  final int? eventStatusId;
  final int? activityTypeId;

  Event({
    required this.id,
    required this.name,
    this.description,
    this.location,
    this.address,
    required this.startDate,
    this.endDate,
    this.price = 0,
    this.currency = 'BAM',
    this.maxParticipants,
    this.participantsCount = 0,
    required this.organizationId,
    this.organizationName,
    this.categoryId,
    this.categoryName,
    this.status = EventStatus.upcoming,
    this.isFeatured = false,
    bool? isFree,
    this.isEnrolled = false,
    this.imageUrl,
    required this.createdAt,
    this.lastModifiedAt,
    this.locationId,
    this.eventStatusId,
    this.activityTypeId,
  }) : isFree = isFree ?? (price == 0);

  /// Alias for name (backwards compatibility)
  String get title => name;

  /// Alias for startDate
  DateTime get start => startDate;

  /// Alias for endDate
  DateTime get end => endDate ?? startDate;

  factory Event.fromJson(Map<String, dynamic> json) {
    final price = _parseDouble(json['Price'] ?? json['price']) ?? 0;
    final isFreeValue = json['IsFree'] as bool? ?? json['isFree'] as bool?;

    return Event(
      id: (json['Id'] ?? json['id'])?.toString() ?? '0',
      name: json['Name'] as String? ?? json['name'] as String? ??
            json['Title'] as String? ?? json['title'] as String? ?? '',
      description: json['Description'] as String? ?? json['description'] as String?,
      location: json['Location'] as String? ?? json['location'] as String?,
      address: json['Address'] as String? ?? json['address'] as String?,
      startDate: _parseDateTime(json['StartDate'] ?? json['startDate'] ??
                                json['Start'] ?? json['start']) ?? DateTime.now(),
      endDate: _parseDateTime(json['EndDate'] ?? json['endDate'] ??
                              json['End'] ?? json['end']),
      price: price,
      currency: json['Currency'] as String? ?? json['currency'] as String? ?? 'BAM',
      maxParticipants: _parseInt(json['MaxParticipants'] ?? json['maxParticipants']),
      participantsCount: _parseInt(json['ParticipantsCount'] ?? json['participantsCount']) ?? 0,
      organizationId: (json['OrganizationId'] ?? json['organizationId'])?.toString() ?? '0',
      organizationName: json['OrganizationName'] as String? ?? json['organizationName'] as String?,
      categoryId: (json['CategoryId'] ?? json['categoryId'])?.toString(),
      categoryName: json['CategoryName'] as String? ?? json['categoryName'] as String?,
      status: EventStatus.fromString(json['Status'] as String? ?? json['status'] as String?),
      isFeatured: json['IsFeatured'] as bool? ?? json['isFeatured'] as bool? ?? false,
      isFree: isFreeValue ?? (price == 0),
      isEnrolled: json['IsEnrolled'] as bool? ?? json['isEnrolled'] as bool? ?? false,
      imageUrl: json['ImageUrl'] as String? ?? json['imageUrl'] as String?,
      createdAt: _parseDateTime(json['CreatedAt'] ?? json['createdAt']) ?? DateTime.now(),
      lastModifiedAt: _parseDateTime(json['LastModifiedAt'] ?? json['lastModifiedAt']),
      locationId: _parseInt(json['LocationId'] ?? json['locationId']),
      eventStatusId: _parseInt(json['EventStatusId'] ?? json['eventStatusId']),
      activityTypeId: _parseInt(json['ActivityTypeId'] ?? json['activityTypeId']),
    );
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
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
      'Title': name,
      'Description': description,
      'Location': location,
      'Address': address,
      'StartDate': startDate.toIso8601String(),
      'Start': startDate.toIso8601String(),
      'EndDate': endDate?.toIso8601String(),
      'End': endDate?.toIso8601String(),
      'Price': price,
      'Currency': currency,
      'MaxParticipants': maxParticipants,
      'ParticipantsCount': participantsCount,
      'OrganizationId': organizationId,
      'OrganizationName': organizationName,
      'CategoryId': categoryId,
      'CategoryName': categoryName,
      'Status': status.name,
      'IsFeatured': isFeatured,
      'IsFree': isFree,
      'IsEnrolled': isEnrolled,
      'ImageUrl': imageUrl,
      'CreatedAt': createdAt.toIso8601String(),
      'LastModifiedAt': lastModifiedAt?.toIso8601String(),
      'LocationId': locationId,
      'EventStatusId': eventStatusId,
      'ActivityTypeId': activityTypeId,
    };
  }

  Event copyWith({
    String? id,
    String? name,
    String? description,
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
    String? categoryId,
    String? categoryName,
    EventStatus? status,
    bool? isFeatured,
    bool? isFree,
    bool? isEnrolled,
    String? imageUrl,
    DateTime? createdAt,
    DateTime? lastModifiedAt,
    int? locationId,
    int? eventStatusId,
    int? activityTypeId,
  }) {
    return Event(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
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
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      status: status ?? this.status,
      isFeatured: isFeatured ?? this.isFeatured,
      isFree: isFree ?? this.isFree,
      isEnrolled: isEnrolled ?? this.isEnrolled,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      lastModifiedAt: lastModifiedAt ?? this.lastModifiedAt,
      locationId: locationId ?? this.locationId,
      eventStatusId: eventStatusId ?? this.eventStatusId,
      activityTypeId: activityTypeId ?? this.activityTypeId,
    );
  }

  /// Get formatted price
  String get formattedPrice {
    if (isFree || price == 0) return 'Besplatno';
    return '${price.toStringAsFixed(2)} ${currency ?? 'BAM'}';
  }

  /// Check if event has available spots
  bool get hasAvailableSpots {
    if (maxParticipants == null) return true;
    return participantsCount < maxParticipants!;
  }

  /// Get remaining spots
  int? get remainingSpots {
    if (maxParticipants == null) return null;
    return maxParticipants! - participantsCount;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Event && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

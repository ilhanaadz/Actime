/// Event model representing an event/activity
/// Maps to backend Event entity
class Event {
  final int id;
  final int organizationId;
  final String title;
  final String? description;
  final DateTime start;
  final DateTime end;
  final int locationId;
  final int? maxParticipants;
  final bool isFree;
  final double price;
  final int eventStatusId;
  final int activityTypeId;
  final DateTime createdAt;
  final DateTime? lastModifiedAt;

  // Additional properties from API responses
  final String? image;
  final String? organizationName;
  final String? location;
  final int? participantsCount;

  Event({
    required this.id,
    required this.organizationId,
    required this.title,
    this.description,
    required this.start,
    required this.end,
    required this.locationId,
    this.maxParticipants,
    this.isFree = true,
    this.price = 0,
    required this.eventStatusId,
    required this.activityTypeId,
    required this.createdAt,
    this.lastModifiedAt,
    this.image,
    this.organizationName,
    this.location,
    this.participantsCount,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: _parseInt(json['Id'] ?? json['id']) ?? 0,
      organizationId: _parseInt(json['OrganizationId'] ?? json['organizationId']) ?? 0,
      title: json['Title'] as String? ?? json['title'] as String? ?? '',
      description: json['Description'] as String? ?? json['description'] as String?,
      start: _parseDateTime(json['Start'] ?? json['start']) ?? DateTime.now(),
      end: _parseDateTime(json['End'] ?? json['end']) ?? DateTime.now(),
      locationId: _parseInt(json['LocationId'] ?? json['locationId']) ?? 0,
      maxParticipants: _parseInt(json['MaxParticipants'] ?? json['maxParticipants']),
      isFree: json['IsFree'] as bool? ?? json['isFree'] as bool? ?? true,
      price: _parseDouble(json['Price'] ?? json['price']) ?? 0,
      eventStatusId: _parseInt(json['EventStatusId'] ?? json['eventStatusId']) ?? 0,
      activityTypeId: _parseInt(json['ActivityTypeId'] ?? json['activityTypeId']) ?? 0,
      createdAt: _parseDateTime(json['CreatedAt'] ?? json['createdAt']) ?? DateTime.now(),
      lastModifiedAt: _parseDateTime(json['LastModifiedAt'] ?? json['lastModifiedAt']),
      image: json['Image'] as String? ?? json['image'] as String?,
      organizationName: json['OrganizationName'] as String? ?? json['organizationName'] as String?,
      location: json['Location'] as String? ?? json['location'] as String?,
      participantsCount: _parseInt(json['ParticipantsCount'] ?? json['participantsCount']),
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
      'OrganizationId': organizationId,
      'Title': title,
      'Description': description,
      'Start': start.toIso8601String(),
      'End': end.toIso8601String(),
      'LocationId': locationId,
      'MaxParticipants': maxParticipants,
      'IsFree': isFree,
      'Price': price,
      'EventStatusId': eventStatusId,
      'ActivityTypeId': activityTypeId,
      'CreatedAt': createdAt.toIso8601String(),
      'LastModifiedAt': lastModifiedAt?.toIso8601String(),
      'Image': image,
      'OrganizationName': organizationName,
      'Location': location,
      'ParticipantsCount': participantsCount,
    };
  }

  Event copyWith({
    int? id,
    int? organizationId,
    String? title,
    String? description,
    DateTime? start,
    DateTime? end,
    int? locationId,
    int? maxParticipants,
    bool? isFree,
    double? price,
    int? eventStatusId,
    int? activityTypeId,
    DateTime? createdAt,
    DateTime? lastModifiedAt,
    String? image,
    String? organizationName,
    String? location,
    int? participantsCount,
  }) {
    return Event(
      id: id ?? this.id,
      organizationId: organizationId ?? this.organizationId,
      title: title ?? this.title,
      description: description ?? this.description,
      start: start ?? this.start,
      end: end ?? this.end,
      locationId: locationId ?? this.locationId,
      maxParticipants: maxParticipants ?? this.maxParticipants,
      isFree: isFree ?? this.isFree,
      price: price ?? this.price,
      eventStatusId: eventStatusId ?? this.eventStatusId,
      activityTypeId: activityTypeId ?? this.activityTypeId,
      createdAt: createdAt ?? this.createdAt,
      lastModifiedAt: lastModifiedAt ?? this.lastModifiedAt,
      image: image ?? this.image,
      organizationName: organizationName ?? this.organizationName,
      location: location ?? this.location,
      participantsCount: participantsCount ?? this.participantsCount,
    );
  }

  /// Get formatted price
  String get formattedPrice {
    if (isFree || price == 0) return 'Besplatno';
    return '${price.toStringAsFixed(2)} BAM';
  }

  /// Alias for title (used in admin screens)
  String get name => title;

  /// Alias for start (used in admin screens)
  DateTime get startDate => start;

  /// Get status enum based on eventStatusId
  EventStatus get status {
    // Map eventStatusId to EventStatus enum
    switch (eventStatusId) {
      case 1:
        return EventStatus.pending;
      case 2:
        return EventStatus.upcoming;
      case 3:
        return EventStatus.inProgress;
      case 4:
        return EventStatus.completed;
      case 5:
        return EventStatus.cancelled;
      case 6:
        return EventStatus.postponed;
      case 7:
        return EventStatus.rescheduled;
      default:
        return EventStatus.pending;
    }
  }

  /// Get status string based on eventStatusId
  String get statusString {
    // Map eventStatusId to status strings
    switch (eventStatusId) {
      case 1:
        return 'pending';
      case 2:
        return 'upcoming';
      case 3:
        return 'inProgress';
      case 4:
        return 'completed';
      case 5:
        return 'cancelled';
      case 6:
        return 'postponed';
      case 7:
        return 'rescheduled';
      default:
        return 'unknown';
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Event && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// Event status enum matching backend EventStatus
enum EventStatus {
  pending,      // 1
  upcoming,     // 2
  inProgress,   // 3
  completed,    // 4
  cancelled,    // 5
  postponed,    // 6
  rescheduled,  // 7
}

enum EventStatus { active, closed, upcoming }

class Event {
  final String id;
  final String name;
  final String? description;
  final String? image;
  final String? location;
  final DateTime? startDate;
  final DateTime? endDate;
  final int participantsCount;
  final int maxParticipants;
  final EventStatus status;
  final String? organizationId;
  final String? organizationName;
  final String? categoryId;
  final String? categoryName;
  final List<String> participantAvatars;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Event({
    required this.id,
    required this.name,
    this.description,
    this.image,
    this.location,
    this.startDate,
    this.endDate,
    this.participantsCount = 0,
    this.maxParticipants = 0,
    this.status = EventStatus.upcoming,
    this.organizationId,
    this.organizationName,
    this.categoryId,
    this.categoryName,
    this.participantAvatars = const [],
    this.createdAt,
    this.updatedAt,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      image: json['image'],
      location: json['location'],
      startDate: json['start_date'] != null
          ? DateTime.tryParse(json['start_date'])
          : null,
      endDate: json['end_date'] != null
          ? DateTime.tryParse(json['end_date'])
          : null,
      participantsCount:
          json['participants_count'] ?? json['participantsCount'] ?? 0,
      maxParticipants:
          json['max_participants'] ?? json['maxParticipants'] ?? 0,
      status: _parseStatus(json['status']),
      organizationId: json['organization_id']?.toString(),
      organizationName: json['organization_name'],
      categoryId: json['category_id']?.toString(),
      categoryName: json['category_name'],
      participantAvatars: json['participant_avatars'] != null
          ? List<String>.from(json['participant_avatars'])
          : [],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,
    );
  }

  static EventStatus _parseStatus(dynamic status) {
    if (status == null) return EventStatus.upcoming;
    final statusStr = status.toString().toLowerCase();
    switch (statusStr) {
      case 'active':
        return EventStatus.active;
      case 'closed':
        return EventStatus.closed;
      default:
        return EventStatus.upcoming;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'image': image,
      'location': location,
      'start_date': startDate?.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'participants_count': participantsCount,
      'max_participants': maxParticipants,
      'status': status.name,
      'organization_id': organizationId,
      'organization_name': organizationName,
      'category_id': categoryId,
      'category_name': categoryName,
      'participant_avatars': participantAvatars,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  Event copyWith({
    String? id,
    String? name,
    String? description,
    String? image,
    String? location,
    DateTime? startDate,
    DateTime? endDate,
    int? participantsCount,
    int? maxParticipants,
    EventStatus? status,
    String? organizationId,
    String? organizationName,
    String? categoryId,
    String? categoryName,
    List<String>? participantAvatars,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Event(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      image: image ?? this.image,
      location: location ?? this.location,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      participantsCount: participantsCount ?? this.participantsCount,
      maxParticipants: maxParticipants ?? this.maxParticipants,
      status: status ?? this.status,
      organizationId: organizationId ?? this.organizationId,
      organizationName: organizationName ?? this.organizationName,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      participantAvatars: participantAvatars ?? this.participantAvatars,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

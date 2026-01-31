import 'user.dart';
import 'event.dart';

/// Event participant model
class Participant {
  final String id;
  final String userId;
  final String eventId;
  final User? user;
  final Event? event;
  final ParticipantStatus status;
  final DateTime joinedAt;
  final DateTime? checkedInAt;
  final DateTime? checkedOutAt;

  Participant({
    required this.id,
    required this.userId,
    required this.eventId,
    this.user,
    this.event,
    this.status = ParticipantStatus.registered,
    required this.joinedAt,
    this.checkedInAt,
    this.checkedOutAt,
  });

  factory Participant.fromJson(Map<String, dynamic> json) {
    return Participant(
      id: (json['Id'] ?? json['id'])?.toString() ?? '0',
      userId: (json['UserId'] ?? json['userId'])?.toString() ?? '0',
      eventId: (json['EventId'] ?? json['eventId'])?.toString() ?? '0',
      user: json['User'] != null
          ? User.fromJson(json['User'] as Map<String, dynamic>)
          : json['user'] != null
              ? User.fromJson(json['user'] as Map<String, dynamic>)
              : null,
      event: json['Event'] != null
          ? Event.fromJson(json['Event'] as Map<String, dynamic>)
          : json['event'] != null
              ? Event.fromJson(json['event'] as Map<String, dynamic>)
              : null,
      status: ParticipantStatus.fromString(json['Status'] as String? ?? json['status'] as String? ?? 'registered'),
      joinedAt: _parseDateTime(json['JoinedAt'] ?? json['joinedAt']) ?? DateTime.now(),
      checkedInAt: _parseDateTime(json['CheckedInAt'] ?? json['checkedInAt']),
      checkedOutAt: _parseDateTime(json['CheckedOutAt'] ?? json['checkedOutAt']),
    );
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
      'UserId': userId,
      'EventId': eventId,
      'User': user?.toJson(),
      'Event': event?.toJson(),
      'Status': status.value,
      'JoinedAt': joinedAt.toIso8601String(),
      'CheckedInAt': checkedInAt?.toIso8601String(),
      'CheckedOutAt': checkedOutAt?.toIso8601String(),
    };
  }

  Participant copyWith({
    String? id,
    String? userId,
    String? eventId,
    User? user,
    Event? event,
    ParticipantStatus? status,
    DateTime? joinedAt,
    DateTime? checkedInAt,
    DateTime? checkedOutAt,
  }) {
    return Participant(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      eventId: eventId ?? this.eventId,
      user: user ?? this.user,
      event: event ?? this.event,
      status: status ?? this.status,
      joinedAt: joinedAt ?? this.joinedAt,
      checkedInAt: checkedInAt ?? this.checkedInAt,
      checkedOutAt: checkedOutAt ?? this.checkedOutAt,
    );
  }

  /// Check if participant has checked in
  bool get hasCheckedIn => checkedInAt != null;

  /// Check if participant has checked out
  bool get hasCheckedOut => checkedOutAt != null;
}

/// Participant status
enum ParticipantStatus {
  registered('registered'),
  checkedIn('checked_in'),
  checkedOut('checked_out'),
  cancelled('cancelled'),
  noShow('no_show');

  final String value;
  const ParticipantStatus(this.value);

  static ParticipantStatus fromString(String value) {
    return ParticipantStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => ParticipantStatus.registered,
    );
  }

  String get displayName {
    switch (this) {
      case ParticipantStatus.registered:
        return 'Registrovan';
      case ParticipantStatus.checkedIn:
        return 'Prijavljen';
      case ParticipantStatus.checkedOut:
        return 'Odjavljen';
      case ParticipantStatus.cancelled:
        return 'Otkazan';
      case ParticipantStatus.noShow:
        return 'Nije došao';
    }
  }
}

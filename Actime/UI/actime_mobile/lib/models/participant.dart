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
      id: json['id'] as String,
      userId: json['userId'] as String,
      eventId: json['eventId'] as String,
      user: json['user'] != null
          ? User.fromJson(json['user'] as Map<String, dynamic>)
          : null,
      event: json['event'] != null
          ? Event.fromJson(json['event'] as Map<String, dynamic>)
          : null,
      status: ParticipantStatus.fromString(json['status'] as String? ?? 'registered'),
      joinedAt: DateTime.parse(json['joinedAt'] as String),
      checkedInAt: json['checkedInAt'] != null
          ? DateTime.parse(json['checkedInAt'] as String)
          : null,
      checkedOutAt: json['checkedOutAt'] != null
          ? DateTime.parse(json['checkedOutAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'eventId': eventId,
      'user': user?.toJson(),
      'event': event?.toJson(),
      'status': status.value,
      'joinedAt': joinedAt.toIso8601String(),
      'checkedInAt': checkedInAt?.toIso8601String(),
      'checkedOutAt': checkedOutAt?.toIso8601String(),
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

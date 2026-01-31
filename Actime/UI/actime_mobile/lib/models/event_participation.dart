import 'event.dart';

/// Event participation summary for organization
class EventParticipation {
  final String eventId;
  final String eventName;
  final int participantsCount;
  final Event? event;

  EventParticipation({
    required this.eventId,
    required this.eventName,
    required this.participantsCount,
    this.event,
  });

  factory EventParticipation.fromJson(Map<String, dynamic> json) {
    return EventParticipation(
      eventId: (json['EventId'] ?? json['eventId'])?.toString() ?? '0',
      eventName: json['EventName'] as String? ?? json['eventName'] as String? ?? '',
      participantsCount: (json['ParticipantsCount'] ?? json['participantsCount']) as int? ?? 0,
      event: json['Event'] != null
          ? Event.fromJson(json['Event'] as Map<String, dynamic>)
          : json['event'] != null
              ? Event.fromJson(json['event'] as Map<String, dynamic>)
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'EventId': eventId,
      'EventName': eventName,
      'ParticipantsCount': participantsCount,
      'Event': event?.toJson(),
    };
  }

  factory EventParticipation.fromEvent(Event event) {
    return EventParticipation(
      eventId: event.id,
      eventName: event.name,
      participantsCount: event.participantsCount,
      event: event,
    );
  }
}

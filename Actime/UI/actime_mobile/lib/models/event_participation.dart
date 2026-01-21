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
      eventId: json['eventId'] as String,
      eventName: json['eventName'] as String,
      participantsCount: json['participantsCount'] as int? ?? 0,
      event: json['event'] != null
          ? Event.fromJson(json['event'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'eventId': eventId,
      'eventName': eventName,
      'participantsCount': participantsCount,
      'event': event?.toJson(),
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

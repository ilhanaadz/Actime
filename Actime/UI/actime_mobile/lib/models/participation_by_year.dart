/// Participation statistics by year
class ParticipationByYear {
  final int year;
  final int participantsCount;

  ParticipationByYear({
    required this.year,
    required this.participantsCount,
  });

  factory ParticipationByYear.fromJson(Map<String, dynamic> json) {
    return ParticipationByYear(
      year: (json['Year'] ?? json['year']) as int? ?? 0,
      participantsCount: (json['ParticipantsCount'] ?? json['participantsCount']) as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Year': year,
      'ParticipantsCount': participantsCount,
    };
  }
}

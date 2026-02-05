/// Participation statistics by month
class ParticipationByMonth {
  final int year;
  final int month;
  final String monthName;
  final int participantsCount;

  ParticipationByMonth({
    required this.year,
    required this.month,
    required this.monthName,
    required this.participantsCount,
  });

  factory ParticipationByMonth.fromJson(Map<String, dynamic> json) {
    return ParticipationByMonth(
      year: (json['Year'] ?? json['year']) as int? ?? 0,
      month: (json['Month'] ?? json['month']) as int? ?? 0,
      monthName: (json['MonthName'] ?? json['monthName']) as String? ?? '',
      participantsCount: (json['ParticipantsCount'] ?? json['participantsCount']) as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Year': year,
      'Month': month,
      'MonthName': monthName,
      'ParticipantsCount': participantsCount,
    };
  }
}

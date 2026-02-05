/// Enrollment statistics by month
class EnrollmentByMonth {
  final int year;
  final int month;
  final String monthName;
  final int membersCount;

  EnrollmentByMonth({
    required this.year,
    required this.month,
    required this.monthName,
    required this.membersCount,
  });

  factory EnrollmentByMonth.fromJson(Map<String, dynamic> json) {
    return EnrollmentByMonth(
      year: (json['Year'] ?? json['year']) as int? ?? 0,
      month: (json['Month'] ?? json['month']) as int? ?? 0,
      monthName: (json['MonthName'] ?? json['monthName']) as String? ?? '',
      membersCount: (json['MembersCount'] ?? json['membersCount']) as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Year': year,
      'Month': month,
      'MonthName': monthName,
      'MembersCount': membersCount,
    };
  }
}

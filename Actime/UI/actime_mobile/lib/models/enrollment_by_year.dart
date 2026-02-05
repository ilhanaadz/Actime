/// Enrollment statistics by year
class EnrollmentByYear {
  final int year;
  final int membersCount;

  EnrollmentByYear({
    required this.year,
    required this.membersCount,
  });

  factory EnrollmentByYear.fromJson(Map<String, dynamic> json) {
    return EnrollmentByYear(
      year: (json['Year'] ?? json['year']) as int? ?? 0,
      membersCount: (json['MembersCount'] ?? json['membersCount']) as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Year': year,
      'MembersCount': membersCount,
    };
  }
}

/// ActivityType enum matching backend ActivityType
/// Used for categorizing events by activity type
enum ActivityType {
  singleDayTrip(1, 'Jednodnevni izlet'),
  multiDayTrip(2, 'Višednevni izlet'),
  training(3, 'Trening'),
  match(4, 'Utakmica'),
  meeting(5, 'Sastanak'),
  volunteering(6, 'Volontiranje'),
  fundraising(7, 'Prikupljanje sredstava'),
  aidCampaign(8, 'Humanitarna akcija'),
  teamBuilding(9, 'Team building'),
  promotion(10, 'Promocija'),
  competition(11, 'Takmičenje'),
  celebration(12, 'Proslava'),
  workshop(13, 'Radionica'),
  recruitmentEvent(14, 'Regrutacija'),
  camp(15, 'Kamp'),
  other(16, 'Ostalo');

  final int id;
  final String displayName;

  const ActivityType(this.id, this.displayName);

  /// Get ActivityType from ID
  static ActivityType? fromId(int? id) {
    if (id == null) return null;
    try {
      return ActivityType.values.firstWhere((type) => type.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Get all activity types as a list for dropdowns
  static List<ActivityType> get all => ActivityType.values;
}

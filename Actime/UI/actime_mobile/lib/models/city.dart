import 'country.dart';

/// City model
/// Maps to backend City entity
class City {
  final int id;
  final String name;
  final int countryId;
  final String? countryName;
  final Country? country;

  City({
    required this.id,
    required this.name,
    required this.countryId,
    this.countryName,
    this.country,
  });

  factory City.fromJson(Map<String, dynamic> json) {
    return City(
      id: _parseInt(json['Id'] ?? json['id']) ?? 0,
      name: json['Name'] as String? ?? json['name'] as String? ?? '',
      countryId: _parseInt(json['CountryId'] ?? json['countryId']) ?? 0,
      countryName: json['CountryName'] as String? ?? json['countryName'] as String?,
      country: json['Country'] != null || json['country'] != null
          ? Country.fromJson(json['Country'] ?? json['country'])
          : null,
    );
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'Id': id,
      'Name': name,
      'CountryId': countryId,
      'CountryName': countryName,
    };
  }

  /// Display name with country
  String get displayName {
    final cName = country?.name ?? countryName;
    if (cName != null && cName.isNotEmpty) {
      return '$name, $cName';
    }
    return name;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is City && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => displayName;
}

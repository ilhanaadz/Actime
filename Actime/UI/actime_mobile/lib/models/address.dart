import 'city.dart';

/// Address model
/// Maps to backend Address entity
class Address {
  final int id;
  final String street;
  final String postalCode;
  final String? coordinates;
  final int cityId;
  final String? cityName;
  final City? city;

  Address({
    required this.id,
    required this.street,
    required this.postalCode,
    this.coordinates,
    required this.cityId,
    this.cityName,
    this.city,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: _parseInt(json['Id'] ?? json['id']) ?? 0,
      street: json['Street'] as String? ?? json['street'] as String? ?? '',
      postalCode: json['PostalCode'] as String? ?? json['postalCode'] as String? ?? '',
      coordinates: json['Coordinates'] as String? ?? json['coordinates'] as String?,
      cityId: _parseInt(json['CityId'] ?? json['cityId']) ?? 0,
      cityName: json['CityName'] as String? ?? json['cityName'] as String?,
      city: json['City'] != null || json['city'] != null
          ? City.fromJson(json['City'] ?? json['city'])
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
      'Street': street,
      'PostalCode': postalCode,
      'Coordinates': coordinates,
      'CityId': cityId,
      'CityName': cityName,
    };
  }

  /// Full display address
  String get displayAddress {
    final parts = <String>[];
    parts.add(street);

    final cName = city?.name ?? cityName;
    if (cName != null && cName.isNotEmpty) {
      parts.add(cName);
    }

    if (postalCode.isNotEmpty) {
      parts.add(postalCode);
    }

    return parts.join(', ');
  }

  /// Short display (street only)
  String get shortAddress => street;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Address && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => displayAddress;
}

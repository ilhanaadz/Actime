/// Location model
/// Maps to backend Location entity
class Location {
  final int id;
  final String name;
  final String? description;
  final int? addressId;
  final double? latitude;
  final double? longitude;

  Location({
    required this.id,
    required this.name,
    this.description,
    this.addressId,
    this.latitude,
    this.longitude,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      id: _parseInt(json['Id'] ?? json['id']) ?? 0,
      name: json['Name'] as String? ?? json['name'] as String? ?? '',
      description: json['Description'] as String? ?? json['description'] as String?,
      addressId: _parseInt(json['AddressId'] ?? json['addressId']),
      latitude: _parseDouble(json['Latitude'] ?? json['latitude']),
      longitude: _parseDouble(json['Longitude'] ?? json['longitude']),
    );
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'Id': id,
      'Name': name,
      'Description': description,
      'AddressId': addressId,
      'Latitude': latitude,
      'Longitude': longitude,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Location && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

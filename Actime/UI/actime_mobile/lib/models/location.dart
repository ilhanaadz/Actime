import 'address.dart';

/// Location model
/// Maps to backend Location entity
class Location {
  final int id;
  final String name;
  final int addressId;
  final int? capacity;
  final String? description;
  final String? contactInfo;
  final Address? address;

  Location({
    required this.id,
    required this.name,
    required this.addressId,
    this.capacity,
    this.description,
    this.contactInfo,
    this.address,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      id: _parseInt(json['Id'] ?? json['id']) ?? 0,
      name: json['Name'] as String? ?? json['name'] as String? ?? '',
      addressId: _parseInt(json['AddressId'] ?? json['addressId']) ?? 0,
      capacity: _parseInt(json['Capacity'] ?? json['capacity']),
      description: json['Description'] as String? ?? json['description'] as String?,
      contactInfo: json['ContactInfo'] as String? ?? json['contactInfo'] as String?,
      address: json['Address'] != null || json['address'] != null
          ? Address.fromJson(json['Address'] ?? json['address'])
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
      'AddressId': addressId,
      'Capacity': capacity,
      'Description': description,
      'ContactInfo': contactInfo,
    };
  }

  /// Full display name with address
  String get displayName {
    if (address != null) {
      return '$name - ${address!.displayAddress}';
    }
    return name;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Location && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => displayName;
}

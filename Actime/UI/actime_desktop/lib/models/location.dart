/// Location model representing a venue/location
/// Maps to backend Location entity
class Location {
  final int id;
  final String name;
  final String? description;
  final int addressId;
  final DateTime createdAt;
  final DateTime? lastModifiedAt;

  Location({
    required this.id,
    required this.name,
    this.description,
    required this.addressId,
    required this.createdAt,
    this.lastModifiedAt,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      id: _parseInt(json['Id'] ?? json['id']) ?? 0,
      name: json['Name'] as String? ?? json['name'] as String? ?? '',
      description: json['Description'] as String? ?? json['description'] as String?,
      addressId: _parseInt(json['AddressId'] ?? json['addressId']) ?? 0,
      createdAt: _parseDateTime(json['CreatedAt'] ?? json['createdAt']) ?? DateTime.now(),
      lastModifiedAt: _parseDateTime(json['LastModifiedAt'] ?? json['lastModifiedAt']),
    );
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'Id': id,
      'Name': name,
      'Description': description,
      'AddressId': addressId,
      'CreatedAt': createdAt.toIso8601String(),
      'LastModifiedAt': lastModifiedAt?.toIso8601String(),
    };
  }

  Location copyWith({
    int? id,
    String? name,
    String? description,
    int? addressId,
    DateTime? createdAt,
    DateTime? lastModifiedAt,
  }) {
    return Location(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      addressId: addressId ?? this.addressId,
      createdAt: createdAt ?? this.createdAt,
      lastModifiedAt: lastModifiedAt ?? this.lastModifiedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Location && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// Country model
/// Maps to backend Country entity
class Country {
  final int id;
  final String name;
  final String? code;

  Country({
    required this.id,
    required this.name,
    this.code,
  });

  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(
      id: _parseInt(json['Id'] ?? json['id']) ?? 0,
      name: json['Name'] as String? ?? json['name'] as String? ?? '',
      code: json['Code'] as String? ?? json['code'] as String?,
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
      'Code': code,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Country && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => name;
}

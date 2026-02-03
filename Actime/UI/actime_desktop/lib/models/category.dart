/// Category model representing event/organization categories
/// Maps to backend Category entity
class Category {
  final int id;
  final String name;
  final String? description;
  final int? organizationsCount;

  Category({
    required this.id,
    required this.name,
    this.description,
    this.organizationsCount,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: _parseInt(json['Id'] ?? json['id']) ?? 0,
      name: json['Name'] as String? ?? json['name'] as String? ?? '',
      description: json['Description'] as String? ?? json['description'] as String?,
      organizationsCount: _parseInt(json['OrganizationsCount'] ?? json['organizationsCount']),
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
      'Description': description,
      'OrganizationsCount': organizationsCount,
    };
  }

  Category copyWith({
    int? id,
    String? name,
    String? description,
    int? organizationsCount,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      organizationsCount: organizationsCount ?? this.organizationsCount,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Category && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

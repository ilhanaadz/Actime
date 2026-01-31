/// Category model representing event/organization categories
/// Maps to backend Category entity
class Category {
  final String id;
  final String name;
  final String? description;
  final String? icon;
  final String? color;
  final int organizationsCount;
  final int eventsCount;

  Category({
    required this.id,
    required this.name,
    this.description,
    this.icon,
    this.color,
    this.organizationsCount = 0,
    this.eventsCount = 0,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: (json['Id'] ?? json['id'])?.toString() ?? '0',
      name: json['Name'] as String? ?? json['name'] as String? ?? '',
      description: json['Description'] as String? ?? json['description'] as String?,
      icon: json['Icon'] as String? ?? json['icon'] as String?,
      color: json['Color'] as String? ?? json['color'] as String?,
      organizationsCount: _parseInt(json['OrganizationsCount'] ?? json['organizationsCount']) ?? 0,
      eventsCount: _parseInt(json['EventsCount'] ?? json['eventsCount']) ?? 0,
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
      'Icon': icon,
      'Color': color,
      'OrganizationsCount': organizationsCount,
      'EventsCount': eventsCount,
    };
  }

  Category copyWith({
    String? id,
    String? name,
    String? description,
    String? icon,
    String? color,
    int? organizationsCount,
    int? eventsCount,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      organizationsCount: organizationsCount ?? this.organizationsCount,
      eventsCount: eventsCount ?? this.eventsCount,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Category && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

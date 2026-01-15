/// Category model representing event/organization categories
class Category {
  final String id;
  final String name;
  final String? description;
  final String? icon;
  final String? color;
  final int organizationsCount;
  final int eventsCount;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Category({
    required this.id,
    required this.name,
    this.description,
    this.icon,
    this.color,
    this.organizationsCount = 0,
    this.eventsCount = 0,
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      icon: json['icon'] as String?,
      color: json['color'] as String?,
      organizationsCount: json['organizationsCount'] as int? ?? 0,
      eventsCount: json['eventsCount'] as int? ?? 0,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon': icon,
      'color': color,
      'organizationsCount': organizationsCount,
      'eventsCount': eventsCount,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
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
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      organizationsCount: organizationsCount ?? this.organizationsCount,
      eventsCount: eventsCount ?? this.eventsCount,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

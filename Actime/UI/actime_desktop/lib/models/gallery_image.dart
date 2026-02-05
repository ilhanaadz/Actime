class GalleryImage {
  final int id;
  final String imageUrl;
  final String? caption;
  final int? userId;
  final int? organizationId;
  final DateTime createdAt;

  GalleryImage({
    required this.id,
    required this.imageUrl,
    this.caption,
    this.userId,
    this.organizationId,
    required this.createdAt,
  });

  factory GalleryImage.fromJson(Map<String, dynamic> json) {
    return GalleryImage(
      id: _parseInt(json['Id'] ?? json['id']) ?? 0,
      imageUrl: json['ImageUrl'] as String? ?? json['imageUrl'] as String? ?? '',
      caption: json['Caption'] as String? ?? json['caption'] as String?,
      userId: _parseInt(json['UserId'] ?? json['userId']),
      organizationId: _parseInt(json['OrganizationId'] ?? json['organizationId']),
      createdAt: _parseDateTime(json['CreatedAt'] ?? json['createdAt']) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Id': id,
      'ImageUrl': imageUrl,
      'Caption': caption,
      'UserId': userId,
      'OrganizationId': organizationId,
      'CreatedAt': createdAt.toIso8601String(),
    };
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
}

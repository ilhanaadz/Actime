class GalleryImage {
  final String id;
  final String imageUrl;
  final String? caption;
  final String? userId;
  final String? organizationId;
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
      id: (json['Id'] ?? json['id'])?.toString() ?? '0',
      imageUrl: json['ImageUrl'] as String? ?? json['imageUrl'] as String? ?? '',
      caption: json['Caption'] as String? ?? json['caption'] as String?,
      userId: (json['UserId'] ?? json['userId'])?.toString(),
      organizationId: (json['OrganizationId'] ?? json['organizationId'])?.toString(),
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

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}

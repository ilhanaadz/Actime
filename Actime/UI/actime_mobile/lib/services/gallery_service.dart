import '../models/api_response.dart';
import '../models/gallery_image.dart';
import 'api_service.dart';

class GalleryService {
  static final GalleryService _instance = GalleryService._internal();
  factory GalleryService() => _instance;
  GalleryService._internal();

  final ApiService _apiService = ApiService();

  Future<ApiResponse<List<GalleryImage>>> getByUserId(String userId) async {
    final response = await _apiService.get<Map<String, dynamic>>(
      '/Gallery/user/$userId',
      fromJson: (json) => json,
    );

    if (response.success && response.data != null) {
      final items = response.data!['items'] as List? ?? response.data as List?;
      if (items != null) {
        final images = items
            .map((item) => GalleryImage.fromJson(item as Map<String, dynamic>))
            .toList();
        return ApiResponse.success(images, statusCode: response.statusCode);
      }
    }

    return ApiResponse.error(
      response.message ?? 'Greška pri učitavanju galerije',
      statusCode: response.statusCode,
    );
  }

  Future<ApiResponse<List<GalleryImage>>> getByOrganizationId(
    String organizationId,
  ) async {
    final response = await _apiService.get<List<GalleryImage>>(
      '/Gallery/organization/$organizationId',
      fromJson: (json) {
        return (json as List)
            .map((item) => GalleryImage.fromJson(item as Map<String, dynamic>))
            .toList();
      },
    );

    return ApiResponse.success(response.data!, statusCode: response.statusCode);
  }

  Future<ApiResponse<GalleryImage>> addImage({
    required String imageUrl,
    String? caption,
    String? userId,
    String? organizationId,
  }) async {
    return await _apiService.post<GalleryImage>(
      '/Gallery',
      body: {
        'ImageUrl': imageUrl,
        if (caption != null) 'Caption': caption,
        if (userId != null) 'UserId': int.tryParse(userId),
        if (organizationId != null)
          'OrganizationId': int.tryParse(organizationId),
      },
      fromJson: (json) => GalleryImage.fromJson(json),
    );
  }

  Future<ApiResponse<void>> deleteImage(String imageId) async {
    return await _apiService.delete('/Gallery/$imageId');
  }
}

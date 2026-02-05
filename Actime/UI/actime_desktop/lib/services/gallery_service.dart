import '../models/gallery_image.dart';
import 'api_service.dart';

class GalleryService {
  static final GalleryService _instance = GalleryService._internal();
  factory GalleryService() => _instance;
  GalleryService._internal();

  final ApiService _apiService = ApiService();

  Future<ApiResponse<List<GalleryImage>>> getByOrganizationId(int organizationId) async {
    final response = await _apiService.get<List<GalleryImage>>(
      '/Gallery/organization/$organizationId',
      fromJson: (json) {
        if (json is List) {
          return json
              .map((item) => GalleryImage.fromJson(item as Map<String, dynamic>))
              .toList();
        }
        return <GalleryImage>[];
      },
    );

    return response;
  }

  Future<ApiResponse<List<GalleryImage>>> getByUserId(int userId) async {
    final response = await _apiService.get<List<GalleryImage>>(
      '/Gallery/user/$userId',
      fromJson: (json) {
        if (json is List) {
          return json
              .map((item) => GalleryImage.fromJson(item as Map<String, dynamic>))
              .toList();
        }
        if (json is Map && json.containsKey('items')) {
          return (json['items'] as List)
              .map((item) => GalleryImage.fromJson(item as Map<String, dynamic>))
              .toList();
        }
        return <GalleryImage>[];
      },
    );

    return response;
  }
}

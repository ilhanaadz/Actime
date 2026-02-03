import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import '../config/api_config.dart';
import '../models/api_response.dart';
import 'token_service.dart';

enum ImageUploadType {
  profile,
  organization,
  gallery,
}

class ImageService {
  static final ImageService _instance = ImageService._internal();
  factory ImageService() => _instance;
  ImageService._internal();

  final ImagePicker _picker = ImagePicker();
  final TokenService _tokenService = TokenService();

  Future<XFile?> pickImageFromGallery() async {
    return await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 85,
    );
  }

  Future<XFile?> pickImageFromCamera() async {
    return await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 85,
    );
  }

  Future<ApiResponse<String>> uploadImage(
    File file,
    ImageUploadType type,
  ) async {
    try {
      final endpoint = _getEndpoint(type);
      final uri = Uri.parse('${ApiConfig.fullUrl}$endpoint');

      final request = http.MultipartRequest('POST', uri);

      final token = await _tokenService.getAccessToken();
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      final mimeType = _getMimeType(file.path);
      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          file.path,
          contentType: MediaType.parse(mimeType),
        ),
      );

      final streamedResponse = await request.send().timeout(
            const Duration(minutes: 2),
          );

      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final imageUrl = data['imageUrl'] as String;
        return ApiResponse.success(imageUrl, statusCode: response.statusCode);
      }

      String message = 'Greška pri uploadu slike';
      try {
        final errorBody = jsonDecode(response.body) as Map<String, dynamic>;
        message = errorBody['message'] as String? ?? message;
      } catch (_) {}

      return ApiResponse.error(message, statusCode: response.statusCode);
    } catch (e) {
      return ApiResponse.error(_getErrorMessage(e));
    }
  }

  Future<ApiResponse<void>> deleteImage(String imageUrl) async {
    try {
      final uri = Uri.parse('${ApiConfig.fullUrl}/FileUpload')
          .replace(queryParameters: {'imageUrl': imageUrl});

      final token = await _tokenService.getAccessToken();
      final headers = <String, String>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http.delete(uri, headers: headers);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return ApiResponse.success(null, statusCode: response.statusCode);
      }

      String message = 'Greška pri brisanju slike';
      try {
        final errorBody = jsonDecode(response.body) as Map<String, dynamic>;
        message = errorBody['message'] as String? ?? message;
      } catch (_) {}

      return ApiResponse.error(message, statusCode: response.statusCode);
    } catch (e) {
      return ApiResponse.error(_getErrorMessage(e));
    }
  }

  String _getEndpoint(ImageUploadType type) {
    switch (type) {
      case ImageUploadType.profile:
        return '/FileUpload/profile';
      case ImageUploadType.organization:
        return '/FileUpload/organization';
      case ImageUploadType.gallery:
        return '/FileUpload/gallery';
    }
  }

  String _getMimeType(String path) {
    final extension = path.split('.').last.toLowerCase();
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      default:
        return 'image/jpeg';
    }
  }

  String _getErrorMessage(dynamic error) {
    if (error.toString().contains('SocketException')) {
      return 'Nema internet veze';
    }
    if (error.toString().contains('TimeoutException')) {
      return 'Upload je istekao. Pokušajte ponovo.';
    }
    return 'Došlo je do greške. Pokušajte ponovo.';
  }

  String getFullImageUrl(String? relativeUrl) {
    if (relativeUrl == null || relativeUrl.isEmpty) {
      return '';
    }
    if (relativeUrl.startsWith('http')) {
      return relativeUrl;
    }
    return '${ApiConfig.fullUrl}$relativeUrl';
  }
}

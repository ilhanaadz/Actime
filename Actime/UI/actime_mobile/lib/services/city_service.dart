import '../config/api_config.dart';
import '../models/api_response.dart';
import '../models/paginated_response.dart';
import '../models/city.dart';
import 'api_service.dart';

/// City service
/// Communicates with backend CityController
class CityService {
  static final CityService _instance = CityService._internal();
  factory CityService() => _instance;
  CityService._internal();

  final ApiService _apiService = ApiService();

  /// Get cities (paginated) - public endpoint
  Future<ApiResponse<PaginatedResponse<City>>> getCities({
    int page = 1,
    int pageSize = 100,
    String? text,
    bool includeTotalCount = true,
  }) async {
    return await _apiService.get<PaginatedResponse<City>>(
      ApiConfig.city,
      queryParams: {
        'Page': page.toString(),
        'PageSize': pageSize.toString(),
        'IncludeTotalCount': includeTotalCount.toString(),
        if (text != null && text.isNotEmpty) 'Text': text,
      },
      fromJson: (json) => PaginatedResponse.fromJson(json, City.fromJson),
    );
  }

  /// Get city by ID - public endpoint
  Future<ApiResponse<City>> getCityById(int id) async {
    return await _apiService.get<City>(
      ApiConfig.cityById(id),
      fromJson: (json) => City.fromJson(json),
    );
  }

  /// Create city
  Future<ApiResponse<City>> createCity({
    required String name,
    required int countryId,
  }) async {
    return await _apiService.post<City>(
      ApiConfig.city,
      body: {
        'Name': name,
        'CountryId': countryId,
      },
      fromJson: (json) => City.fromJson(json),
    );
  }

  /// Get all cities as list
  Future<List<City>> getAllCities() async {
    final response = await getCities(pageSize: 500);
    if (response.success && response.data != null) {
      return response.data!.items;
    }
    return [];
  }
}

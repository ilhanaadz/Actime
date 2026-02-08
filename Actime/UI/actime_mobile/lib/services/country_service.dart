import '../config/api_config.dart';
import '../models/api_response.dart';
import '../models/paginated_response.dart';
import '../models/country.dart';
import 'api_service.dart';

/// Country service
/// Communicates with backend CountryController
class CountryService {
  static final CountryService _instance = CountryService._internal();
  factory CountryService() => _instance;
  CountryService._internal();

  final ApiService _apiService = ApiService();

  /// Get countries (paginated) - public endpoint
  Future<ApiResponse<PaginatedResponse<Country>>> getCountries({
    int page = 1,
    int pageSize = 100,
    String? text,
    bool includeTotalCount = true,
  }) async {
    return await _apiService.get<PaginatedResponse<Country>>(
      ApiConfig.country,
      queryParams: {
        'Page': page.toString(),
        'PageSize': pageSize.toString(),
        'IncludeTotalCount': includeTotalCount.toString(),
        if (text != null && text.isNotEmpty) 'Text': text,
      },
      fromJson: (json) => PaginatedResponse.fromJson(json, Country.fromJson),
    );
  }

  /// Get country by ID - public endpoint
  Future<ApiResponse<Country>> getCountryById(int id) async {
    return await _apiService.get<Country>(
      ApiConfig.countryById(id),
      fromJson: (json) => Country.fromJson(json),
    );
  }

  /// Get all countries as list
  Future<List<Country>> getAllCountries() async {
    final response = await getCountries(pageSize: 300);
    if (response.success && response.data != null) {
      return response.data!.items;
    }
    return [];
  }
}

import '../config/api_config.dart';
import '../models/api_response.dart';
import '../models/paginated_response.dart';
import '../models/location.dart';
import 'api_service.dart';

/// Location service
/// Communicates with backend LocationController
class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  final ApiService _apiService = ApiService();

  /// Get locations (paginated) - public endpoint
  Future<ApiResponse<PaginatedResponse<Location>>> getLocations({
    int page = 1,
    int pageSize = 10,
    String? text,
    bool includeTotalCount = true,
  }) async {
    if (ApiConfig.useMockApi) {
      return ApiResponse.success(PaginatedResponse(items: [], totalCount: 0));
    }

    return await _apiService.get<PaginatedResponse<Location>>(
      ApiConfig.location,
      queryParams: {
        'Page': page.toString(),
        'PageSize': pageSize.toString(),
        'IncludeTotalCount': includeTotalCount.toString(),
        if (text != null && text.isNotEmpty) 'Text': text,
      },
      fromJson: (json) => PaginatedResponse.fromJson(json, Location.fromJson),
    );
  }

  /// Get location by ID - public endpoint
  Future<ApiResponse<Location>> getLocationById(int id) async {
    if (ApiConfig.useMockApi) {
      return ApiResponse.error('Mock nije dostupan');
    }

    return await _apiService.get<Location>(
      ApiConfig.locationById(id),
      fromJson: (json) => Location.fromJson(json),
    );
  }

  /// Create location
  Future<ApiResponse<Location>> createLocation({
    required String name,
    required int addressId,
    int? capacity,
    String? description,
    String? contactInfo,
  }) async {
    if (ApiConfig.useMockApi) {
      return ApiResponse.error('Mock nije dostupan');
    }

    return await _apiService.post<Location>(
      ApiConfig.location,
      body: {
        'Name': name,
        'AddressId': addressId,
        if (capacity != null) 'Capacity': capacity,
        if (description != null) 'Description': description,
        if (contactInfo != null) 'ContactInfo': contactInfo,
      },
      fromJson: (json) => Location.fromJson(json),
    );
  }

  /// Update location
  Future<ApiResponse<Location>> updateLocation(
    int id, {
    String? name,
    int? addressId,
    int? capacity,
    String? description,
    String? contactInfo,
  }) async {
    if (ApiConfig.useMockApi) {
      return ApiResponse.error('Mock nije dostupan');
    }

    return await _apiService.put<Location>(
      ApiConfig.locationById(id),
      body: {
        if (name != null) 'Name': name,
        if (addressId != null) 'AddressId': addressId,
        if (capacity != null) 'Capacity': capacity,
        if (description != null) 'Description': description,
        if (contactInfo != null) 'ContactInfo': contactInfo,
      },
      fromJson: (json) => Location.fromJson(json),
    );
  }

  /// Delete location
  Future<ApiResponse<void>> deleteLocation(int id) async {
    if (ApiConfig.useMockApi) {
      return ApiResponse.success(null);
    }

    return await _apiService.delete(ApiConfig.locationById(id));
  }

  /// Get all locations as list
  Future<List<Location>> getAllLocations() async {
    final response = await getLocations(pageSize: 100);
    if (response.success && response.data != null) {
      return response.data!.items;
    }
    return [];
  }
}

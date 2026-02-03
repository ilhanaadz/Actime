import '../config/api_config.dart';
import '../models/models.dart';
import 'api_service.dart';

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  final ApiService _apiService = ApiService();

  Future<ApiResponse<PaginatedResponse<Location>>> getLocations({
    int page = 1,
    int pageSize = 10,
    String? search,
  }) async {
    final queryParams = <String, String>{
      'Page': page.toString(),
      'PageSize': pageSize.toString(),
      'IncludeTotalCount': 'true',
    };

    if (search != null && search.isNotEmpty) {
      queryParams['Search'] = search;
    }

    return await _apiService.get<PaginatedResponse<Location>>(
      ApiConfig.location,
      queryParams: queryParams,
      fromJson: (json) => PaginatedResponse.fromJson(json, Location.fromJson),
    );
  }

  Future<ApiResponse<Location>> getLocationById(int id) async {
    return await _apiService.get<Location>(
      ApiConfig.locationById(id),
      fromJson: (json) => Location.fromJson(json),
    );
  }

  Future<ApiResponse<Location>> createLocation({
    required String name,
    String? description,
    required int addressId,
  }) async {
    return await _apiService.post<Location>(
      ApiConfig.location,
      body: {
        'Name': name,
        'Description': description,
        'AddressId': addressId,
      },
      fromJson: (json) => Location.fromJson(json),
    );
  }

  Future<ApiResponse<Location>> updateLocation({
    required int id,
    String? name,
    String? description,
    int? addressId,
  }) async {
    final body = <String, dynamic>{};
    if (name != null) body['Name'] = name;
    if (description != null) body['Description'] = description;
    if (addressId != null) body['AddressId'] = addressId;

    return await _apiService.put<Location>(
      ApiConfig.locationById(id),
      body: body,
      fromJson: (json) => Location.fromJson(json),
    );
  }

  Future<ApiResponse<void>> deleteLocation(int id) async {
    return await _apiService.delete<void>(
      ApiConfig.locationById(id),
    );
  }
}

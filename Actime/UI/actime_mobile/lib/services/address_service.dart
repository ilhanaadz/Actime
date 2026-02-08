import '../config/api_config.dart';
import '../models/api_response.dart';
import '../models/paginated_response.dart';
import '../models/address.dart';
import 'api_service.dart';

/// Address service
/// Communicates with backend AddressController
class AddressService {
  static final AddressService _instance = AddressService._internal();
  factory AddressService() => _instance;
  AddressService._internal();

  final ApiService _apiService = ApiService();

  /// Get addresses (paginated) - public endpoint
  Future<ApiResponse<PaginatedResponse<Address>>> getAddresses({
    int page = 1,
    int pageSize = 50,
    String? text,
    bool includeTotalCount = true,
  }) async {
    return await _apiService.get<PaginatedResponse<Address>>(
      ApiConfig.address,
      queryParams: {
        'Page': page.toString(),
        'PageSize': pageSize.toString(),
        'IncludeTotalCount': includeTotalCount.toString(),
        if (text != null && text.isNotEmpty) 'Text': text,
      },
      fromJson: (json) => PaginatedResponse.fromJson(json, Address.fromJson),
    );
  }

  /// Get address by ID - public endpoint
  Future<ApiResponse<Address>> getAddressById(int id) async {
    return await _apiService.get<Address>(
      ApiConfig.addressById(id),
      fromJson: (json) => Address.fromJson(json),
    );
  }

  /// Create address
  Future<ApiResponse<Address>> createAddress({
    required String street,
    required String postalCode,
    required int cityId,
    String? coordinates,
  }) async {
    return await _apiService.post<Address>(
      ApiConfig.address,
      body: {
        'Street': street,
        'PostalCode': postalCode,
        'CityId': cityId,
        if (coordinates != null) 'Coordinates': coordinates,
      },
      fromJson: (json) => Address.fromJson(json),
    );
  }

  /// Update address
  Future<ApiResponse<Address>> updateAddress(
    int id, {
    String? street,
    String? postalCode,
    int? cityId,
    String? coordinates,
  }) async {
    return await _apiService.put<Address>(
      ApiConfig.addressById(id),
      body: {
        if (street != null) 'Street': street,
        if (postalCode != null) 'PostalCode': postalCode,
        if (cityId != null) 'CityId': cityId,
        if (coordinates != null) 'Coordinates': coordinates,
      },
      fromJson: (json) => Address.fromJson(json),
    );
  }

  /// Delete address
  Future<ApiResponse<void>> deleteAddress(int id) async {
    return await _apiService.delete(ApiConfig.addressById(id));
  }

  /// Get all addresses as list
  Future<List<Address>> getAllAddresses() async {
    final response = await getAddresses(pageSize: 200);
    if (response.success && response.data != null) {
      return response.data!.items;
    }
    return [];
  }
}

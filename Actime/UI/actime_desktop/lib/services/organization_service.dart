import '../config/api_config.dart';
import '../models/models.dart';
import 'api_service.dart';
import 'mock_api_service.dart';

class OrganizationService {
  static final OrganizationService _instance = OrganizationService._internal();
  factory OrganizationService() => _instance;
  OrganizationService._internal();

  final ApiService _apiService = ApiService();
  final MockApiService _mockService = MockApiService();

  Future<ApiResponse<PaginatedResponse<Organization>>> getOrganizations({
    int page = 1,
    int pageSize = 10,
    String? search,
    String? sortBy,
    String? sortOrder,
    int? categoryId,
  }) async {
    if (ApiConfig.useMockApi) {
      return await _mockService.getOrganizations(
        page: page,
        pageSize: pageSize,
        search: search,
        sortBy: sortBy,
      );
    }

    final queryParams = <String, String>{
      'Page': page.toString(),
      'PageSize': pageSize.toString(),
    };

    if (search != null && search.isNotEmpty) {
      queryParams['Search'] = search;
    }
    if (sortBy != null) {
      queryParams['SortBy'] = sortBy;
    }
    if (sortOrder != null) {
      queryParams['SortOrder'] = sortOrder;
    }
    if (categoryId != null) {
      queryParams['CategoryId'] = categoryId.toString();
    }

    return await _apiService.get<PaginatedResponse<Organization>>(
      ApiConfig.organization,
      queryParams: queryParams,
      fromJson: (json) => PaginatedResponse.fromJson(json, Organization.fromJson),
    );
  }

  Future<ApiResponse<Organization>> getOrganizationById(int id) async {
    if (ApiConfig.useMockApi) {
      return await _mockService.getOrganizationById(id);
    }

    return await _apiService.get<Organization>(
      ApiConfig.organizationById(id),
      fromJson: (json) => Organization.fromJson(json),
    );
  }

  Future<ApiResponse<Organization>> createOrganization({
    required String name,
    required String email,
    String? description,
    String? logoUrl,
    String? phoneNumber,
    required int userId,
    required int categoryId,
    required int addressId,
  }) async {
    return await _apiService.post<Organization>(
      ApiConfig.organization,
      body: {
        'Name': name,
        'Email': email,
        'Description': description,
        'LogoUrl': logoUrl,
        'PhoneNumber': phoneNumber,
        'UserId': userId,
        'CategoryId': categoryId,
        'AddressId': addressId,
      },
      fromJson: (json) => Organization.fromJson(json),
    );
  }

  Future<ApiResponse<Organization>> updateOrganization({
    required int id,
    String? name,
    String? email,
    String? description,
    String? logoUrl,
    String? phoneNumber,
    int? categoryId,
    int? addressId,
  }) async {
    final body = <String, dynamic>{};
    if (name != null) body['Name'] = name;
    if (email != null) body['Email'] = email;
    if (description != null) body['Description'] = description;
    if (logoUrl != null) body['LogoUrl'] = logoUrl;
    if (phoneNumber != null) body['PhoneNumber'] = phoneNumber;
    if (categoryId != null) body['CategoryId'] = categoryId;
    if (addressId != null) body['AddressId'] = addressId;

    return await _apiService.put<Organization>(
      ApiConfig.organizationById(id),
      body: body,
      fromJson: (json) => Organization.fromJson(json),
    );
  }

  Future<ApiResponse<void>> deleteOrganization(int id) async {
    if (ApiConfig.useMockApi) {
      return await _mockService.deleteOrganization(id);
    }

    return await _apiService.delete<void>(
      ApiConfig.organizationById(id),
    );
  }
}

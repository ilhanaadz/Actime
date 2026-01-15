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
    int perPage = 10,
    String? search,
    String? sortBy,
    String? sortOrder,
    String? categoryId,
  }) async {
    if (ApiConfig.useMockApi) {
      return await _mockService.getOrganizations(
        page: page,
        perPage: perPage,
        search: search,
        sortBy: sortBy,
      );
    }

    final queryParams = <String, String>{
      'page': page.toString(),
      'per_page': perPage.toString(),
    };

    if (search != null && search.isNotEmpty) {
      queryParams['search'] = search;
    }
    if (sortBy != null) {
      queryParams['sort_by'] = sortBy;
    }
    if (sortOrder != null) {
      queryParams['sort_order'] = sortOrder;
    }
    if (categoryId != null) {
      queryParams['category_id'] = categoryId;
    }

    return await _apiService.get<PaginatedResponse<Organization>>(
      ApiConfig.organizations,
      queryParams: queryParams,
      fromJson: (json) => PaginatedResponse.fromJson(json, Organization.fromJson),
    );
  }

  Future<ApiResponse<Organization>> getOrganizationById(String id) async {
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
    String? description,
    String? address,
    String? phone,
    String? email,
    String? website,
  }) async {
    return await _apiService.post<Organization>(
      ApiConfig.organizations,
      body: {
        'name': name,
        'description': description,
        'address': address,
        'phone': phone,
        'email': email,
        'website': website,
      },
      fromJson: (json) => Organization.fromJson(json),
    );
  }

  Future<ApiResponse<Organization>> updateOrganization({
    required String id,
    String? name,
    String? description,
    String? address,
    String? phone,
    String? email,
    String? website,
  }) async {
    final body = <String, dynamic>{};
    if (name != null) body['name'] = name;
    if (description != null) body['description'] = description;
    if (address != null) body['address'] = address;
    if (phone != null) body['phone'] = phone;
    if (email != null) body['email'] = email;
    if (website != null) body['website'] = website;

    return await _apiService.put<Organization>(
      ApiConfig.organizationById(id),
      body: body,
      fromJson: (json) => Organization.fromJson(json),
    );
  }

  Future<ApiResponse<void>> deleteOrganization(String id) async {
    if (ApiConfig.useMockApi) {
      return await _mockService.deleteOrganization(id);
    }

    return await _apiService.delete<void>(
      ApiConfig.organizationById(id),
    );
  }
}

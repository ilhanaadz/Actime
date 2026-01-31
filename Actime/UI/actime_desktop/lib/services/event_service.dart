import '../config/api_config.dart';
import '../models/models.dart';
import 'api_service.dart';
import 'mock_api_service.dart';

class EventService {
  static final EventService _instance = EventService._internal();
  factory EventService() => _instance;
  EventService._internal();

  final ApiService _apiService = ApiService();
  final MockApiService _mockService = MockApiService();

  Future<ApiResponse<PaginatedResponse<Event>>> getEvents({
    int page = 1,
    int pageSize = 10,
    String? search,
    String? sortBy,
    String? sortOrder,
    int? eventStatusId,
    int? organizationId,
    int? activityTypeId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    if (ApiConfig.useMockApi) {
      return await _mockService.getEvents(
        page: page,
        pageSize: pageSize,
        search: search,
        sortBy: sortBy,
        eventStatusId: eventStatusId,
        startDate: startDate,
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
    if (eventStatusId != null) {
      queryParams['EventStatusId'] = eventStatusId.toString();
    }
    if (organizationId != null) {
      queryParams['OrganizationId'] = organizationId.toString();
    }
    if (activityTypeId != null) {
      queryParams['ActivityTypeId'] = activityTypeId.toString();
    }
    if (startDate != null) {
      queryParams['StartDate'] = startDate.toIso8601String();
    }
    if (endDate != null) {
      queryParams['EndDate'] = endDate.toIso8601String();
    }

    return await _apiService.get<PaginatedResponse<Event>>(
      ApiConfig.event,
      queryParams: queryParams,
      fromJson: (json) => PaginatedResponse.fromJson(json, Event.fromJson),
    );
  }

  Future<ApiResponse<Event>> getEventById(int id) async {
    if (ApiConfig.useMockApi) {
      return await _mockService.getEventById(id);
    }

    return await _apiService.get<Event>(
      ApiConfig.eventById(id),
      fromJson: (json) => Event.fromJson(json),
    );
  }

  Future<ApiResponse<Event>> createEvent({
    required int organizationId,
    required String title,
    String? description,
    required DateTime start,
    required DateTime end,
    required int locationId,
    int? maxParticipants,
    bool isFree = true,
    double price = 0,
    required int eventStatusId,
    required int activityTypeId,
  }) async {
    return await _apiService.post<Event>(
      ApiConfig.event,
      body: {
        'OrganizationId': organizationId,
        'Title': title,
        'Description': description,
        'Start': start.toIso8601String(),
        'End': end.toIso8601String(),
        'LocationId': locationId,
        'MaxParticipants': maxParticipants,
        'IsFree': isFree,
        'Price': price,
        'EventStatusId': eventStatusId,
        'ActivityTypeId': activityTypeId,
      },
      fromJson: (json) => Event.fromJson(json),
    );
  }

  Future<ApiResponse<Event>> updateEvent({
    required int id,
    String? title,
    String? description,
    DateTime? start,
    DateTime? end,
    int? locationId,
    int? maxParticipants,
    bool? isFree,
    double? price,
    int? eventStatusId,
    int? activityTypeId,
  }) async {
    final body = <String, dynamic>{};
    if (title != null) body['Title'] = title;
    if (description != null) body['Description'] = description;
    if (start != null) body['Start'] = start.toIso8601String();
    if (end != null) body['End'] = end.toIso8601String();
    if (locationId != null) body['LocationId'] = locationId;
    if (maxParticipants != null) body['MaxParticipants'] = maxParticipants;
    if (isFree != null) body['IsFree'] = isFree;
    if (price != null) body['Price'] = price;
    if (eventStatusId != null) body['EventStatusId'] = eventStatusId;
    if (activityTypeId != null) body['ActivityTypeId'] = activityTypeId;

    return await _apiService.put<Event>(
      ApiConfig.eventById(id),
      body: body,
      fromJson: (json) => Event.fromJson(json),
    );
  }

  Future<ApiResponse<void>> deleteEvent(int id) async {
    if (ApiConfig.useMockApi) {
      return await _mockService.deleteEvent(id);
    }

    return await _apiService.delete<void>(
      ApiConfig.eventById(id),
    );
  }
}

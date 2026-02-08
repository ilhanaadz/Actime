import '../config/api_config.dart';
import '../constants/participation_constants.dart';
import '../models/models.dart';
import 'api_service.dart';
import 'auth_service.dart';

/// Participant model for event participants
class Participant {
  final String id;
  final String eventId;
  final String userId;
  final String? userName;
  final String? userEmail;
  final String? userPhone;
  final String? userAvatar;
  final DateTime joinedAt;
  final bool isPaid;

  Participant({
    required this.id,
    required this.eventId,
    required this.userId,
    this.userName,
    this.userEmail,
    this.userPhone,
    this.userAvatar,
    required this.joinedAt,
    this.isPaid = false,
  });

  /// Get user object from participant data
  User get user => User(
    id: userId,
    name: userName ?? '',
    email: userEmail ?? '',
    profileImageUrl: userAvatar,
    createdAt: joinedAt,
  );

  factory Participant.fromJson(Map<String, dynamic> json) {
    return Participant(
      id: (json['Id'] ?? json['id'])?.toString() ?? '0',
      eventId: (json['EventId'] ?? json['eventId'])?.toString() ?? '0',
      userId: (json['UserId'] ?? json['userId'])?.toString() ?? '0',
      userName: json['UserName'] as String? ?? json['userName'] as String?,
      userEmail: json['UserEmail'] as String? ?? json['userEmail'] as String?,
      userPhone: json['UserPhone'] as String? ?? json['userPhone'] as String?,
      userAvatar: json['UserAvatar'] as String? ?? json['userAvatar'] as String?,
      joinedAt: DateTime.tryParse(json['JoinedAt']?.toString() ?? json['joinedAt']?.toString() ?? '') ?? DateTime.now(),
      isPaid: json['IsPaid'] as bool? ?? json['isPaid'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Id': id,
      'EventId': eventId,
      'UserId': userId,
      'UserName': userName,
      'UserEmail': userEmail,
      'UserPhone': userPhone,
      'UserAvatar': userAvatar,
      'JoinedAt': joinedAt.toIso8601String(),
      'IsPaid': isPaid,
    };
  }
}

/// Event service
/// Communicates with backend EventController
class EventService {
  static final EventService _instance = EventService._internal();
  factory EventService() => _instance;
  EventService._internal();

  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();

  /// Get events (paginated)
  /// Backend uses TextSearchObject for filtering
  Future<ApiResponse<PaginatedResponse<Event>>> getEvents({
    int page = 1,
    int pageSize = 10,
    int? perPage,
    String? text,
    String? search,
    String? sortBy,
    bool sortDescending = false,
    bool includeTotalCount = true,
    EventStatus? status,
  }) async {
    final effectivePageSize = perPage ?? pageSize;
    final effectiveSearch = search ?? text;

    return await _apiService.get<PaginatedResponse<Event>>(
      ApiConfig.event,
      queryParams: {
        'Page': page.toString(),
        'PageSize': effectivePageSize.toString(),
        'IncludeTotalCount': includeTotalCount.toString(),
        if (effectiveSearch != null && effectiveSearch.isNotEmpty) 'Text': effectiveSearch,
        if (sortBy != null) 'SortBy': sortBy,
        if (status != null) 'EventStatusId': status.id.toString(),
        'SortDescending': sortDescending.toString(),
      },
      fromJson: (json) => PaginatedResponse.fromJson(json, Event.fromJson),
    );
  }

  /// Get event by ID
  Future<ApiResponse<Event>> getEventById(String id) async {
    return await _apiService.get<Event>(
      '${ApiConfig.event}/$id',
      fromJson: (json) => Event.fromJson(json),
    );
  }

  /// Create event
  /// Request body: EventInsertRequest
  Future<ApiResponse<Event>> createEvent(Map<String, dynamic> data) async {
    return await _apiService.post<Event>(
      ApiConfig.event,
      body: data,
      fromJson: (json) => Event.fromJson(json),
    );
  }

  /// Update event
  /// Request body: EventUpdateRequest (all fields optional)
  Future<ApiResponse<Event>> updateEvent(String id, Map<String, dynamic> data) async {
    return await _apiService.put<Event>(
      '${ApiConfig.event}/$id',
      body: data,
      fromJson: (json) => Event.fromJson(json),
    );
  }

  /// Delete event
  Future<ApiResponse<void>> deleteEvent(String id) async {
    return await _apiService.delete('${ApiConfig.event}/$id');
  }

  /// Join event (participate)
  /// Sets appropriate status values based on whether event is free or paid.
  /// [paymentMethodId] is provided after successful (dummy) checkout for paid events.
  Future<ApiResponse<void>> joinEvent(Event event, {int? paymentMethodId}) async {
    final userId = _authService.currentUserId;
    if (userId == null) {
      return ApiResponse.error('Morate biti prijavljeni');
    }

    final body = <String, dynamic>{
      'EventId': int.tryParse(event.id) ?? 0,
      'UserId': userId,
    };

    if (event.isFree) {
      // Free event - no payment involved, leave PaymentStatusId/PaymentMethodId null
      body['AttendanceStatusId'] = AttendanceStatus.going;
    } else {
      // Paid event - checkout already completed, mark as paid with selected method
      body['AttendanceStatusId'] = AttendanceStatus.going;
      body['PaymentStatusId'] = PaymentStatus.paid;
      body['PaymentMethodId'] = paymentMethodId ?? PaymentMethod.other;
    }

    final response = await _apiService.post<Map<String, dynamic>>(
      ApiConfig.participation,
      body: body,
      fromJson: (json) => json,
    );

    if (response.success) {
      return ApiResponse.success(null, message: 'Uspješno ste se prijavili na događaj');
    }
    return ApiResponse.error(response.message ?? 'Greška pri prijavi');
  }

  /// Leave event (cancel participation)
  Future<ApiResponse<void>> leaveEvent(String eventId) async {
    final userId = _authService.currentUserId;
    if (userId == null) {
      return ApiResponse.error('Morate biti prijavljeni');
    }

    final response = await _apiService.delete(
      '${ApiConfig.participation}/event/$eventId/user/$userId',
    );

    if (response.success) {
      return ApiResponse.success(null, message: 'Uspješno ste se odjavili sa događaja');
    }
    return ApiResponse.error(response.message ?? 'Greška pri odjavi');
  }

  /// Get organization events
  Future<ApiResponse<PaginatedResponse<Event>>> getOrganizationEvents(
    String organizationId, {
    int page = 1,
    int perPage = 10,
    String? search,
    String? sortBy,
    bool sortDescending = false,
    EventStatus? status,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return await _apiService.get<PaginatedResponse<Event>>(
      ApiConfig.event,
      queryParams: {
        'Page': page.toString(),
        'PageSize': perPage.toString(),
        'OrganizationId': organizationId,
        'IncludeTotalCount': 'true',
        if (search != null && search.isNotEmpty) 'Text': search,
        if (sortBy != null) 'SortBy': sortBy,
        'SortDescending': sortDescending.toString(),
        if (status != null) 'EventStatusId': status.id.toString(),
        if (startDate != null) 'FromDate': startDate.toIso8601String(),
        if (endDate != null) 'ToDate': endDate.toIso8601String(),
      },
      fromJson: (json) => PaginatedResponse.fromJson(json, Event.fromJson),
    );
  }

  /// Get event participants
 Future<ApiResponse<List<User>>> getEventParticipants(String eventId) async {
  return await _apiService.get<List<User>>(
    '${ApiConfig.participation}/participants/$eventId',
    fromJson: (json) {
      final list = json as List<dynamic>;

      return list
          .map((e) => User.fromJson(e as Map<String, dynamic>))
          .toList();
    },
  );
}

  /// Get recommended events for user
  /// Uses RecommendationController endpoint
  Future<ApiResponse<List<Event>>> getRecommendedEvents({int top = 5}) async {
    final userId = _authService.currentUserId;
    if (userId == null) {
      return ApiResponse.error('Morate biti prijavljeni');
    }

    return await _apiService.get<List<Event>>(
      ApiConfig.recommendedEvents(userId, top: top),
      fromJson: (json) => parseListResponse(json, Event.fromJson),
    );
  }
}

import '../config/api_config.dart';
import '../models/models.dart';
import 'api_service.dart';

class ParticipationService {
  static final ParticipationService _instance = ParticipationService._internal();
  factory ParticipationService() => _instance;
  ParticipationService._internal();

  final ApiService _apiService = ApiService();

  Future<ApiResponse<PaginatedResponse<Participation>>> getParticipations({
    int page = 1,
    int pageSize = 10,
    int? userId,
    int? eventId,
  }) async {
    final queryParams = <String, String>{
      'Page': page.toString(),
      'PageSize': pageSize.toString(),
    };

    if (userId != null) {
      queryParams['UserId'] = userId.toString();
    }
    if (eventId != null) {
      queryParams['EventId'] = eventId.toString();
    }

    return await _apiService.get<PaginatedResponse<Participation>>(
      ApiConfig.participation,
      queryParams: queryParams,
      fromJson: (json) => PaginatedResponse.fromJson(json, Participation.fromJson),
    );
  }

  Future<ApiResponse<Participation>> getParticipationById(int id) async {
    return await _apiService.get<Participation>(
      ApiConfig.participationById(id),
      fromJson: (json) => Participation.fromJson(json),
    );
  }

  Future<ApiResponse<Participation>> createParticipation({
    required int userId,
    required int eventId,
  }) async {
    return await _apiService.post<Participation>(
      ApiConfig.participation,
      body: {
        'UserId': userId,
        'EventId': eventId,
      },
      fromJson: (json) => Participation.fromJson(json),
    );
  }

  Future<ApiResponse<Participation>> updateParticipation({
    required int id,
    bool? attended,
  }) async {
    final body = <String, dynamic>{};
    if (attended != null) body['Attended'] = attended;

    return await _apiService.put<Participation>(
      ApiConfig.participationById(id),
      body: body,
      fromJson: (json) => Participation.fromJson(json),
    );
  }

  Future<ApiResponse<void>> deleteParticipation(int id) async {
    return await _apiService.delete<void>(
      ApiConfig.participationById(id),
    );
  }
}

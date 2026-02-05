import '../config/api_config.dart';
import '../models/api_response.dart';
import 'api_service.dart';

/// Handles communication with the backend Stripe endpoints.
class StripePaymentService {
  static final StripePaymentService _instance = StripePaymentService._internal();
  factory StripePaymentService() => _instance;
  StripePaymentService._internal();

  final ApiService _apiService = ApiService();

  /// Calls backend POST /Payment/create-intent and returns the Stripe clientSecret.
  Future<ApiResponse<String>> createPaymentIntent(int eventId) async {
    final response = await _apiService.post<Map<String, dynamic>>(
      ApiConfig.paymentCreateIntent,
      body: {'EventId': eventId},
      fromJson: (json) => json as Map<String, dynamic>,
    );

    if (response.success && response.data != null) {
      final clientSecret = response.data!['clientSecret'] as String;
      return ApiResponse.success(clientSecret);
    }

    return ApiResponse.error(response.message ?? 'Greška pri kreanju plaćanja');
  }
}

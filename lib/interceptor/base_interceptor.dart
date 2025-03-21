import 'package:doh_api_client/utils/doh_response_model.dart';

/// API request interceptor
abstract class BaseDohInterceptor {
  /// Called before the request is sent
  void onRequest(String method, String url, Map<String, dynamic> headers,
      [String? body, String dohProvider]);

  /// Called after the response is received
  void onResponse(String method, String url, DohResponse response);

  /// Called when an error occurs
  void onError(String method, String url, dynamic error);
}

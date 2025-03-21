import 'package:doh_api_client/utils/doh_response_model.dart';
import 'package:doh_api_client/interceptor/base_interceptor.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'client.dart';
import 'method_channel.dart';

abstract class DohApiClientPlatform extends PlatformInterface {
  /// Constructs a DohApiClientPlatform.
  DohApiClientPlatform() : super(token: _token);

  static final Object _token = Object();

  static DohApiClientPlatform _instance = MethodChannelDohApiClient();

  /// The default instance of [DohApiClientPlatform] to use.
  ///
  /// Defaults to [MethodChannelDohApiClient].
  static DohApiClientPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [DohApiClientPlatform] when
  /// they register themselves.
  static set instance(DohApiClientPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Add an interceptor
  void addInterceptor(BaseDohInterceptor interceptor) {
    throw UnimplementedError();
  }

  /// Remove an interceptor
  void removeInterceptor(BaseDohInterceptor interceptor) {
    throw UnimplementedError();
  }

  /// Clear all interceptors
  void clearInterceptors() {
    throw UnimplementedError();
  }

  Future<DohResponse> get(
      String url, Map<String, dynamic> headers, DohProvider dohProvider) {
    throw UnimplementedError('get() has not been implemented');
  }

  Future<DohResponse> post(String url, Map<String, dynamic> headers,
      String body, DohProvider dohProvider) {
    throw UnimplementedError('post() has not been implemented');
  }

  Future<DohResponse> put(String url, Map<String, dynamic> headers, String body,
      DohProvider dohProvider) {
    throw UnimplementedError('put() has not been implemented');
  }

  Future<DohResponse> patch(String url, Map<String, dynamic> headers,
      String body, DohProvider dohProvider) {
    throw UnimplementedError('patch() has not been implemented');
  }

  Future<DohResponse> delete(
      String url, Map<String, dynamic> headers, DohProvider dohProvider) {
    throw UnimplementedError('patch() has not been implemented');
  }
}

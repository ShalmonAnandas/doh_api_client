import 'package:doh_api_client/utils/doh_response_model.dart';
import 'package:doh_api_client/interceptor/base_interceptor.dart';

import 'platform_interface.dart';

class DohApiClient {
  /// Add an interceptor
  void addInterceptor(BaseDohInterceptor interceptor) {
    return DohApiClientPlatform.instance.addInterceptor(interceptor);
  }

  /// Remove an interceptor
  void removeInterceptor(BaseDohInterceptor interceptor) {
    return DohApiClientPlatform.instance.removeInterceptor(interceptor);
  }

  /// Clear all interceptors
  void clearInterceptors() {
    return DohApiClientPlatform.instance.clearInterceptors();
  }

  Future<DohResponse> get(
      {required String url,
      Map<String, dynamic>? headers,
      DohProvider? dohProvider}) {
    return DohApiClientPlatform.instance
        .get(url, headers ?? {}, dohProvider ?? DohProvider.CloudFlare);
  }

  Future<DohResponse> post(
      {required String url,
      Map<String, dynamic>? headers,
      String? body,
      DohProvider? dohProvider}) {
    return DohApiClientPlatform.instance.post(
        url, headers ?? {}, body ?? "", dohProvider ?? DohProvider.CloudFlare);
  }

  Future<DohResponse> put(
      {required String url,
      Map<String, dynamic>? headers,
      String? body,
      DohProvider? dohProvider}) {
    return DohApiClientPlatform.instance.put(
        url, headers ?? {}, body ?? "", dohProvider ?? DohProvider.CloudFlare);
  }

  Future<DohResponse> patch(
      {required String url,
      Map<String, dynamic>? headers,
      String? body,
      DohProvider? dohProvider}) {
    return DohApiClientPlatform.instance.patch(
        url, headers ?? {}, body ?? "", dohProvider ?? DohProvider.CloudFlare);
  }

  Future<DohResponse> delete(
      {required String url,
      Map<String, dynamic>? headers,
      DohProvider? dohProvider}) {
    return DohApiClientPlatform.instance
        .delete(url, headers ?? {}, dohProvider ?? DohProvider.CloudFlare);
  }
}

enum DohProvider {
  CloudFlare,
  Google,
  AdGuard,
  Quad9,
  AliDNS,
  DNSPod,
  threeSixty,
  Quad101,
  Mullvad,
  ControlD,
  Najalla,
  SheCan
}

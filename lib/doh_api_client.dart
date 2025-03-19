import 'package:doh_api_client/doh_response_model.dart';

import 'doh_api_client_platform_interface.dart';

class DohApiClient {
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

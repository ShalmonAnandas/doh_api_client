import 'doh_api_client_platform_interface.dart';

class DohApiClient {
  Future<Map<String, dynamic>?> get(
      {required String url,
      Map<String, dynamic>? headers,
      DohProvider? dohProvider}) {
    return DohApiClientPlatform.instance
        .get(url, headers ?? {}, dohProvider ?? DohProvider.CloudFlare);
  }

  Future<Map<String, dynamic>?> post(
      {required String url,
      Map<String, dynamic>? headers,
      String? body,
      DohProvider? dohProvider}) {
    return DohApiClientPlatform.instance.post(
        url, headers ?? {}, body ?? "", dohProvider ?? DohProvider.CloudFlare);
  }

  Future<Map<String, dynamic>?> put(
      {required String url,
      Map<String, dynamic>? headers,
      String? body,
      DohProvider? dohProvider}) {
    return DohApiClientPlatform.instance.put(
        url, headers ?? {}, body ?? "", dohProvider ?? DohProvider.CloudFlare);
  }

  Future<Map<String, dynamic>?> patch(
      {required String url,
      Map<String, dynamic>? headers,
      String? body,
      DohProvider? dohProvider}) {
    return DohApiClientPlatform.instance.patch(
        url, headers ?? {}, body ?? "", dohProvider ?? DohProvider.CloudFlare);
  }

  Future<Map<String, dynamic>?> delete(
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

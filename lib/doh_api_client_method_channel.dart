import 'package:doh_api_client/response_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'doh_api_client.dart';
import 'doh_api_client_platform_interface.dart';

/// An implementation of [DohApiClientPlatform] that uses method channels.
class MethodChannelDohApiClient extends DohApiClientPlatform
    with ResponseUtils {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('doh_api_client');

  @override
  Future<Map<String, dynamic>?> get(
      String url, Map<String, dynamic> headers, DohProvider dohProvider) async {
    final result = await methodChannel.invokeMethod('makeGetRequest', {
      'url': url,
      'headers': headers,
      "dohProvider": dohProvider.toString()
    });

    if (result == null) return null;
    return convertMap(result as Map<Object?, Object?>);
  }

  @override
  Future<Map<String, dynamic>?> post(String url, Map<String, dynamic> headers,
      String body, DohProvider dohProvider) async {
    final result = await methodChannel.invokeMethod('makePostRequest', {
      'url': url,
      'headers': headers,
      'body': body,
      "dohProvider": dohProvider.toString()
    });

    if (result == null) return null;
    return convertMap(result as Map<Object?, Object?>);
  }

  @override
  Future<Map<String, dynamic>?> put(String url, Map<String, dynamic> headers,
      String body, DohProvider dohProvider) async {
    final result = await methodChannel.invokeMethod('makePutRequest', {
      'url': url,
      'headers': headers,
      'body': body,
      "dohProvider": dohProvider.toString()
    });

    if (result == null) return null;
    return convertMap(result as Map<Object?, Object?>);
  }

  @override
  Future<Map<String, dynamic>?> patch(String url, Map<String, dynamic> headers,
      String body, DohProvider dohProvider) async {
    final result = await methodChannel.invokeMethod('makePatchRequest', {
      'url': url,
      'headers': headers,
      'body': body,
      "dohProvider": dohProvider.toString()
    });

    if (result == null) return null;
    return convertMap(result as Map<Object?, Object?>);
  }

  @override
  Future<Map<String, dynamic>?> delete(
      String url, Map<String, dynamic> headers, DohProvider dohProvider) async {
    final result = await methodChannel.invokeMethod('makeDeleteRequest', {
      'url': url,
      'headers': headers,
      "dohProvider": dohProvider.toString()
    });

    if (result == null) return null;
    return convertMap(result as Map<Object?, Object?>);
  }
}

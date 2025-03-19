import 'package:doh_api_client/doh_response_model.dart';
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
  Future<DohResponse> get(
      String url, Map<String, dynamic> headers, DohProvider dohProvider) async {
    final result = await methodChannel.invokeMethod('makeGetRequest', {
      'url': url,
      'headers': headers,
      "dohProvider": dohProvider.toString()
    });

    return _returnResponse(result);
  }

  @override
  Future<DohResponse> post(String url, Map<String, dynamic> headers,
      String body, DohProvider dohProvider) async {
    final result = await methodChannel.invokeMethod('makePostRequest', {
      'url': url,
      'headers': headers,
      'body': body,
      "dohProvider": dohProvider.toString()
    });

    return _returnResponse(result);
  }

  @override
  Future<DohResponse> put(String url, Map<String, dynamic> headers,
      String body, DohProvider dohProvider) async {
    final result = await methodChannel.invokeMethod('makePutRequest', {
      'url': url,
      'headers': headers,
      'body': body,
      "dohProvider": dohProvider.toString()
    });

    return _returnResponse(result);
  }

  @override
  Future<DohResponse> patch(String url, Map<String, dynamic> headers,
      String body, DohProvider dohProvider) async {
    final result = await methodChannel.invokeMethod('makePatchRequest', {
      'url': url,
      'headers': headers,
      'body': body,
      "dohProvider": dohProvider.toString()
    });

    return _returnResponse(result);
  }

  @override
  Future<DohResponse> delete(
      String url, Map<String, dynamic> headers, DohProvider dohProvider) async {
    final result = await methodChannel.invokeMethod('makeDeleteRequest', {
      'url': url,
      'headers': headers,
      "dohProvider": dohProvider.toString()
    });

    return _returnResponse(result);
  }

  DohResponse _returnResponse(result) {
    if (result == null) {
      return DohResponse(
          data: {}, message: "Unkown Error", statusCode: 520);
    } else {
      final map = convertMap(result as Map<Object?, Object?>);
      if (map["success"] == false) {
        return DohResponse(
            statusCode: map["code"], message: map["message"], data: {});
      } else {
        return DohResponse(
            data: map["data"], message: "", statusCode: map["code"]);
      }
    }
  }
}

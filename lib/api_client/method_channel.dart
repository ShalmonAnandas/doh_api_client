import 'package:doh_api_client/utils/doh_response_model.dart';
import 'package:doh_api_client/interceptor/base_interceptor.dart';
import 'package:doh_api_client/utils/response_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'client.dart';
import 'platform_interface.dart';

/// An implementation of [DohApiClientPlatform] that uses method channels.
class MethodChannelDohApiClient extends DohApiClientPlatform
    with ResponseUtils {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('doh_api_client');

  final List<BaseDohInterceptor> interceptors = [];

  /// Add an interceptor
  @override
  void addInterceptor(BaseDohInterceptor interceptor) {
    interceptors.add(interceptor);
  }

  /// Remove an interceptor
  @override
  void removeInterceptor(BaseDohInterceptor interceptor) {
    interceptors.remove(interceptor);
  }

  /// Clear all interceptors
  @override
  void clearInterceptors() {
    interceptors.clear();
  }

  @override
  Future<DohResponse> get(
      String url, Map<String, dynamic> headers, DohProvider dohProvider) async {
    return await makeRequest(
      method: 'makeGetRequest',
      request: {
        'url': url,
        'headers': headers,
        "dohProvider": dohProvider.toString()
      },
    );
  }

  @override
  Future<DohResponse> post(String url, Map<String, dynamic> headers,
      String body, DohProvider dohProvider) async {
    return await makeRequest(
      method: 'makePostRequest',
      request: {
        'url': url,
        'headers': headers,
        'body': body,
        "dohProvider": dohProvider.toString()
      },
    );
  }

  @override
  Future<DohResponse> put(String url, Map<String, dynamic> headers, String body,
      DohProvider dohProvider) async {
    return await makeRequest(
      method: 'makePutRequest',
      request: {
        'url': url,
        'headers': headers,
        'body': body,
        "dohProvider": dohProvider.toString()
      },
    );
  }

  @override
  Future<DohResponse> patch(String url, Map<String, dynamic> headers,
      String body, DohProvider dohProvider) async {
    return await makeRequest(
      method: 'makePatchRequest',
      request: {
        'url': url,
        'headers': headers,
        'body': body,
        "dohProvider": dohProvider.toString()
      },
    );
  }

  @override
  Future<DohResponse> delete(
      String url, Map<String, dynamic> headers, DohProvider dohProvider) async {
    return await makeRequest(
      method: 'makeDeleteRequest',
      request: {
        'url': url,
        'headers': headers,
        "dohProvider": dohProvider.toString()
      },
    );
  }

  Future<DohResponse> makeRequest(
      {required String method, required Map<String, dynamic> request}) async {
    final url = request['url'];
    final headers = request['headers'];
    final body = request['body'];
    final dohProvider = request['dohProvider'];

    final requestType =
        method.replaceAll("make", "").replaceAll("request", "").toUpperCase();

    for (final interceptor in interceptors) {
      interceptor.onRequest(requestType, url, headers, body, dohProvider);
    }

    try {
      final result = await methodChannel.invokeMethod(method, request);

      final response = _returnResponse(result);

      for (final interceptor in interceptors) {
        interceptor.onResponse(requestType, url, response);
      }

      return response;
    } catch (er) {
      for (final interceptor in interceptors) {
        interceptor.onError(requestType, url, er);
      }
      rethrow;
    }
  }

  DohResponse _returnResponse(result) {
    if (result == null) {
      return DohResponse(data: {}, message: "Unkown Error", statusCode: 520);
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

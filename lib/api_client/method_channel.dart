import 'dart:async';
import 'dart:isolate';

import 'package:doh_api_client/utils/doh_response_model.dart';
import 'package:doh_api_client/interceptor/base_interceptor.dart';
import 'package:doh_api_client/utils/response_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'client.dart';
import 'platform_interface.dart';

/// An implementation of [DohApiClientPlatform] that uses method channels with async interceptors.
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

  /// Run interceptor method in an isolate
  Future<void> _runInterceptorIsolate({
    required String method,
    required BaseDohInterceptor interceptor,
    required String requestType,
    required String url,
    Map<String, dynamic>? headers,
    dynamic body,
    String? dohProvider,
    DohResponse? response,
    dynamic error,
  }) async {
    final receivePort = ReceivePort();
    final isolate = await Isolate.spawn(_isolateFunction, receivePort.sendPort);
    final sendPort = await receivePort.first as SendPort;

    final completer = Completer<void>();
    final responsePort = ReceivePort();
    sendPort.send([
      responsePort.sendPort,
      method,
      interceptor,
      requestType,
      url,
      headers,
      body,
      dohProvider,
      response,
      error,
    ]);

    responsePort.listen((message) {
      if (message == 'done') {
        completer.complete();
        responsePort.close(); // Close the response port
        receivePort.close(); // Close the receive port
        isolate.kill(priority: Isolate.immediate); // Kill the isolate
      }
    });

    return completer.future;
  }

  /// Static function to run in isolate
  static void _isolateFunction(SendPort mainSendPort) {
    final receivePort = ReceivePort();
    mainSendPort.send(receivePort.sendPort);

    receivePort.listen((message) async {
      final SendPort replyPort = message[0];
      final String method = message[1];
      final BaseDohInterceptor interceptor = message[2];
      final String requestType = message[3];
      final String url = message[4];
      final Map<String, dynamic>? headers = message[5];
      final dynamic body = message[6];
      final String? dohProvider = message[7];
      final DohResponse? response = message[8];
      final dynamic error = message[9];

      // Run the appropriate interceptor method based on the method name
      switch (method) {
        case 'onRequest':
          interceptor.onRequest(
              requestType, url, headers ?? {}, body, dohProvider ?? "");
          break;
        case 'onResponse':
          interceptor.onResponse(
              requestType, url, response ?? DohResponse.empty());
          break;
        case 'onError':
          interceptor.onError(requestType, url, error);
          break;
      }

      replyPort.send('done');
    });
  }

  Future<DohResponse> makeRequest(
      {required String method, required Map<String, dynamic> request}) async {
    final url = request['url'];
    final headers = request['headers'];
    final body = request['body'];
    final dohProvider = request['dohProvider'];

    final requestType =
        method.replaceAll("make", "").replaceAll("request", "").toUpperCase();

    // Run onRequest interceptors asynchronously
    await Future.wait(interceptors.map((interceptor) => _runInterceptorIsolate(
          method: 'onRequest',
          interceptor: interceptor,
          requestType: requestType,
          url: url,
          headers: headers,
          body: body,
          dohProvider: dohProvider,
        )));

    try {
      final result = await methodChannel.invokeMethod(method, request);

      final response = _returnResponse(result);

      // Run onResponse interceptors asynchronously
      await Future.wait(
          interceptors.map((interceptor) => _runInterceptorIsolate(
                method: 'onResponse',
                interceptor: interceptor,
                requestType: requestType,
                url: url,
                response: response,
              )));

      return response;
    } catch (er) {
      // Run onError interceptors asynchronously
      await Future.wait(
          interceptors.map((interceptor) => _runInterceptorIsolate(
                method: 'onError',
                interceptor: interceptor,
                requestType: requestType,
                url: url,
                error: er,
              )));
      rethrow;
    }
  }

  DohResponse _returnResponse(result) {
    if (result == null) {
      return DohResponse(data: {}, message: "Unknown Error", statusCode: 520);
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

import 'dart:math';

import 'package:doh_api_client/doh_response_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:doh_api_client/doh_api_client.dart';
import 'package:doh_api_client/doh_api_client_platform_interface.dart';
import 'package:doh_api_client/doh_api_client_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockDohApiClientPlatform
    with MockPlatformInterfaceMixin
    implements DohApiClientPlatform {
  final tResponseModel =
      DohResponse(statusCode: 01, message: "message", data: {});

  @override
  Future<DohResponse> get(
          String url, Map<String, dynamic>? headers, DohProvider dohProvider) =>
      Future.value(tResponseModel);

  @override
  Future<DohResponse> post(String url, Map<String, dynamic>? headers,
          String? body, DohProvider dohProvider) =>
      Future.value(tResponseModel);

  @override
  Future<DohResponse> put(String url, Map<String, dynamic>? headers,
          String? body, DohProvider dohProvider) =>
      Future.value(tResponseModel);

  @override
  Future<DohResponse> patch(String url, Map<String, dynamic>? headers,
          String? body, DohProvider dohProvider) =>
      Future.value(tResponseModel);

  @override
  Future<DohResponse> delete(
          String url, Map<String, dynamic>? headers, DohProvider dohProvider) =>
      Future.value(tResponseModel);
}

void main() {
  final DohApiClientPlatform initialPlatform = DohApiClientPlatform.instance;

  test('$MethodChannelDohApiClient is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelDohApiClient>());
  });

  test('getPlatformVersion', () async {
    MockDohApiClientPlatform fakePlatform = MockDohApiClientPlatform();
    DohApiClientPlatform.instance = fakePlatform;
  });
}

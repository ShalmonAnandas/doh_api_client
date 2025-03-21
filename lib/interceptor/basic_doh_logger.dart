import 'dart:convert';

import 'package:doh_api_client/utils/doh_response_model.dart';
import 'package:doh_api_client/interceptor/base_interceptor.dart';
import 'package:flutter/foundation.dart';

/// Default logger interceptor implementation
class BasicDohLogger implements BaseDohInterceptor {
  final bool enablePrettyPrint;

  BasicDohLogger({this.enablePrettyPrint = true});

  @override
  void onRequest(String method, String url, Map<String, dynamic> headers,
      [String? body, String? dohProvider]) {
    final String logMessage = '''
--> $method $url
HEADERS: ${_formatJson(headers)}
${body != null ? 'BODY: ${_formatJson(json.decode(body))}' : 'NO BODY'}
DOHPROVIDER: $dohProvider
--> END $method
''';

    debugPrint(logMessage);
  }

  @override
  void onResponse(String method, String url, DohResponse response) {
    final String logMessage = '''
<-- ${response.statusCode} | $method | $url
BODY: ${_formatJson(response.data)}
<-- END HTTP
''';

    debugPrint(logMessage);
  }

  @override
  void onError(String method, String url, dynamic error) {
    debugPrint('<-- ERROR $method $url');
    debugPrint(error.toString());
    debugPrint('<-- END ERROR');
  }

  String _formatJson(dynamic json) {
    if (!enablePrettyPrint) {
      return json.toString();
    }

    const encoder = JsonEncoder.withIndent('  ');
    try {
      return encoder.convert(json);
    } catch (e) {
      return json.toString();
    }
  }
}

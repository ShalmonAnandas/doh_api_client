import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:doh_api_client/utils/doh_response_model.dart';
import 'package:doh_api_client/interceptor/base_interceptor.dart';
import 'package:flutter/foundation.dart';

/// Credits to https://github.com/Milad-Akarie/pretty_dio_logger for providing such a comprehensive logger

/// A pretty logger for DoH API Client
/// it will print request/response info with a pretty format
class PrettyDohLogger implements BaseDohInterceptor {
  /// Print request info
  final bool request;

  /// Print request header
  final bool requestHeader;

  /// Print request body
  final bool requestBody;

  /// Print response body
  final bool responseBody;

  /// Print error message
  final bool error;

  /// InitialTab count to print json response
  static const int kInitialTab = 1;

  /// 1 tab length
  static const String tabStep = '    ';

  /// Print compact json response
  final bool compact;

  /// Width size per print
  final int maxWidth;

  /// Size in which the Uint8List will be split
  static const int chunkSize = 20;

  /// Log printer; defaults print log to console.
  /// In flutter, you'd better use debugPrint.
  final void Function(String,
      {Object? error,
      int level,
      String name,
      int? sequenceNumber,
      StackTrace? stackTrace,
      DateTime? time,
      Zone? zone}) logPrint;

  /// Enable logger
  final bool enabled;

  /// Request start timestamps
  final Map<String, int> _requestTimestamps = {};

  /// Default constructor
  PrettyDohLogger({
    this.request = true,
    this.requestHeader = false,
    this.requestBody = true,
    this.responseBody = true,
    this.error = true,
    this.maxWidth = 90,
    this.compact = true,
    this.logPrint = log,
    this.enabled = true,
  });

  @override
  void onRequest(String method, String url, Map<String, dynamic> headers,
      [String? body, String? dohProvider]) {
    if (!enabled) return;

    // Store timestamp for calculating response time
    _requestTimestamps[url] = DateTime.now().millisecondsSinceEpoch;

    if (request) {
      _printRequestHeader(method, url);
    }

    if (requestHeader) {
      _printMapAsTable(headers, header: 'Headers');
    }

    if (requestBody && body != null && method != 'GET' && method != 'DELETE') {
      final requestBlock = StringBuffer('╔ Body\n');
      try {
        final dynamic data = json.decode(body);
        if (data is Map) {
          requestBlock.write(_formatPrettyMap(data));
        } else if (data is List) {
          requestBlock.write('${_indent()}[\n');
          requestBlock.write(_formatList(data));
          requestBlock.write('${_indent()}]\n');
        } else {
          requestBlock.write(body);
        }
      } catch (e) {
        requestBlock.write(body);
      }
      requestBlock.write('╚ ${_repeatChar('═', maxWidth)}');
      logPrint(requestBlock.toString());
    }
  }

  @override
  void onResponse(String method, String url, DohResponse response) {
    if (!enabled) return;

    // Calculate response time
    final int startTime =
        _requestTimestamps[url] ?? DateTime.now().millisecondsSinceEpoch;
    final int responseTime = DateTime.now().millisecondsSinceEpoch - startTime;

    // Clean up timestamp
    _requestTimestamps.remove(url);

    _printResponseHeader(method, url, response.statusCode, responseTime);

    if (responseBody) {
      final responseBlock = StringBuffer('╔ Body\n');
      final data = response.data;
      // ignore: unnecessary_type_check
      if (data is Map) {
        responseBlock.write(_formatPrettyMap(data));
      } else if (data is Uint8List) {
        responseBlock.write('${_indent()}[\n');
        responseBlock.write(_formatUint8List(data as Uint8List));
        responseBlock.write('${_indent()}]\n');
      } else if (data is List) {
        responseBlock.write('${_indent()}[\n');
        responseBlock.write(_formatList(data as List));
        responseBlock.write('${_indent()}]\n');
      } else {
        responseBlock.write(data.toString());
      }
      responseBlock.write('╚ ${_repeatChar('═', maxWidth)}');
      logPrint(responseBlock.toString());
    }
  }

  @override
  void onError(String method, String url, dynamic error) {
    if (!enabled || !this.error) return;

    // Clean up timestamp
    _requestTimestamps.remove(url);

    final errorBlock = StringBuffer();
    errorBlock.writeln('╔╣ Error ║ $method');
    errorBlock.writeln('║  $url');
    errorBlock.writeln('║  $error');
    errorBlock.write('╚ ${_repeatChar('═', maxWidth)}');
    logPrint(errorBlock.toString());
  }

  String _formatPrettyMap(
    Map data, {
    int initialTab = kInitialTab,
    bool isListItem = false,
    bool isLast = false,
  }) {
    final buffer = StringBuffer();
    var tabs = initialTab;
    final isRoot = tabs == kInitialTab;
    final initialIndent = _indent(tabs);
    tabs++;

    if (isRoot || isListItem) buffer.write('║$initialIndent{\n');

    for (var index = 0; index < data.length; index++) {
      final isLast = index == data.length - 1;
      final key = '"${data.keys.elementAt(index)}"';
      dynamic value = data[data.keys.elementAt(index)];

      // Format string values
      if (value is String) {
        value = '"${value.toString().replaceAll(RegExp(r'([\r\n])+'), " ")}"';
      }

      // Handle nested structures
      if (value is Map) {
        if (compact && _canFlattenMap(value)) {
          buffer.write('║${_indent(tabs)} $key: $value${!isLast ? ',' : ''}\n');
        } else {
          buffer.write('║${_indent(tabs)} $key: {\n');
          buffer.write(_formatPrettyMap(value, initialTab: tabs));
        }
      } else if (value is List) {
        if (compact && _canFlattenList(value)) {
          buffer.write('║${_indent(tabs)} $key: ${value.toString()}\n');
        } else {
          buffer.write('║${_indent(tabs)} $key: [\n');
          buffer.write(_formatList(value, tabs: tabs));
          buffer.write('║${_indent(tabs)} ]${isLast ? '' : ','}\n');
        }
      } else {
        // Handle individual values
        final msg = value.toString().replaceAll('\n', '');
        buffer.write('║${_indent(tabs)} $key: $msg${!isLast ? ',' : ''}\n');
      }
    }

    buffer.write('║$initialIndent}${isListItem && !isLast ? ',' : ''}\n');
    return buffer.toString();
  }

  String _formatList(List list, {int tabs = kInitialTab}) {
    final buffer = StringBuffer();
    for (var i = 0; i < list.length; i++) {
      final element = list[i];
      final isLast = i == list.length - 1;
      if (element is Map) {
        if (compact && _canFlattenMap(element)) {
          buffer.write('║${_indent(tabs)}  $element${!isLast ? ',' : ''}\n');
        } else {
          buffer.write(_formatPrettyMap(
            element,
            initialTab: tabs + 1,
            isListItem: true,
            isLast: isLast,
          ));
        }
      } else {
        buffer.write('║${_indent(tabs + 2)} $element${isLast ? '' : ','}\n');
      }
    }
    return buffer.toString();
  }

  String _formatUint8List(Uint8List list, {int tabs = kInitialTab}) {
    final buffer = StringBuffer();
    var chunks = [];
    for (var i = 0; i < list.length; i += chunkSize) {
      chunks.add(
        list.sublist(
            i, i + chunkSize > list.length ? list.length : i + chunkSize),
      );
    }
    for (var element in chunks) {
      buffer.write('║${_indent(tabs)} ${element.join(", ")}\n');
    }
    return buffer.toString();
  }

  void _printRequestHeader(String method, String url) {
    final headerBlock = StringBuffer();
    headerBlock.writeln('╔╣ Request ║ $method');
    headerBlock.writeln('║  $url');
    headerBlock.write('╚ ${_repeatChar('═', maxWidth)}');
    logPrint(headerBlock.toString());
  }

  void _printResponseHeader(
      String method, String url, int statusCode, int responseTime) {
    final headerBlock = StringBuffer();
    headerBlock.writeln(
        '╔╣ Response ║ $method ║ Status: $statusCode ║ Time: $responseTime ms');
    headerBlock.writeln('║  $url');
    headerBlock.write('╚ ${_repeatChar('═', maxWidth)}');
    logPrint(headerBlock.toString());
  }

  void _printMapAsTable(Map? map, {String? header}) {
    if (map == null || map.isEmpty) return;
    final tableBlock = StringBuffer();
    tableBlock.writeln('╔ $header');
    for (final entry in map.entries) {
      tableBlock.writeln('║  ${entry.key}: ${entry.value}');
    }
    tableBlock.write('╚ ${_repeatChar('═', maxWidth)}');
    logPrint(tableBlock.toString());
  }

  String _indent([int tabCount = kInitialTab]) => tabStep * tabCount;

  String _repeatChar(String char, int count) => char * count;

  bool _canFlattenMap(Map map) {
    return map.values
            .where((dynamic val) => val is Map || val is List)
            .isEmpty &&
        map.toString().length < maxWidth;
  }

  bool _canFlattenList(List list) {
    return list.length < 10 && list.toString().length < maxWidth;
  }
}

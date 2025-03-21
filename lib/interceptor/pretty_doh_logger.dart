import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:doh_api_client/utils/doh_response_model.dart';
import 'package:doh_api_client/interceptor/base_interceptor.dart';
import 'package:flutter/foundation.dart';
import 'dart:math' as math;

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
      logPrint('╔ Body');
      try {
        final dynamic data = json.decode(body);
        if (data is Map) {
          _printPrettyMap(data);
        } else if (data is List) {
          logPrint('║${_indent()}[');
          _printList(data);
          logPrint('║${_indent()}]');
        } else {
          _printBlock(body);
        }
      } catch (e) {
        _printBlock(body);
      }
      _printLine('╚');
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
      logPrint('╔ Body');
      final data = response.data;
      // ignore: unnecessary_type_check
      if (data is Map) {
        _printPrettyMap(data);
      } else if (data is Uint8List) {
        logPrint('║${_indent()}[');
        _printUint8List(data as Uint8List);
        logPrint('║${_indent()}]');
      } else if (data is List) {
        logPrint('║${_indent()}[');
        _printList(data as List);
        logPrint('║${_indent()}]');
      } else {
        _printBlock(data.toString());
      }
      _printLine('╚');
    }
  }

  @override
  void onError(String method, String url, dynamic error) {
    if (!enabled || !this.error) return;

    // Clean up timestamp
    _requestTimestamps.remove(url);

    _printBoxed(header: 'Error ║ $method', text: '$url\n$error');
  }

  void _printBoxed({String? header, String? text}) {
    logPrint('');
    logPrint('╔╣ $header');
    logPrint('║  $text');
    _printLine('╚');
  }

  void _printRequestHeader(String method, String url) {
    _printBoxed(header: 'Request ║ $method', text: url);
  }

  void _printResponseHeader(
      String method, String url, int statusCode, int responseTime) {
    _printBoxed(
      header:
          'Response ║ $method ║ Status: $statusCode ║ Time: $responseTime ms',
      text: url,
    );
  }

  void _printLine([String pre = '', String suf = '╝']) =>
      logPrint('$pre${'═' * maxWidth}$suf');

  void _printKV(String? key, Object? v) {
    final pre = '╟ $key: ';
    final msg = v.toString();

    if (pre.length + msg.length > maxWidth) {
      logPrint(pre);
      _printBlock(msg);
    } else {
      logPrint('$pre$msg');
    }
  }

  void _printBlock(String msg) {
    final lines = (msg.length / maxWidth).ceil();
    for (var i = 0; i < lines; ++i) {
      logPrint((i >= 0 ? '║ ' : '') +
          msg.substring(i * maxWidth,
              math.min<int>(i * maxWidth + maxWidth, msg.length)));
    }
  }

  String _indent([int tabCount = kInitialTab]) => tabStep * tabCount;

  void _printPrettyMap(
    Map data, {
    int initialTab = kInitialTab,
    bool isListItem = false,
    bool isLast = false,
  }) {
    var tabs = initialTab;
    final isRoot = tabs == kInitialTab;
    final initialIndent = _indent(tabs);
    tabs++;

    if (isRoot || isListItem) logPrint('║$initialIndent{');

    for (var index = 0; index < data.length; index++) {
      final isLast = index == data.length - 1;
      final key = '"${data.keys.elementAt(index)}"';
      dynamic value = data[data.keys.elementAt(index)];
      if (value is String) {
        value = '"${value.toString().replaceAll(RegExp(r'([\r\n])+'), " ")}"';
      }
      if (value is Map) {
        if (compact && _canFlattenMap(value)) {
          logPrint('║${_indent(tabs)} $key: $value${!isLast ? ',' : ''}');
        } else {
          logPrint('║${_indent(tabs)} $key: {');
          _printPrettyMap(value, initialTab: tabs);
        }
      } else if (value is List) {
        if (compact && _canFlattenList(value)) {
          logPrint('║${_indent(tabs)} $key: ${value.toString()}');
        } else {
          logPrint('║${_indent(tabs)} $key: [');
          _printList(value, tabs: tabs);
          logPrint('║${_indent(tabs)} ]${isLast ? '' : ','}');
        }
      } else {
        final msg = value.toString().replaceAll('\n', '');
        final indent = _indent(tabs);
        final linWidth = maxWidth - indent.length;
        if (msg.length + indent.length > linWidth) {
          final lines = (msg.length / linWidth).ceil();
          for (var i = 0; i < lines; ++i) {
            final multilineKey = i == 0 ? "$key:" : "";
            logPrint(
                '║${_indent(tabs)} $multilineKey ${msg.substring(i * linWidth, math.min<int>(i * linWidth + linWidth, msg.length))}');
          }
        } else {
          logPrint('║${_indent(tabs)} $key: $msg${!isLast ? ',' : ''}');
        }
      }
    }

    logPrint('║$initialIndent}${isListItem && !isLast ? ',' : ''}');
  }

  void _printList(List list, {int tabs = kInitialTab}) {
    for (var i = 0; i < list.length; i++) {
      final element = list[i];
      final isLast = i == list.length - 1;
      if (element is Map) {
        if (compact && _canFlattenMap(element)) {
          logPrint('║${_indent(tabs)}  $element${!isLast ? ',' : ''}');
        } else {
          _printPrettyMap(
            element,
            initialTab: tabs + 1,
            isListItem: true,
            isLast: isLast,
          );
        }
      } else {
        logPrint('║${_indent(tabs + 2)} $element${isLast ? '' : ','}');
      }
    }
  }

  void _printUint8List(Uint8List list, {int tabs = kInitialTab}) {
    var chunks = [];
    for (var i = 0; i < list.length; i += chunkSize) {
      chunks.add(
        list.sublist(
            i, i + chunkSize > list.length ? list.length : i + chunkSize),
      );
    }
    for (var element in chunks) {
      logPrint('║${_indent(tabs)} ${element.join(", ")}');
    }
  }

  bool _canFlattenMap(Map map) {
    return map.values
            .where((dynamic val) => val is Map || val is List)
            .isEmpty &&
        map.toString().length < maxWidth;
  }

  bool _canFlattenList(List list) {
    return list.length < 10 && list.toString().length < maxWidth;
  }

  void _printMapAsTable(Map? map, {String? header}) {
    if (map == null || map.isEmpty) return;
    logPrint('╔ $header ');
    for (final entry in map.entries) {
      _printKV(entry.key.toString(), entry.value);
    }
    _printLine('╚');
  }
}

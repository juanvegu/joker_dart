import 'dart:convert';
import 'dart:typed_data';

/// Response data that will be returned for a matched request
class JokerResponse {
  final int statusCode;
  final Map<String, String> headers;
  final dynamic body;
  final Duration? delay;

  /// Creates a response
  const JokerResponse({
    this.statusCode = 200,
    this.headers = const {},
    this.body,
    this.delay,
  });

  /// Creates a successful response with JSON body
  factory JokerResponse.json(
    Map<String, dynamic> json, {
    int statusCode = 200,
    Map<String, String> headers = const {},
    Duration? delay,
  }) {
    final jsonHeaders = {
      'content-type': 'application/json; charset=utf-8',
      ...headers,
    };
    return JokerResponse(
      statusCode: statusCode,
      headers: jsonHeaders,
      body: jsonEncode(json),
      delay: delay,
    );
  }

  /// Converts the body to bytes for HTTP response
  Uint8List get bytes {
    if (body is Uint8List) return body as Uint8List;
    if (body is String) return utf8.encode(body as String);
    if (body is List<int>) return Uint8List.fromList(body as List<int>);
    return Uint8List(0);
  }
}

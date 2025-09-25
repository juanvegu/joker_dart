import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'expections/file_load_exception.dart';

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

  /// Creates a successful response with JSON body loaded from a file
  ///
  /// Example:
  /// ```dart
  /// // Load from assets or test data
  /// final response = await JokerResponse.jsonFile('test/fixtures/users.json');
  ///
  /// // With custom status and headers
  /// final response = await JokerResponse.jsonFile(
  ///   'assets/api/profile.json',
  ///   statusCode: 201,
  ///   headers: {'x-custom': 'header'},
  ///   delay: Duration(milliseconds: 500),
  /// );
  /// ```
  static Future<JokerResponse> jsonFile(
    String filePath, {
    int statusCode = 200,
    Map<String, String> headers = const {},
    Duration? delay,
  }) async {
    try {
      final file = File(filePath);
      final jsonString = await file.readAsString();
      final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;

      return JokerResponse.json(
        jsonData,
        statusCode: statusCode,
        headers: headers,
        delay: delay,
      );
    } catch (e) {
      throw JokerFileLoadException(
        'Failed to load JSON file: $filePath. Error: $e',
      );
    }
  }

  /// Creates a successful response with text body
  ///
  /// Example:
  /// ```dart
  /// final response = JokerResponse.text('Hello, World!');
  /// ```
  factory JokerResponse.text(
    String text, {
    int statusCode = 200,
    Map<String, String> headers = const {},
    Duration? delay,
  }) {
    final textHeaders = {
      'content-type': 'text/plain; charset=utf-8',
      ...headers,
    };
    return JokerResponse(
      statusCode: statusCode,
      headers: textHeaders,
      body: text,
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

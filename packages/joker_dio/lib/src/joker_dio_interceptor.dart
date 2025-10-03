import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:joker/joker.dart';

/// A Dio interceptor that intercepts requests and returns stubbed responses
/// when Joker is active and has matching stubs.
///
/// This interceptor works on all platforms including web.
///
/// Usage:
/// ```dart
/// Joker.start();
/// Joker.stubJson(
///   host: 'api.example.com',
///   path: '/users',
///   data: {'users': []},
/// );
///
/// final dio = Dio();
/// dio.interceptors.add(JokerDioInterceptor());
/// final response = await dio.get('https://api.example.com/users');
/// ```
class JokerDioInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Check if Joker is active
    if (!Joker.isActive) {
      // Continue with normal request
      handler.next(options);
      return;
    }

    // Try to find a matching stub
    final stub = Joker.findStubForRequest(
      method: options.method,
      uri: options.uri,
    );

    if (stub == null) {
      // No stub found, make real request
      handler.next(options);
      return;
    }

    // Get the stubbed response
    final jokerResponse = Joker.getResponseForStub(
      stub,
      method: options.method,
      uri: options.uri,
    );

    if (jokerResponse == null) {
      // Shouldn't happen, but fallback to real request
      handler.next(options);
      return;
    }

    // Apply delay if specified
    if (jokerResponse.delay != null) {
      Future.delayed(jokerResponse.delay!).then((_) {
        _resolveWithStub(jokerResponse, options, handler);
      });
    } else {
      _resolveWithStub(jokerResponse, options, handler);
    }
  }

  void _resolveWithStub(
    JokerResponse jokerResponse,
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    // Convert JokerResponse to Dio Response
    final dioResponse = Response(
      requestOptions: options,
      statusCode: jokerResponse.statusCode,
      headers: Headers.fromMap(
        jokerResponse.headers.map((key, value) => MapEntry(key, [value])),
      ),
      data: _parseBody(jokerResponse.body, jokerResponse.headers),
    );

    handler.resolve(dioResponse);
  }

  /// Parses the response body based on content type
  dynamic _parseBody(String body, Map<String, String> headers) {
    final contentType = headers['content-type'] ?? '';

    if (contentType.contains('application/json')) {
      try {
        return jsonDecode(body);
      } catch (e) {
        return body;
      }
    }

    return body;
  }
}

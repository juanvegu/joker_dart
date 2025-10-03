import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:joker/joker.dart';

/// Internal HTTP client that intercepts requests and returns stubbed responses
/// when Joker is active and has matching stubs.
///
/// **Note**: Don't instantiate this class directly. Use `createHttpClient()`
/// instead, which is the public API and recommended way to create HTTP clients
/// that work with Joker.
///
/// This client wraps an inner HTTP client and checks for Joker stubs before
/// making real network requests. If a stub matches, it returns the stubbed
/// response. Otherwise, it forwards the request to the inner client.
class JokerHttpClient extends http.BaseClient {
  final http.Client _inner;

  /// Creates a new JokerHttpClient.
  ///
  /// [innerClient] is an optional custom HTTP client to use for non-stubbed
  /// requests. This is useful for advanced scenarios where you need custom
  /// HTTP configuration (e.g., custom certificates, proxy settings, timeouts).
  ///
  /// **Most users don't need to provide this parameter.**
  ///
  /// If not provided, a standard `http.Client()` will be created and used
  /// for any requests that don't match Joker stubs.
  ///
  /// **Example with custom client**:
  /// ```dart
  /// // Advanced: Custom client with specific configuration
  /// final customClient = http.Client(); // Configure as needed
  /// final jokerClient = createHttpClient(innerClient: customClient);
  /// ```
  JokerHttpClient({http.Client? innerClient})
    : _inner = innerClient ?? http.Client();

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    // Check if Joker is active
    if (!Joker.isActive) {
      return _inner.send(request);
    }

    // Try to find a matching stub
    final stub = Joker.findStubForRequest(
      method: request.method,
      uri: request.url,
    );

    if (stub == null) {
      // No stub found, make real request
      return _inner.send(request);
    }

    // Get the stubbed response
    final jokerResponse = Joker.getResponseForStub(
      stub,
      method: request.method,
      uri: request.url,
    );

    if (jokerResponse == null) {
      // Shouldn't happen, but fallback to real request
      return _inner.send(request);
    }

    // Apply delay if specified
    if (jokerResponse.delay != null) {
      await Future.delayed(jokerResponse.delay!);
    }

    // Convert JokerResponse to http.StreamedResponse
    final bodyBytes = utf8.encode(jokerResponse.body);
    return http.StreamedResponse(
      Stream.value(bodyBytes),
      jokerResponse.statusCode,
      headers: jokerResponse.headers,
      request: request,
      contentLength: bodyBytes.length,
    );
  }

  @override
  void close() {
    _inner.close();
    super.close();
  }
}

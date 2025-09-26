import 'dart:io';
import 'http_client_request.dart';

/// Custom HttpClient that intercepts all requests for stubbing
class JokerHttpClient implements HttpClient {
  /// Creates a Joker HTTP client
  JokerHttpClient();

  @override
  Future<HttpClientRequest> open(
    String method,
    String host,
    int port,
    String path,
  ) {
    final uri = Uri(scheme: 'http', host: host, port: port, path: path);
    return Future.value(JokerHttpClientRequest(method, uri));
  }

  @override
  Future<HttpClientRequest> openUrl(String method, Uri url) {
    return Future.value(JokerHttpClientRequest(method, url));
  }

  @override
  Future<HttpClientRequest> delete(String host, int port, String path) {
    return open('DELETE', host, port, path);
  }

  @override
  Future<HttpClientRequest> deleteUrl(Uri url) {
    return openUrl('DELETE', url);
  }

  @override
  Future<HttpClientRequest> get(String host, int port, String path) {
    return open('GET', host, port, path);
  }

  @override
  Future<HttpClientRequest> getUrl(Uri url) {
    return openUrl('GET', url);
  }

  @override
  Future<HttpClientRequest> head(String host, int port, String path) {
    return open('HEAD', host, port, path);
  }

  @override
  Future<HttpClientRequest> headUrl(Uri url) {
    return openUrl('HEAD', url);
  }

  @override
  Future<HttpClientRequest> patch(String host, int port, String path) {
    return open('PATCH', host, port, path);
  }

  @override
  Future<HttpClientRequest> patchUrl(Uri url) {
    return openUrl('PATCH', url);
  }

  @override
  Future<HttpClientRequest> post(String host, int port, String path) {
    return open('POST', host, port, path);
  }

  @override
  Future<HttpClientRequest> postUrl(Uri url) {
    return openUrl('POST', url);
  }

  @override
  Future<HttpClientRequest> put(String host, int port, String path) {
    return open('PUT', host, port, path);
  }

  @override
  Future<HttpClientRequest> putUrl(Uri url) {
    return openUrl('PUT', url);
  }

  @override
  void close({bool force = false}) {
    // Nothing to close in test mode
  }

  // Use noSuchMethod for all other unimplemented methods
  @override
  dynamic noSuchMethod(Invocation invocation) {
    throw UnsupportedError(
      'Joker intercepts all requests - operation not supported in test mode',
    );
  }
}

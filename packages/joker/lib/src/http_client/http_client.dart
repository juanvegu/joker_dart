import 'dart:io';
import 'http_client_request.dart';

/// Custom HttpClient that intercepts all requests for stubbing
class JokerHttpClient implements HttpClient {
  Duration _idleTimeout = const Duration(seconds: 15);
  Duration _connectionTimeout = const Duration(seconds: 60);
  int _maxConnectionsPerHost = 6;
  bool _autoUncompress = true;
  String? _userAgent;

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

  // Common HttpClient properties that HTTP libraries like Dio need
  @override
  Duration get idleTimeout => _idleTimeout;

  @override
  set idleTimeout(Duration timeout) {
    _idleTimeout = timeout;
  }

  @override
  Duration? get connectionTimeout => _connectionTimeout;

  @override
  set connectionTimeout(Duration? timeout) {
    _connectionTimeout = timeout ?? const Duration(seconds: 60);
  }

  @override
  int? get maxConnectionsPerHost => _maxConnectionsPerHost;

  @override
  set maxConnectionsPerHost(int? count) {
    _maxConnectionsPerHost = count ?? 6;
  }

  @override
  bool get autoUncompress => _autoUncompress;

  @override
  set autoUncompress(bool enabled) {
    _autoUncompress = enabled;
  }

  @override
  String? get userAgent => _userAgent;

  @override
  set userAgent(String? agent) {
    _userAgent = agent;
  }

  // Use noSuchMethod for all other unimplemented methods
  @override
  dynamic noSuchMethod(Invocation invocation) {
    throw UnsupportedError(
      'Joker intercepts all requests - operation not supported in test mode',
    );
  }
}

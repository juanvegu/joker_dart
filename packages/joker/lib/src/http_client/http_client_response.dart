import 'dart:async';
import 'dart:io';
import '../joker_response.dart';
import 'http_headers.dart';

/// Custom HttpClientResponse that returns stubbed data
class JokerHttpClientResponse implements HttpClientResponse {
  final JokerResponse _jokerResponse;

  JokerHttpClientResponse(this._jokerResponse);

  @override
  int get statusCode => _jokerResponse.statusCode;

  @override
  String get reasonPhrase {
    // Standard HTTP reason phrases
    switch (statusCode) {
      case 200:
        return 'OK';
      case 201:
        return 'Created';
      case 204:
        return 'No Content';
      case 400:
        return 'Bad Request';
      case 401:
        return 'Unauthorized';
      case 403:
        return 'Forbidden';
      case 404:
        return 'Not Found';
      case 500:
        return 'Internal Server Error';
      default:
        return 'Unknown';
    }
  }

  @override
  HttpHeaders get headers => JokerHttpHeaders(
    _jokerResponse.headers.map(
      (key, value) => MapEntry(key.toLowerCase(), [value]),
    ),
  );

  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int> event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    final bytes = _jokerResponse.bytes
        .toList(); // Convert Uint8List to List<int>
    final stream = Stream.fromIterable([bytes]);
    return stream.listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }

  @override
  int get contentLength => _jokerResponse.bytes.length;

  @override
  bool get isRedirect {
    // HTTP redirect status codes are 3xx
    return statusCode >= 300 && statusCode < 400;
  }

  @override
  List<RedirectInfo> get redirects => <RedirectInfo>[];

  @override
  bool get persistentConnection => false;

  @override
  HttpConnectionInfo? get connectionInfo => null;

  @override
  X509Certificate? get certificate => null;

  @override
  Stream<S> transform<S>(StreamTransformer<List<int>, S> streamTransformer) {
    final bytes = _jokerResponse.bytes
        .toList(); // Convert Uint8List to List<int>
    final stream = Stream.fromIterable([bytes]);
    return stream.transform(streamTransformer);
  }

  @override
  Future<String> join([String separator = ""]) async {
    final bytes = _jokerResponse.bytes;
    return String.fromCharCodes(bytes);
  }

  // Use noSuchMethod for all other unimplemented methods
  @override
  dynamic noSuchMethod(Invocation invocation) {
    // Most getters can return null in test mode
    if (invocation.isGetter) return null;

    // Most setters can do nothing in test mode
    if (invocation.isSetter) return null;

    throw UnsupportedError(
      '${invocation.memberName} not supported in test mode',
    );
  }
}

import 'dart:io';
import 'dart:typed_data';
import '../expections/no_stub_found_exception.dart';
import '../joker_base.dart';
import 'http_client_response.dart';
import 'http_headers.dart';

class JokerHttpClientRequest implements HttpClientRequest {
  final String _method;
  final Uri _uri;
  final Map<String, List<String>> _headers = {};
  final List<int> _body = [];

  JokerHttpClientRequest(this._method, this._uri);

  @override
  Future<HttpClientResponse> close() async {
    // Use this request for matching since it implements HttpClientRequest
    final stub = Joker.findStub(this);

    if (stub == null) {
      throw JokerNoStubFoundException('No stub found for $method $uri');
    }

    final response = stub.responseProvider(this);
    
    // Apply delay if specified
    if (response.delay != null) {
      await Future.delayed(response.delay!);
    }
    
    return JokerHttpClientResponse(response);
  }

  @override
  void add(List<int> data) {
    _body.addAll(data);
  }

  @override
  Future addStream(Stream<List<int>> stream) async {
    await for (final data in stream) {
      add(data);
    }
  }

  @override
  Future<HttpClientResponse> get done => close();

  @override
  Future flush() async {
    // Nothing to flush in test mode
  }

  @override
  void write(Object? object) {
    if (object != null) {
      add(object.toString().codeUnits);
    }
  }

  @override
  void writeAll(Iterable objects, [String separator = ""]) {
    write(objects.join(separator));
  }

  @override
  void writeCharCode(int charCode) {
    add([charCode]);
  }

  @override
  void writeln([Object? object = ""]) {
    write(object);
    write('\n');
  }

  // Request properties
  @override
  String get method => _method;

  @override
  Uri get uri => _uri;

  @override
  HttpHeaders get headers => JokerHttpHeaders(_headers);

  /// Get the request body as bytes (used by matchers)
  Uint8List get bodyBytes => Uint8List.fromList(_body);

  // Use noSuchMethod for all other unimplemented methods
  @override
  dynamic noSuchMethod(Invocation invocation) {
    return null; // Most getters/setters can return null/do nothing in test mode
  }
}

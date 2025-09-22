import 'dart:io';

class JokerHttpClientRequest implements HttpClientRequest {
  final String _method;
  final Uri _uri;

  JokerHttpClientRequest(this._method, this._uri);

  // Request properties
  @override
  String get method => _method;

  @override
  Uri get uri => _uri;

  // Use noSuchMethod for all other unimplemented methods
  @override
  dynamic noSuchMethod(Invocation invocation) {
    return null; // Most getters/setters can return null/do nothing in test mode
  }
}

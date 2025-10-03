// Native implementation using HttpOverrides
import 'dart:io';
import 'http_client/http_overrides.dart';
import 'joker_request.dart';
import 'joker_stub.dart';

/// Native implementation of Joker using HttpOverrides
class JokerPlatform {
  static final List<JokerStub> _stubs = [];
  static HttpOverrides? _previousOverrides;
  static bool _isActive = false;

  /// Returns a list of all currently registered stubs
  static List<JokerStub> get stubs => List.unmodifiable(_stubs);

  /// Returns true if Joker is currently active and intercepting requests
  static bool get isActive => _isActive;

  /// Starts intercepting HTTP requests
  static void start() {
    if (_isActive) return;

    _previousOverrides = HttpOverrides.current;
    HttpOverrides.global = JokerHttpOverrides();
    _isActive = true;
  }

  /// Stops intercepting HTTP requests and clears all stubs
  static void stop() {
    if (!_isActive) return;

    HttpOverrides.global = _previousOverrides;
    _stubs.clear();
    _isActive = false;
  }

  /// Adds a stub for HTTP request interception
  static JokerStub addStub(JokerStub stub) {
    _stubs.add(stub);
    return stub;
  }

  /// Removes a specific stub
  static bool removeStub(JokerStub stub) {
    return _stubs.remove(stub);
  }

  /// Removes all stubs with the given name
  static int removeStubsByName(String name) {
    final toRemove = _stubs.where((stub) => stub.name == name).toList();
    for (final stub in toRemove) {
      _stubs.remove(stub);
    }
    return toRemove.length;
  }

  /// Clears all registered stubs
  static void clearStubs() {
    _stubs.clear();
  }

  /// Finds a stub that matches the given request
  static JokerStub? findStub(HttpClientRequest request) {
    // Convert HttpClientRequest to JokerRequest for matching
    final jokerRequest = _HttpClientRequestAdapter(request);

    for (int i = 0; i < _stubs.length; i++) {
      final stub = _stubs[i];
      if (stub.matcher.matches(jokerRequest)) {
        if (stub.removeAfterUse) {
          _stubs.removeAt(i);
        }
        return stub;
      }
    }
    return null;
  }
}

/// Adapter to convert HttpClientRequest to JokerRequest
class _HttpClientRequestAdapter implements JokerRequest {
  final HttpClientRequest _request;

  _HttpClientRequestAdapter(this._request);

  @override
  String get method => _request.method;

  @override
  Uri get uri => _request.uri;
}

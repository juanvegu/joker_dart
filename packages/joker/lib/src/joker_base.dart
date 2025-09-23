import 'dart:io';
import 'http_client/http_overrides.dart';
import 'joker_response.dart';
import 'joker_stub.dart';
import 'matchers/url_matcher.dart';

class Joker {
  static final List<JokerStub> _stubs = [];
  static HttpOverrides? _previousOverrides;
  static bool _isActive = false;

  /// Starts intercepting HTTP requests
  ///
  /// This must be called before making any HTTP requests that you want to stub.
  /// It installs a custom HttpOverrides that will check registered stubs
  /// before making actual network requests.
  static void start() {
    if (_isActive) return;

    _previousOverrides = HttpOverrides.current;
    HttpOverrides.global = JokerHttpOverrides();
    _isActive = true;
  }

  /// Stops intercepting HTTP requests and clears all stubs
  ///
  /// This restores the original HttpOverrides and removes all registered stubs.
  static void stop() {
    if (!_isActive) return;

    HttpOverrides.global = _previousOverrides;
    _stubs.clear();
    _isActive = false;
  }

  /// Registers a new stub for HTTP request interception
  ///
  /// The [stub] will be checked against incoming requests in the order they
  /// were added. The first matching stub will be used to generate the response.
  ///
  /// Returns the added stub for potential later removal.
  static JokerStub addStub(JokerStub stub) {
    _stubs.add(stub);
    return stub;
  }

  /// Creates and registers a stub that matches specific URL patterns
  ///
  /// Example:
  /// ```dart
  /// Joker.stubUrl(
  ///   host: 'api.example.com',
  ///   path: '/users',
  ///   method: 'GET',
  ///   response: JokerResponse.json({'users': []}),
  /// );
  /// ```
  static JokerStub stubUrl({
    String? host,
    String? path,
    String? method,
    required JokerResponse response,
    String? name,
    bool removeAfterUse = false,
  }) {
    final matcher = UrlMatcher(host: host, path: path, method: method);
    final stub = JokerStub.create(
      matcher: matcher,
      response: response,
      name: name,
      removeAfterUse: removeAfterUse,
    );
    return addStub(stub);
  }

  /// Removes a specific stub from the registered list
  ///
  /// Returns true if the stub was found and removed, false otherwise.
  static bool removeStub(JokerStub stub) {
    return _stubs.remove(stub);
  }

  /// Removes all stubs with the given name
  ///
  /// Returns the number of stubs that were removed.
  static int removeStubsByName(String name) {
    final toRemove = _stubs.where((stub) => stub.name == name).toList();
    for (final stub in toRemove) {
      _stubs.remove(stub);
    }
    return toRemove.length;
  }

  /// Removes all registered stubs
  static void clearStubs() {
    _stubs.clear();
  }
}

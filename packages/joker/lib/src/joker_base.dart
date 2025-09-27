import 'dart:convert';
import 'dart:io';
import 'http_client/http_overrides.dart';
import 'joker_response.dart';
import 'joker_stub.dart';
import 'matchers/url_matcher.dart';

class Joker {
  static final List<JokerStub> _stubs = [];
  static HttpOverrides? _previousOverrides;
  static bool _isActive = false;

  /// Returns a list of all currently registered stubs
  ///
  /// The returned list is a copy, so modifying it won't affect the internal state.
  static List<JokerStub> get stubs => List.unmodifiable(_stubs);

  /// Returns true if Joker is currently active and intercepting requests
  static bool get isActive => _isActive;

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

  /// Internal method to register a new stub for HTTP request interception
  ///
  /// The [stub] will be checked against incoming requests in the order they
  /// were added. The first matching stub will be used to generate the response.
  ///
  /// Returns the added stub for potential later removal.
  static JokerStub _addStub(JokerStub stub) {
    _stubs.add(stub);
    return stub;
  }

  /// Internal helper method to create and register URL-based stubs
  static JokerStub _stubUrl({
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
    return _addStub(stub);
  }

  /// Convenience method for stubbing JSON responses
  ///
  /// Example:
  /// ```dart
  /// Joker.stubJson(
  ///   host: 'api.example.com',
  ///   path: '/users',
  ///   data: {'users': []},
  /// );
  /// ```
  static JokerStub stubJson({
    String? host,
    String? path,
    String? method,
    required Map<String, dynamic> data,
    int statusCode = 200,
    Map<String, String> headers = const {},
    Duration? delay,
    String? name,
    bool removeAfterUse = false,
  }) {
    final response = JokerResponse.json(
      data,
      statusCode: statusCode,
      headers: headers,
      delay: delay,
    );
    return _stubUrl(
      host: host,
      path: path,
      method: method,
      response: response,
      name: name,
      removeAfterUse: removeAfterUse,
    );
  }

  /// Convenience method for stubbing JSON array responses
  ///
  /// This method handles the common case where REST APIs return arrays
  /// at the root level (e.g., `[{...}, {...}]`) instead of wrapped objects.
  ///
  /// Example:
  /// ```dart
  /// Joker.stubJsonArray(
  ///   host: 'api.example.com',
  ///   path: '/posts',
  ///   data: [
  ///     {'id': 1, 'title': 'Post 1'},
  ///     {'id': 2, 'title': 'Post 2'},
  ///   ],
  /// );
  /// ```
  static JokerStub stubJsonArray({
    String? host,
    String? path,
    String? method,
    required List<Map<String, dynamic>> data,
    int statusCode = 200,
    Map<String, String> headers = const {},
    Duration? delay,
    String? name,
    bool removeAfterUse = false,
  }) {
    final jsonHeaders = {
      'content-type': 'application/json; charset=utf-8',
      ...headers,
    };
    final response = JokerResponse(
      statusCode: statusCode,
      headers: jsonHeaders,
      body: jsonEncode(data),
      delay: delay,
    );
    return _stubUrl(
      host: host,
      path: path,
      method: method,
      response: response,
      name: name,
      removeAfterUse: removeAfterUse,
    );
  }

  /// Convenience method for stubbing text responses
  ///
  /// Example:
  /// ```dart
  /// Joker.stubText(
  ///   host: 'api.example.com',
  ///   path: '/health',
  ///   text: 'OK',
  /// );
  /// ```
  static JokerStub stubText({
    String? host,
    String? path,
    String? method,
    required String text,
    int statusCode = 200,
    Map<String, String> headers = const {},
    Duration? delay,
    String? name,
    bool removeAfterUse = false,
  }) {
    final response = JokerResponse.text(
      text,
      statusCode: statusCode,
      headers: headers,
      delay: delay,
    );
    return _stubUrl(
      host: host,
      path: path,
      method: method,
      response: response,
      name: name,
      removeAfterUse: removeAfterUse,
    );
  }

  /// Creates a stub for JSON response loaded from a file (asynchronous)
  ///
  /// Example:
  /// ```dart
  /// await Joker.stubJsonFile(
  ///   host: 'api.example.com',
  ///   path: '/users',
  ///   filePath: 'test/fixtures/users.json',
  /// );
  /// ```
  static Future<JokerStub> stubJsonFile({
    String? host,
    String? path,
    String? method,
    required String filePath,
    int statusCode = 200,
    Map<String, String> headers = const {},
    Duration? delay,
    String? name,
    bool removeAfterUse = false,
  }) async {
    final response = await JokerResponse.jsonFile(
      filePath,
      statusCode: statusCode,
      headers: headers,
      delay: delay,
    );
    return _stubUrl(
      host: host,
      path: path,
      method: method,
      response: response,
      name: name,
      removeAfterUse: removeAfterUse,
    );
  }

  /// Finds a stub that matches the given request
  ///
  /// Returns the first matching stub, or null if no stub matches.
  /// If the stub has removeAfterUse=true, it will be removed from the stubs list.
  static JokerStub? findStub(HttpClientRequest request) {
    for (int i = 0; i < _stubs.length; i++) {
      final stub = _stubs[i];
      if (stub.matcher.matches(request)) {
        if (stub.removeAfterUse) {
          _stubs.removeAt(i);
        }
        return stub;
      }
    }
    return null;
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

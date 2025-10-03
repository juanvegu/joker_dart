import 'dart:convert';
import 'joker_request.dart';
import 'joker_response.dart';
import 'joker_stub.dart';
import 'matchers/url_matcher.dart';

// Conditional imports for platform-specific implementations
import 'joker_platform_stub.dart'
    if (dart.library.io) 'joker_platform_native.dart'
    if (dart.library.html) 'joker_platform_web.dart';

class Joker {
  /// Returns a list of all currently registered stubs
  ///
  /// The returned list is a copy, so modifying it won't affect the internal state.
  static List<JokerStub> get stubs => JokerPlatform.stubs;

  /// Returns true if Joker is currently active and intercepting requests
  static bool get isActive => JokerPlatform.isActive;

  /// Starts intercepting HTTP requests
  ///
  /// This must be called before making any HTTP requests that you want to stub.
  ///
  /// On native platforms (mobile, desktop, server), it installs a custom
  /// HttpOverrides that will check registered stubs before making actual
  /// network requests.
  ///
  /// On web, it sets Joker as active and requires HTTP clients to be configured
  /// with Joker's interception logic (see joker_http and joker_dio packages).
  static void start() {
    JokerPlatform.start();
  }

  /// Stops intercepting HTTP requests and clears all stubs
  ///
  /// This restores the original state and removes all registered stubs.
  static void stop() {
    JokerPlatform.stop();
  }

  /// Creates an HTTP client that works with Joker stubs.
  ///
  /// **For web platform only** - On native platforms (mobile, desktop, server),
  /// you can use the standard `http.Client()` directly as Joker uses HttpOverrides
  /// to intercept all requests automatically.
  ///
  /// On web, use this factory method to create clients that will respect Joker stubs:
  ///
  /// ```dart
  /// // In your service/repository layer with dependency injection
  /// class ApiService {
  ///   final http.Client client;
  ///
  ///   ApiService(this.client);
  ///
  ///   Future<User> getUser(int id) async {
  ///     final response = await client.get(
  ///       Uri.parse('https://api.example.com/users/$id'),
  ///     );
  ///     return User.fromJson(jsonDecode(response.body));
  ///   }
  /// }
  ///
  /// // In main.dart or dependency injection setup
  /// void main() {
  ///   if (kDebugMode) {
  ///     Joker.start();
  ///     // Add your stubs here
  ///   }
  ///
  ///   // Inject the client
  ///   final httpClient = Joker.createHttpClient();
  ///   final apiService = ApiService(httpClient);
  ///
  ///   runApp(MyApp(apiService: apiService));
  /// }
  /// ```
  ///
  /// This method requires the `joker_http` package to be installed.
  /// Add it to your `pubspec.yaml`:
  /// ```yaml
  /// dependencies:
  ///   joker_http: ^0.0.1
  /// ```
  static dynamic createHttpClient() {
    throw UnimplementedError(
      'createHttpClient() requires the joker_http package.\n'
      'Add it to your pubspec.yaml:\n'
      'dependencies:\n'
      '  joker_http: ^0.0.1\n\n'
      'Then use: import \'package:joker_http/joker_http.dart\' as joker_http;\n'
      'And call: joker_http.createHttpClient()',
    );
  }

  /// Internal method to register a new stub for HTTP request interception
  ///
  /// The [stub] will be checked against incoming requests in the order they
  /// were added. The first matching stub will be used to generate the response.
  ///
  /// Returns the added stub for potential later removal.
  static JokerStub _addStub(JokerStub stub) {
    return JokerPlatform.addStub(stub);
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

  /// Removes a specific stub from the registered list
  ///
  /// Returns true if the stub was found and removed, false otherwise.
  static bool removeStub(JokerStub stub) {
    return JokerPlatform.removeStub(stub);
  }

  /// Removes all stubs with the given name
  ///
  /// Returns the number of stubs that were removed.
  static int removeStubsByName(String name) {
    return JokerPlatform.removeStubsByName(name);
  }

  /// Removes all registered stubs
  static void clearStubs() {
    JokerPlatform.clearStubs();
  }

  /// Finds a stub that matches the given request parameters
  ///
  /// This method is mainly used by HTTP client integrations (like joker_http
  /// and joker_dio) to check if a request should be stubbed.
  ///
  /// Returns the matching stub, or null if no stub matches.
  static JokerStub? findStubForRequest({
    required String method,
    required Uri uri,
  }) {
    // Create a mock request for matching
    final request = _JokerRequestImpl(method: method, uri: uri);

    for (int i = 0; i < stubs.length; i++) {
      final stub = stubs[i];
      if (stub.matcher.matches(request)) {
        if (stub.removeAfterUse) {
          removeStub(stub);
        }
        return stub;
      }
    }
    return null;
  }

  /// Gets the response for a matched stub
  ///
  /// This method is mainly used by HTTP client integrations to get the
  /// response to return for a matched stub.
  ///
  /// Returns the JokerResponse for the stub, or null if something goes wrong.
  static JokerResponse? getResponseForStub(
    JokerStub stub, {
    required String method,
    required Uri uri,
  }) {
    final request = _JokerRequestImpl(method: method, uri: uri);
    return stub.responseProvider(request);
  }
}

/// Internal implementation of JokerRequest for matching
class _JokerRequestImpl implements JokerRequest {
  @override
  final String method;

  @override
  final Uri uri;

  _JokerRequestImpl({required this.method, required this.uri});
}

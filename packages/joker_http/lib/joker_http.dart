library;

/// HTTP client integration for Joker
///
/// This package provides an HTTP client factory that works with Joker
/// to intercept and stub HTTP requests made with the `package:http` library.
///
/// Works on all platforms including web.
///
/// **Simple Usage** (Single Import):
/// ```dart
/// // Just import joker_http - it re-exports everything from joker
/// import 'package:joker_http/joker_http.dart';
/// import 'package:http/http.dart' as http;
///
/// // 1. Define your service with injected client
/// class ApiService {
///   final http.Client client;
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
/// // 2. Setup in main.dart
/// void main() {
///   if (kDebugMode) {
///     Joker.start(); // ← From joker (re-exported)
///     Joker.stubJson( // ← From joker (re-exported)
///       host: 'api.example.com',
///       path: '/users/1',
///       data: {'id': 1, 'name': 'Test User'},
///     );
///   }
///
///   // Create and inject the client
///   final httpClient = createHttpClient(); // ← From joker_http
///   final apiService = ApiService(httpClient);
///
///   runApp(MyApp(apiService: apiService));
/// }
/// ```

// Re-export everything from joker so users only need one import
export 'package:joker/joker.dart';

// Export the HTTP client factory
export 'src/create_http_client.dart' show createHttpClient;

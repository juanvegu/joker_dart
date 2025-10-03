import 'package:http/http.dart' as http;
import 'joker_http_client.dart';

/// Creates an HTTP client that works with Joker stubs.
///
/// **This is the recommended and primary way to use joker_http.**
///
/// The returned client will automatically check for Joker stubs when making
/// requests. If a stub matches, it returns the stubbed response. Otherwise,
/// it makes a real network request.
///
/// **Basic Usage** (Most Common):
///
/// ```dart
/// import 'package:joker_http/joker_http.dart';
///
/// void main() {
///   if (kDebugMode) {
///     Joker.start();
///     Joker.stubJson(
///       host: 'api.example.com',
///       path: '/users/1',
///       data: {'id': 1, 'name': 'Test User'},
///     );
///   }
///
///   // Create the client - that's it!
///   final httpClient = createHttpClient();
///
///   // Use it anywhere in your app
///   final apiService = ApiService(httpClient);
///   runApp(MyApp(apiService: apiService));
/// }
/// ```
///
/// **Usage with Dependency Injection** (Recommended for larger apps):
///
/// ```dart
/// import 'package:joker_http/joker_http.dart';
///
/// // 1. In your service/repository
/// class ApiService {
///   final http.Client client;
///
///   ApiService(this.client); // Injected dependency
///
///   Future<User> getUser(int id) async {
///     final response = await client.get(
///       Uri.parse('https://api.example.com/users/$id'),
///     );
///     return User.fromJson(jsonDecode(response.body));
///   }
/// }
///
/// // 2. In your DI setup (main.dart, get_it, provider, etc.)
/// void main() {
///   if (kDebugMode) {
///     Joker.start();
///     Joker.stubJson(
///       host: 'api.example.com',
///       path: '/users/1',
///       data: {'id': 1, 'name': 'Test User'},
///     );
///   }
///
///   // Create the client once
///   final httpClient = createHttpClient();
///
///   // Inject into services
///   final apiService = ApiService(httpClient);
///
///   runApp(MyApp(apiService: apiService));
/// }
/// ```
///
/// **With get_it**:
/// ```dart
/// final getIt = GetIt.instance;
///
/// void setupDependencies() {
///   if (kDebugMode) {
///     Joker.start();
///     // Setup stubs...
///   }
///
///   // Register the HTTP client
///   getIt.registerSingleton<http.Client>(createHttpClient());
///
///   // Register services that depend on it
///   getIt.registerSingleton<ApiService>(
///     ApiService(getIt<http.Client>()),
///   );
/// }
/// ```
///
/// **Advanced: Custom Inner Client** (Optional):
///
/// The [innerClient] parameter allows you to provide a custom HTTP client
/// that will be used for non-stubbed requests. This is useful for advanced
/// scenarios like custom SSL certificates, proxy configuration, or timeouts.
///
/// **Most users don't need this parameter - leave it null for default behavior.**
///
/// ```dart
/// // Advanced example with custom configuration
/// final customClient = http.Client(); // Configure with custom settings
/// final httpClient = createHttpClient(innerClient: customClient);
/// ```
///
/// **Platform Behavior**:
/// - **Native** (mobile, desktop, server): Works seamlessly. HttpOverrides
///   handles interception automatically, but using this client provides
///   consistency across platforms.
/// - **Web**: Required because HttpOverrides doesn't exist in browsers.
///   This client explicitly checks stubs before making fetch() calls.
///
/// Returns an `http.Client` instance that checks Joker stubs when active.
http.Client createHttpClient({http.Client? innerClient}) {
  return JokerHttpClient(innerClient: innerClient);
}

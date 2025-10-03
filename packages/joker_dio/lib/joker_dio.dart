library;

/// Dio integration for Joker
///
/// This package provides a Dio interceptor that works with Joker
/// to intercept and stub HTTP requests made with the Dio library.
///
/// Works on all platforms including web.
///
/// **Simple Usage** (Single Import):
/// ```dart
/// // Just import joker_dio - it re-exports everything from joker
/// import 'package:joker_dio/joker_dio.dart';
/// import 'package:dio/dio.dart';
///
/// // 1. Define your service with injected Dio
/// class ApiService {
///   final Dio dio;
///   ApiService(this.dio);
///
///   Future<User> getUser(int id) async {
///     final response = await dio.get('/users/$id');
///     return User.fromJson(response.data);
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
///   // Create Dio with interceptor
///   final dio = Dio(BaseOptions(baseUrl: 'https://api.example.com'));
///   dio.interceptors.add(JokerDioInterceptor()); // ← From joker_dio
///   
///   final apiService = ApiService(dio);
///   runApp(MyApp(apiService: apiService));
/// }
/// ```

// Re-export everything from joker so users only need one import
export 'package:joker/joker.dart';

// Export the Dio interceptor
export 'src/joker_dio_interceptor.dart';

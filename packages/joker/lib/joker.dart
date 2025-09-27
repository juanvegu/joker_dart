/// A powerful HTTP request stubbing and mocking library for Dart.
///
/// Joker allows you to intercept HTTP requests made by any Dart library
/// that uses the standard HttpClient and HttpOverrides classes.
/// This includes popular packages like dio and http.
///
/// Example usage:
/// ```dart
/// import 'package:joker/joker.dart';
///
/// // Start intercepting requests
/// Joker.start();
///
/// // Stub a JSON object response
/// Joker.stubJson(
///   host: 'api.example.com',
///   path: '/user/1',
///   data: {'id': 1, 'name': 'John'},
/// );
///
/// // Stub a JSON array response (common in REST APIs)
/// Joker.stubJsonArray(
///   host: 'api.example.com',
///   path: '/posts',
///   data: [
///     {'id': 1, 'title': 'Post 1'},
///     {'id': 2, 'title': 'Post 2'},
///   ],
/// );
///
/// // Make your HTTP requests - they will be intercepted
/// final userResponse = await http.get(Uri.parse('https://api.example.com/user/1'));
/// final postsResponse = await http.get(Uri.parse('https://api.example.com/posts'));
///
/// // Stop intercepting when done
/// Joker.stop();
/// ```

library;

export 'src/joker_base.dart';

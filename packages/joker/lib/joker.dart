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
/// // Stub a JSON response
/// Joker.stubJson(
///   host: 'api.example.com',
///   path: '/users',
///   data: {'users': []},
/// );
///
/// // Make your HTTP request - it will be intercepted
/// final response = await http.get(Uri.parse('https://api.example.com/users'));
///
/// // Stop intercepting when done
/// Joker.stop();
/// ```

library;

export 'src/joker_base.dart';

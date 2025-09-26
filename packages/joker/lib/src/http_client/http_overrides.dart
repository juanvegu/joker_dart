import 'dart:io';
import 'http_client.dart';

/// Custom HttpOverrides that creates Joker HTTP clients
class JokerHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return JokerHttpClient();
  }
}

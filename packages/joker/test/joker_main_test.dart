import 'dart:io';
import 'package:test/test.dart';
import 'package:joker/joker.dart';

/// Main test file - serves as an entry point for comprehensive Joker testing.
/// For specific functionality, see the organized test files:
/// - test/unit/basic_functionality_test.dart
/// - test/unit/stub_management_test.dart
/// - test/unit/http_methods_test.dart
/// - test/unit/error_handling_test.dart
/// - test/integration/integration_test.dart
void main() {
  group('Joker HTTP Stubbing - Core Features', () {
    setUp(() {
      Joker.stop();
      Joker.clearStubs();
    });

    tearDown(() {
      Joker.stop();
      Joker.clearStubs();
    });

    test('should provide a working end-to-end example', () async {
      // This test demonstrates the main use case of Joker
      Joker.start();

      // Setup a simple stub
      Joker.stubJson(
        host: 'api.example.com',
        path: '/health',
        data: {'status': 'ok', 'version': '1.0.0'},
      );

      final client = HttpClient();
      try {
        final request = await client.getUrl(
          Uri.parse('https://api.example.com/health'),
        );
        final response = await request.close();
        final body = await response.transform(SystemEncoding().decoder).join();

        expect(response.statusCode, equals(200));
        expect(body, contains('"status":"ok"'));
        expect(body, contains('"version":"1.0.0"'));
      } finally {
        client.close();
      }
    });

    test('should demonstrate stub lifecycle management', () {
      Joker.start();

      // Create some stubs
      Joker.stubJson(
        host: 'api.test.com',
        path: '/users',
        name: 'users-stub',
        data: {'users': []},
      );
      Joker.stubJson(
        host: 'api.test.com',
        path: '/posts',
        name: 'posts-stub',
        data: {'posts': []},
      );

      // Remove specific stub
      final removed = Joker.removeStubsByName('users-stub');
      expect(removed, equals(1));

      // Clear all remaining stubs
      Joker.clearStubs();

      // These operations should complete without errors
      expect(Joker.stop, returnsNormally);
    });
  });
}

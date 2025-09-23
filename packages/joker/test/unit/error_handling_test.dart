import 'dart:io';
import 'package:test/test.dart';
import 'package:joker/joker.dart';

void main() {
  group('Error Handling', () {
    setUp(() {
      Joker.stop();
      Joker.clearStubs();
    });

    tearDown(() {
      Joker.stop();
      Joker.clearStubs();
    });

    test('should handle missing stubs gracefully', () async {
      Joker.start();
      // Don't register any stubs

      final client = HttpClient();
      try {
        final request = await client.getUrl(
          Uri.parse('https://api.test.com/missing'),
        );

        // Should throw exception when trying to close the request
        expect(() => request.close(), throwsException);
      } finally {
        client.close();
      }
    });

    test('should handle non-matching stubs', () async {
      Joker.start();

      // Register stubs that won't match
      Joker.stubJson(
        host: 'different.com',
        path: '/users',
        data: {'users': []},
      );

      final client = HttpClient();
      try {
        final request = await client.getUrl(
          Uri.parse('https://api.test.com/missing'),
        );

        expect(() => request.close(), throwsException);
      } finally {
        client.close();
      }
    });

    test('should handle requests to different hosts than stubbed', () async {
      Joker.start();

      // Stub one host
      Joker.stubJson(host: 'api.test.com', path: '/users', data: {'users': []});

      final client = HttpClient();
      try {
        // Request to different host
        final request = await client.getUrl(
          Uri.parse('https://different-api.test.com/users'),
        );

        expect(() => request.close(), throwsException);
      } finally {
        client.close();
      }
    });

    test('should handle requests to different paths than stubbed', () async {
      Joker.start();

      // Stub one path
      Joker.stubJson(host: 'api.test.com', path: '/users', data: {'users': []});

      final client = HttpClient();
      try {
        // Request to different path
        final request = await client.getUrl(
          Uri.parse('https://api.test.com/posts'),
        );

        expect(() => request.close(), throwsException);
      } finally {
        client.close();
      }
    });

    test(
      'should handle requests with different HTTP methods than stubbed',
      () async {
        Joker.start();

        // Stub GET method
        Joker.stubJson(
          host: 'api.test.com',
          path: '/users',
          method: 'GET',
          data: {'users': []},
        );

        final client = HttpClient();
        try {
          // Request with POST method
          final request = await client.postUrl(
            Uri.parse('https://api.test.com/users'),
          );

          expect(() => request.close(), throwsException);
        } finally {
          client.close();
        }
      },
    );

    group('Network Simulation', () {
      test('should simulate network errors with custom status codes', () async {
        Joker.start();

        // Simulate various HTTP error codes
        Joker.stubJson(
          host: 'api.test.com',
          path: '/unauthorized',
          statusCode: 401,
          data: {'error': 'Unauthorized'},
        );

        Joker.stubJson(
          host: 'api.test.com',
          path: '/forbidden',
          statusCode: 403,
          data: {'error': 'Forbidden'},
        );

        Joker.stubJson(
          host: 'api.test.com',
          path: '/not-found',
          statusCode: 404,
          data: {'error': 'Not Found'},
        );

        Joker.stubJson(
          host: 'api.test.com',
          path: '/server-error',
          statusCode: 500,
          data: {'error': 'Internal Server Error'},
        );

        final client = HttpClient();
        try {
          // Test 401
          final request401 = await client.getUrl(
            Uri.parse('https://api.test.com/unauthorized'),
          );
          final response401 = await request401.close();
          expect(response401.statusCode, equals(401));

          // Test 403
          final request403 = await client.getUrl(
            Uri.parse('https://api.test.com/forbidden'),
          );
          final response403 = await request403.close();
          expect(response403.statusCode, equals(403));

          // Test 404
          final request404 = await client.getUrl(
            Uri.parse('https://api.test.com/not-found'),
          );
          final response404 = await request404.close();
          expect(response404.statusCode, equals(404));

          // Test 500
          final request500 = await client.getUrl(
            Uri.parse('https://api.test.com/server-error'),
          );
          final response500 = await request500.close();
          expect(response500.statusCode, equals(500));
        } finally {
          client.close();
        }
      });
    });
  });
}

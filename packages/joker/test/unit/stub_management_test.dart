import 'dart:io';
import 'package:test/test.dart';
import 'package:joker/joker.dart';

void main() {
  group('Stub Management', () {
    setUp(() {
      Joker.stop();
      Joker.clearStubs();
    });

    tearDown(() {
      Joker.stop();
      Joker.clearStubs();
    });

    group('Named Stubs', () {
      test('should create and remove stubs by name', () {
        Joker.start();

        // Create named stubs
        Joker.stubJson(
          host: 'api.test.com',
          path: '/endpoint1',
          name: 'stub1',
          data: {'data': 1},
        );

        Joker.stubJson(
          host: 'api.test.com',
          path: '/endpoint2',
          name: 'stub2',
          data: {'data': 2},
        );

        Joker.stubJson(
          host: 'api.test.com',
          path: '/endpoint3',
          name: 'stub1', // Same name as first
          data: {'data': 3},
        );

        // Remove stubs by name
        final removedCount = Joker.removeStubsByName('stub1');
        expect(
          removedCount,
          equals(2),
        ); // Should remove 2 stubs with name 'stub1'

        final removedCount2 = Joker.removeStubsByName('nonexistent');
        expect(removedCount2, equals(0)); // Should remove 0 stubs
      });
    });

    group('One-time Stubs', () {
      test(
        'should remove stub after first use when removeAfterUse is true',
        () async {
          Joker.start();

          // Create one-time stub
          Joker.stubJson(
            host: 'api.test.com',
            path: '/token',
            removeAfterUse: true,
            data: {'token': 'abc123'},
          );

          // Add fallback stub
          Joker.stubJson(
            host: 'api.test.com',
            path: '/token',
            statusCode: 401,
            data: {'error': 'No token available'},
          );

          final client = HttpClient();
          try {
            // First request should get the token
            final firstRequest = await client.getUrl(
              Uri.parse('https://api.test.com/token'),
            );
            final firstResponse = await firstRequest.close();
            final firstBody = await firstResponse
                .transform(SystemEncoding().decoder)
                .join();

            expect(firstResponse.statusCode, equals(200));
            expect(firstBody, contains('"token":"abc123"'));

            // Second request should get the fallback (401 error)
            final secondRequest = await client.getUrl(
              Uri.parse('https://api.test.com/token'),
            );
            final secondResponse = await secondRequest.close();
            final secondBody = await secondResponse
                .transform(SystemEncoding().decoder)
                .join();

            expect(secondResponse.statusCode, equals(401));
            expect(secondBody, contains('"error":"No token available"'));
          } finally {
            client.close();
          }
        },
      );
    });

    group('Multiple Endpoints', () {
      test('should handle multiple different endpoints', () async {
        Joker.start();

        // Stub multiple endpoints
        Joker.stubJson(
          host: 'api.test.com',
          path: '/users',
          data: {'users': []},
        );

        Joker.stubJson(
          host: 'api.test.com',
          path: '/posts',
          data: {'posts': []},
        );

        Joker.stubJson(
          host: 'different.test.com',
          path: '/config',
          data: {'env': 'test'},
        );

        final client = HttpClient();
        try {
          // Test first endpoint
          final usersRequest = await client.getUrl(
            Uri.parse('https://api.test.com/users'),
          );
          final usersResponse = await usersRequest.close();
          final usersBody = await usersResponse
              .transform(SystemEncoding().decoder)
              .join();
          expect(usersResponse.statusCode, equals(200));
          expect(usersBody, contains('"users":[]'));

          // Test second endpoint
          final postsRequest = await client.getUrl(
            Uri.parse('https://api.test.com/posts'),
          );
          final postsResponse = await postsRequest.close();
          final postsBody = await postsResponse
              .transform(SystemEncoding().decoder)
              .join();
          expect(postsResponse.statusCode, equals(200));
          expect(postsBody, contains('"posts":[]'));

          // Test different host
          final configRequest = await client.getUrl(
            Uri.parse('https://different.test.com/config'),
          );
          final configResponse = await configRequest.close();
          final configBody = await configResponse
              .transform(SystemEncoding().decoder)
              .join();
          expect(configResponse.statusCode, equals(200));
          expect(configBody, contains('"env":"test"'));
        } finally {
          client.close();
        }
      });
    });

    group('Custom Responses', () {
      test('should include custom headers in response', () async {
        Joker.start();

        Joker.stubJson(
          host: 'api.test.com',
          path: '/custom',
          data: {'message': 'Custom response'},
          headers: {'X-Custom-Header': 'Test-Value', 'X-API-Version': '2.0'},
        );

        final client = HttpClient();
        try {
          final request = await client.getUrl(
            Uri.parse('https://api.test.com/custom'),
          );
          final response = await request.close();

          // Check custom headers exist and have correct values
          // HTTP headers are case-insensitive, so we use lowercase keys
          expect(response.headers['x-custom-header'], contains('Test-Value'));
          expect(response.headers['x-api-version'], contains('2.0'));
          expect(
            response.headers.contentType?.primaryType,
            equals('application'),
          );
          expect(response.headers.contentType?.subType, equals('json'));
        } finally {
          client.close();
        }
      });

      test('should handle error status codes', () async {
        Joker.start();

        Joker.stubJson(
          host: 'api.test.com',
          path: '/error',
          statusCode: 404,
          data: {
            'error': 'Not Found',
            'code': 'RESOURCE_NOT_FOUND',
            'message': 'The requested resource was not found',
          },
        );

        final client = HttpClient();
        try {
          final request = await client.getUrl(
            Uri.parse('https://api.test.com/error'),
          );
          final response = await request.close();
          final body = await response
              .transform(SystemEncoding().decoder)
              .join();

          expect(response.statusCode, equals(404));
          expect(body, contains('"error":"Not Found"'));
          expect(body, contains('"code":"RESOURCE_NOT_FOUND"'));
        } finally {
          client.close();
        }
      });

      test('should handle delays in responses', () async {
        Joker.start();

        const delay = Duration(milliseconds: 100);
        Joker.stubJson(
          host: 'api.test.com',
          path: '/slow',
          data: {'message': 'Delayed response'},
          delay: delay,
        );

        final client = HttpClient();
        try {
          final stopwatch = Stopwatch()..start();
          final request = await client.getUrl(
            Uri.parse('https://api.test.com/slow'),
          );
          final response = await request.close();
          stopwatch.stop();

          expect(response.statusCode, equals(200));
          // Allow some tolerance for test execution timing
          expect(stopwatch.elapsedMilliseconds, greaterThan(90));
        } finally {
          client.close();
        }
      });
    });
  });
}

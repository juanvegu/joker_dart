import 'dart:io';
import 'package:test/test.dart';
import 'package:joker/joker.dart';

void main() {
  group('Basic Functionality', () {
    setUp(() {
      // Ensure clean state before each test
      Joker.stop();
      Joker.clearStubs();
    });

    tearDown(() {
      // Clean up after each test
      Joker.stop();
      Joker.clearStubs();
    });

    test('should start and stop intercepting requests', () {
      expect(Joker.start, returnsNormally);
      expect(Joker.stop, returnsNormally);

      // Should be safe to call multiple times
      Joker.start();
      Joker.start();
      expect(Joker.stop, returnsNormally);
    });

    test('should clear all stubs', () {
      Joker.start();

      // Add some stubs
      Joker.stubJson(host: 'test.com', path: '/test1', data: {'test': 1});
      Joker.stubJson(host: 'test.com', path: '/test2', data: {'test': 2});

      // Clear all stubs
      Joker.clearStubs();

      // This test verifies the method executes without error
      // In a real scenario, you'd verify no stubs are matched
      expect(Joker.clearStubs, returnsNormally);
    });

    test('should handle basic JSON stubbing', () async {
      Joker.start();

      final testData = {
        'id': 123,
        'name': 'Test User',
        'email': 'test@example.com',
      };

      Joker.stubJson(
        host: 'api.test.com',
        path: '/users/123',
        method: 'GET',
        data: testData,
      );

      final client = HttpClient();
      try {
        final request = await client.getUrl(
          Uri.parse('https://api.test.com/users/123'),
        );
        final response = await request.close();
        final body = await response.transform(SystemEncoding().decoder).join();

        expect(response.statusCode, equals(200));
        expect(
          response.headers.contentType?.primaryType,
          equals('application'),
        );
        expect(response.headers.contentType?.subType, equals('json'));
        expect(body, contains('"id":123'));
        expect(body, contains('"name":"Test User"'));
        expect(body, contains('"email":"test@example.com"'));
      } finally {
        client.close();
      }
    });

    test('should intercept requests with stubJsonArray', () async {
      Joker.start();

      final testData = [
        {'id': 1, 'name': 'Post 1', 'body': 'Content 1'},
        {'id': 2, 'name': 'Post 2', 'body': 'Content 2'},
      ];

      Joker.stubJsonArray(
        host: 'api.test.com',
        path: '/posts',
        method: 'GET',
        data: testData,
      );

      final client = HttpClient();
      try {
        final request = await client.getUrl(
          Uri.parse('https://api.test.com/posts'),
        );
        final response = await request.close();
        final body = await response.transform(SystemEncoding().decoder).join();

        expect(response.statusCode, equals(200));
        expect(
          response.headers.contentType?.primaryType,
          equals('application'),
        );
        expect(response.headers.contentType?.subType, equals('json'));

        // Should return an array
        expect(body, startsWith('['));
        expect(body, endsWith(']'));
        expect(body, contains('"id":1'));
        expect(body, contains('"name":"Post 1"'));
        expect(body, contains('"id":2'));
        expect(body, contains('"name":"Post 2"'));
      } finally {
        client.close();
      }
    });
  });
}

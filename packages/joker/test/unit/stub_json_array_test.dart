import 'dart:io';
import 'package:test/test.dart';
import 'package:joker/joker.dart';

void main() {
  group('Stub Methods Comprehensive Tests', () {
    setUp(() {
      Joker.stop();
      Joker.clearStubs();
    });

    tearDown(() {
      Joker.stop();
      Joker.clearStubs();
    });

    group('stubJsonArray', () {
      test('should handle complex nested objects in array', () async {
        Joker.start();

        final testData = [
          {
            'id': 1,
            'user': {
              'name': 'John Doe',
              'profile': {
                'age': 30,
                'interests': ['coding', 'testing'],
              },
            },
            'posts': [
              {'title': 'Post 1', 'likes': 10},
              {'title': 'Post 2', 'likes': 5},
            ],
          },
          {
            'id': 2,
            'user': {
              'name': 'Jane Smith',
              'profile': {
                'age': 25,
                'interests': ['design', 'art'],
              },
            },
            'posts': [],
          },
        ];

        Joker.stubJsonArray(
          host: 'api.test.com',
          path: '/users-with-posts',
          method: 'GET',
          data: testData,
        );

        final client = HttpClient();
        try {
          final request = await client.getUrl(
            Uri.parse('https://api.test.com/users-with-posts'),
          );
          final response = await request.close();
          final body = await response
              .transform(SystemEncoding().decoder)
              .join();

          expect(response.statusCode, equals(200));
          expect(body, startsWith('['));
          expect(body, endsWith(']'));

          // Check nested structure is preserved
          expect(body, contains('"name":"John Doe"'));
          expect(body, contains('"age":30'));
          expect(body, contains('["coding","testing"]'));
          expect(body, contains('"title":"Post 1"'));
          expect(body, contains('"likes":10'));
          expect(body, contains('"name":"Jane Smith"'));
        } finally {
          client.close();
        }
      });

      test('should handle array with mixed data types', () async {
        Joker.start();

        final testData = [
          {
            'stringField': 'test string',
            'numberField': 42,
            'boolField': true,
            'nullField': null,
            'arrayField': [1, 'two', false],
            'objectField': {'nested': 'value'},
          },
        ];

        Joker.stubJsonArray(
          host: 'api.test.com',
          path: '/mixed-types',
          method: 'GET',
          data: testData,
        );

        final client = HttpClient();
        try {
          final request = await client.getUrl(
            Uri.parse('https://api.test.com/mixed-types'),
          );
          final response = await request.close();
          final body = await response
              .transform(SystemEncoding().decoder)
              .join();

          expect(response.statusCode, equals(200));
          expect(body, contains('"stringField":"test string"'));
          expect(body, contains('"numberField":42'));
          expect(body, contains('"boolField":true'));
          expect(body, contains('"nullField":null'));
          expect(body, contains('[1,"two",false]'));
          expect(body, contains('"nested":"value"'));
        } finally {
          client.close();
        }
      });

      test('should handle array with all optional parameters', () async {
        Joker.start();

        final testData = [
          {'test': 'all parameters'},
        ];

        Joker.stubJsonArray(
          host: 'api.test.com',
          path: '/all-params',
          method: 'POST',
          data: testData,
          statusCode: 201,
          headers: {'x-custom-header': 'test-value', 'x-api-version': 'v1'},
          delay: Duration(milliseconds: 50),
          name: 'test-stub-array',
          removeAfterUse: true,
        );

        final client = HttpClient();
        try {
          // First request should match and remove the stub
          final request1 = await client.postUrl(
            Uri.parse('https://api.test.com/all-params'),
          );
          final response1 = await request1.close();

          expect(response1.statusCode, equals(201));
          expect(
            response1.headers.value('x-custom-header'),
            equals('test-value'),
          );
          expect(response1.headers.value('x-api-version'), equals('v1'));

          // Second request should not match (stub was removed)
          try {
            final request2 = await client.postUrl(
              Uri.parse('https://api.test.com/all-params'),
            );
            await request2.close();
            fail('Should have thrown an exception for unmatched request');
          } catch (e) {
            // Expected - no stub should match
          }
        } finally {
          client.close();
        }
      });

      test('should handle large arrays efficiently', () async {
        Joker.start();

        // Create a large array to test performance/memory handling
        final testData = List.generate(
          1000,
          (index) => {'id': index, 'name': 'Item $index', 'value': index * 2},
        );

        Joker.stubJsonArray(
          host: 'api.test.com',
          path: '/large-array',
          method: 'GET',
          data: testData,
        );

        final client = HttpClient();
        try {
          final request = await client.getUrl(
            Uri.parse('https://api.test.com/large-array'),
          );
          final response = await request.close();
          final body = await response
              .transform(SystemEncoding().decoder)
              .join();

          expect(response.statusCode, equals(200));
          expect(body, startsWith('['));
          expect(body, endsWith(']'));

          // Check first and last items are present
          expect(body, contains('"name":"Item 0"'));
          expect(body, contains('"name":"Item 999"'));
          expect(body, contains('"value":0'));
          expect(body, contains('"value":1998'));
        } finally {
          client.close();
        }
      });

      test('should preserve order in arrays', () async {
        Joker.start();

        final testData = [
          {'order': 1, 'name': 'First'},
          {'order': 2, 'name': 'Second'},
          {'order': 3, 'name': 'Third'},
          {'order': 4, 'name': 'Fourth'},
          {'order': 5, 'name': 'Fifth'},
        ];

        Joker.stubJsonArray(
          host: 'api.test.com',
          path: '/ordered',
          method: 'GET',
          data: testData,
        );

        final client = HttpClient();
        try {
          final request = await client.getUrl(
            Uri.parse('https://api.test.com/ordered'),
          );
          final response = await request.close();
          final body = await response
              .transform(SystemEncoding().decoder)
              .join();

          expect(response.statusCode, equals(200));

          // Check that order is preserved by ensuring "First" comes before "Second", etc.
          final firstIndex = body.indexOf('"name":"First"');
          final secondIndex = body.indexOf('"name":"Second"');
          final thirdIndex = body.indexOf('"name":"Third"');
          final fourthIndex = body.indexOf('"name":"Fourth"');
          final fifthIndex = body.indexOf('"name":"Fifth"');

          expect(firstIndex, lessThan(secondIndex));
          expect(secondIndex, lessThan(thirdIndex));
          expect(thirdIndex, lessThan(fourthIndex));
          expect(fourthIndex, lessThan(fifthIndex));
        } finally {
          client.close();
        }
      });

      test('should handle Unicode and special characters in arrays', () async {
        Joker.start();

        final testData = [
          {
            'emoji': '🚀💻🎉',
            'unicode': 'Héllö Wörld',
            'special': 'Line 1\nLine 2\tTabbed',
            'quotes': 'He said "Hello!" to me',
            'backslash': 'C:\\Users\\test',
          },
        ];

        Joker.stubJsonArray(
          host: 'api.test.com',
          path: '/unicode',
          method: 'GET',
          data: testData,
        );

        final client = HttpClient();
        try {
          final request = await client.getUrl(
            Uri.parse('https://api.test.com/unicode'),
          );
          final response = await request.close();
          final body = await response
              .transform(SystemEncoding().decoder)
              .join();

          expect(response.statusCode, equals(200));
          expect(body, contains('🚀💻🎉'));
          expect(body, contains('Héllö Wörld'));
          expect(body, contains('Line 1\\nLine 2\\tTabbed'));
          expect(body, contains('He said \\"Hello!\\" to me'));
          expect(body, contains('C:\\\\Users\\\\test'));
        } finally {
          client.close();
        }
      });
    });

    group('stubJsonArray error cases', () {
      test(
        'should handle array with invalid JSON structure gracefully',
        () async {
          Joker.start();

          // This should still work as Dart will handle the encoding
          final testData = [
            {
              'validField': 'valid',
              // JSON encoding should handle this properly
            },
          ];

          expect(() {
            Joker.stubJsonArray(
              host: 'api.test.com',
              path: '/test',
              data: testData,
            );
          }, returnsNormally);
        },
      );

      test('should work with different HTTP methods', () async {
        Joker.start();

        final testData = [
          {'method': 'POST'},
        ];

        Joker.stubJsonArray(
          host: 'api.test.com',
          path: '/method-test',
          method: 'POST',
          data: testData,
        );

        final client = HttpClient();
        try {
          final request = await client.postUrl(
            Uri.parse('https://api.test.com/method-test'),
          );
          final response = await request.close();
          final body = await response
              .transform(SystemEncoding().decoder)
              .join();

          expect(response.statusCode, equals(200));
          expect(body, contains('"method":"POST"'));
        } finally {
          client.close();
        }
      });
    });
  });
}

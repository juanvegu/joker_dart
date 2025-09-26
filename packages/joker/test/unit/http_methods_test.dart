import 'dart:io';
import 'package:test/test.dart';
import 'package:joker/joker.dart';

void main() {
  group('HTTP Methods Support', () {
    setUp(() {
      Joker.stop();
      Joker.clearStubs();
    });

    tearDown(() {
      Joker.stop();
      Joker.clearStubs();
    });

    test('should handle all standard HTTP methods through stubbing', () async {
      Joker.start();

      // Setup stubs for all HTTP methods
      Joker.stubJson(
        host: 'api.test.com',
        path: '/resource',
        method: 'GET',
        data: {'method': 'GET'},
      );
      Joker.stubJson(
        host: 'api.test.com',
        path: '/resource',
        method: 'POST',
        data: {'method': 'POST'},
      );
      Joker.stubJson(
        host: 'api.test.com',
        path: '/resource',
        method: 'PUT',
        data: {'method': 'PUT'},
      );
      Joker.stubJson(
        host: 'api.test.com',
        path: '/resource',
        method: 'PATCH',
        data: {'method': 'PATCH'},
      );
      Joker.stubJson(
        host: 'api.test.com',
        path: '/resource',
        method: 'DELETE',
        data: {'method': 'DELETE'},
      );
      Joker.stubJson(
        host: 'api.test.com',
        path: '/resource',
        method: 'HEAD',
        data: {'method': 'HEAD'},
      );

      final client = HttpClient();
      try {
        // Test GET
        final getRequest = await client.getUrl(
          Uri.parse('https://api.test.com/resource'),
        );
        final getResponse = await getRequest.close();
        final getBody = await getResponse
            .transform(SystemEncoding().decoder)
            .join();
        expect(getResponse.statusCode, equals(200));
        expect(getBody, contains('"method":"GET"'));

        // Test POST
        final postRequest = await client.postUrl(
          Uri.parse('https://api.test.com/resource'),
        );
        final postResponse = await postRequest.close();
        final postBody = await postResponse
            .transform(SystemEncoding().decoder)
            .join();
        expect(postResponse.statusCode, equals(200));
        expect(postBody, contains('"method":"POST"'));

        // Test PUT
        final putRequest = await client.putUrl(
          Uri.parse('https://api.test.com/resource'),
        );
        final putResponse = await putRequest.close();
        final putBody = await putResponse
            .transform(SystemEncoding().decoder)
            .join();
        expect(putResponse.statusCode, equals(200));
        expect(putBody, contains('"method":"PUT"'));

        // Test DELETE
        final deleteRequest = await client.deleteUrl(
          Uri.parse('https://api.test.com/resource'),
        );
        final deleteResponse = await deleteRequest.close();
        final deleteBody = await deleteResponse
            .transform(SystemEncoding().decoder)
            .join();
        expect(deleteResponse.statusCode, equals(200));
        expect(deleteBody, contains('"method":"DELETE"'));

        // Test HEAD
        final headRequest = await client.headUrl(
          Uri.parse('https://api.test.com/resource'),
        );
        final headResponse = await headRequest.close();
        expect(headResponse.statusCode, equals(200));

        // Test PATCH
        final patchRequest = await client.patchUrl(
          Uri.parse('https://api.test.com/resource'),
        );
        final patchResponse = await patchRequest.close();
        final patchBody = await patchResponse
            .transform(SystemEncoding().decoder)
            .join();
        expect(patchResponse.statusCode, equals(200));
        expect(patchBody, contains('"method":"PATCH"'));
      } finally {
        client.close();
      }
    });

    test('should handle POST requests with custom status codes', () async {
      Joker.start();

      final responseData = {'id': 456, 'message': 'User created successfully'};

      Joker.stubJson(
        host: 'api.test.com',
        path: '/users',
        method: 'POST',
        statusCode: 201,
        data: responseData,
      );

      final client = HttpClient();
      try {
        final request = await client.postUrl(
          Uri.parse('https://api.test.com/users'),
        );
        request.write('{"name": "New User"}');
        final response = await request.close();
        final body = await response.transform(SystemEncoding().decoder).join();

        expect(response.statusCode, equals(201));
        expect(body, contains('"id":456'));
        expect(body, contains('"message":"User created successfully"'));
      } finally {
        client.close();
      }
    });

    test('should handle different port configurations', () async {
      Joker.start();

      // Test different ports - using different hosts to avoid conflicts
      Joker.stubJson(
        host: 'localhost-3000',
        path: '/api',
        data: {'port': 3000},
      );
      Joker.stubJson(
        host: 'localhost-8080',
        path: '/api',
        data: {'port': 8080},
      );

      final client = HttpClient();
      try {
        // Test port 3000 (simulated with different host)
        final request3000 = await client.getUrl(
          Uri.parse('http://localhost-3000/api'),
        );
        final response3000 = await request3000.close();
        final body3000 = await response3000
            .transform(SystemEncoding().decoder)
            .join();
        expect(response3000.statusCode, equals(200));
        expect(body3000, contains('"port":3000'));

        // Test port 8080 (simulated with different host)
        final request8080 = await client.getUrl(
          Uri.parse('http://localhost-8080/api'),
        );
        final response8080 = await request8080.close();
        final body8080 = await response8080
            .transform(SystemEncoding().decoder)
            .join();
        expect(response8080.statusCode, equals(200));
        expect(body8080, contains('"port":8080'));
      } finally {
        client.close();
      }
    });

    test('should handle custom HTTP methods', () async {
      Joker.start();

      // Test custom method
      Joker.stubJson(
        host: 'api.test.com',
        path: '/webhook',
        method: 'WEBHOOK',
        data: {'custom': true},
      );

      final client = HttpClient();
      try {
        final request = await client.openUrl(
          'WEBHOOK',
          Uri.parse('https://api.test.com/webhook'),
        );
        final response = await request.close();
        final body = await response.transform(SystemEncoding().decoder).join();
        expect(response.statusCode, equals(200));
        expect(body, contains('"custom":true'));
      } finally {
        client.close();
      }
    });

    group('URL Matching', () {
      test('should match requests with query parameters', () async {
        Joker.start();

        Joker.stubJson(
          host: 'api.test.com',
          path: '/search',
          data: {'results': [], 'total': 0},
        );

        final client = HttpClient();
        try {
          final request = await client.getUrl(
            Uri.parse('https://api.test.com/search?q=test&limit=10'),
          );
          final response = await request.close();
          final body = await response
              .transform(SystemEncoding().decoder)
              .join();

          expect(response.statusCode, equals(200));
          expect(body, contains('"results":[]'));
          expect(body, contains('"total":0'));
        } finally {
          client.close();
        }
      });

      test('should match partial host patterns', () async {
        Joker.start();

        // Test without specifying full host
        Joker.stubJson(path: '/any-host', data: {'matched': true});

        final client = HttpClient();
        try {
          final request = await client.getUrl(
            Uri.parse('https://any.domain.com/any-host'),
          );
          final response = await request.close();
          final body = await response
              .transform(SystemEncoding().decoder)
              .join();

          expect(response.statusCode, equals(200));
          expect(body, contains('"matched":true'));
        } finally {
          client.close();
        }
      });
    });
  });
}

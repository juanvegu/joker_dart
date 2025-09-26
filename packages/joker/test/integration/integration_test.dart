import 'dart:io';
import 'package:test/test.dart';
import 'package:joker/joker.dart';

void main() {
  group('Integration Tests', () {
    setUp(() {
      Joker.stop();
      Joker.clearStubs();
    });

    tearDown(() {
      Joker.stop();
      Joker.clearStubs();
    });

    test('should handle complex authentication flow', () async {
      Joker.start();

      // Mock login endpoint
      Joker.stubJson(
        host: 'auth.test.com',
        path: '/login',
        method: 'POST',
        data: {
          'access_token': 'token_123',
          'refresh_token': 'refresh_456',
          'expires_in': 3600,
        },
      );

      // Mock protected endpoint
      Joker.stubJson(
        host: 'api.test.com',
        path: '/profile',
        method: 'GET',
        data: {
          'id': 'user_123',
          'name': 'Test User',
          'email': 'test@example.com',
        },
      );

      final client = HttpClient();
      try {
        // Step 1: Login
        final loginRequest = await client.postUrl(
          Uri.parse('https://auth.test.com/login'),
        );
        loginRequest.write('{"username": "test", "password": "pass"}');
        final loginResponse = await loginRequest.close();
        final loginBody = await loginResponse
            .transform(SystemEncoding().decoder)
            .join();

        expect(loginResponse.statusCode, equals(200));
        expect(loginBody, contains('"access_token":"token_123"'));

        // Step 2: Access protected resource
        final profileRequest = await client.getUrl(
          Uri.parse('https://api.test.com/profile'),
        );
        profileRequest.headers.set('Authorization', 'Bearer token_123');
        final profileResponse = await profileRequest.close();
        final profileBody = await profileResponse
            .transform(SystemEncoding().decoder)
            .join();

        expect(profileResponse.statusCode, equals(200));
        expect(profileBody, contains('"name":"Test User"'));
      } finally {
        client.close();
      }
    });

    test('should handle complete CRUD operations workflow', () async {
      Joker.start();

      // Mock CREATE (POST)
      Joker.stubJson(
        host: 'api.test.com',
        path: '/users',
        method: 'POST',
        statusCode: 201,
        data: {'id': 1, 'name': 'New User', 'created': true},
      );

      // Mock READ (GET)
      Joker.stubJson(
        host: 'api.test.com',
        path: '/users/1',
        method: 'GET',
        data: {'id': 1, 'name': 'New User', 'email': 'user@test.com'},
      );

      // Mock UPDATE (PUT)
      Joker.stubJson(
        host: 'api.test.com',
        path: '/users/1',
        method: 'PUT',
        data: {'id': 1, 'name': 'Updated User', 'updated': true},
      );

      // Mock DELETE
      Joker.stubJson(
        host: 'api.test.com',
        path: '/users/1',
        method: 'DELETE',
        statusCode: 204,
        data: {},
      );

      final client = HttpClient();
      try {
        // CREATE
        final createRequest = await client.postUrl(
          Uri.parse('https://api.test.com/users'),
        );
        createRequest.write('{"name": "New User"}');
        final createResponse = await createRequest.close();
        final createBody = await createResponse
            .transform(SystemEncoding().decoder)
            .join();
        expect(createResponse.statusCode, equals(201));
        expect(createBody, contains('"created":true'));

        // READ
        final readRequest = await client.getUrl(
          Uri.parse('https://api.test.com/users/1'),
        );
        final readResponse = await readRequest.close();
        final readBody = await readResponse
            .transform(SystemEncoding().decoder)
            .join();
        expect(readResponse.statusCode, equals(200));
        expect(readBody, contains('"email":"user@test.com"'));

        // UPDATE
        final updateRequest = await client.putUrl(
          Uri.parse('https://api.test.com/users/1'),
        );
        updateRequest.write('{"name": "Updated User"}');
        final updateResponse = await updateRequest.close();
        final updateBody = await updateResponse
            .transform(SystemEncoding().decoder)
            .join();
        expect(updateResponse.statusCode, equals(200));
        expect(updateBody, contains('"updated":true'));

        // DELETE
        final deleteRequest = await client.deleteUrl(
          Uri.parse('https://api.test.com/users/1'),
        );
        final deleteResponse = await deleteRequest.close();
        expect(deleteResponse.statusCode, equals(204));
      } finally {
        client.close();
      }
    });

    test('should handle API versioning scenario', () async {
      Joker.start();

      // Mock v1 API
      Joker.stubJson(
        host: 'api.test.com',
        path: '/v1/users',
        data: {'version': 'v1', 'users': []},
        headers: {'API-Version': '1.0'},
      );

      // Mock v2 API
      Joker.stubJson(
        host: 'api.test.com',
        path: '/v2/users',
        data: {
          'version': 'v2',
          'users': [],
          'meta': {'total': 0},
        },
        headers: {'API-Version': '2.0'},
      );

      final client = HttpClient();
      try {
        // Test v1 API
        final v1Request = await client.getUrl(
          Uri.parse('https://api.test.com/v1/users'),
        );
        final v1Response = await v1Request.close();
        final v1Body = await v1Response
            .transform(SystemEncoding().decoder)
            .join();
        expect(v1Response.statusCode, equals(200));
        expect(v1Body, contains('"version":"v1"'));
        expect(v1Response.headers['api-version'], contains('1.0'));

        // Test v2 API
        final v2Request = await client.getUrl(
          Uri.parse('https://api.test.com/v2/users'),
        );
        final v2Response = await v2Request.close();
        final v2Body = await v2Response
            .transform(SystemEncoding().decoder)
            .join();
        expect(v2Response.statusCode, equals(200));
        expect(v2Body, contains('"version":"v2"'));
        expect(v2Body, contains('"meta"'));
        expect(v2Response.headers['api-version'], contains('2.0'));
      } finally {
        client.close();
      }
    });

    test('should handle mixed success and error scenarios', () async {
      Joker.start();

      // Successful endpoints
      Joker.stubJson(
        host: 'api.test.com',
        path: '/success',
        data: {'status': 'success'},
      );

      // Error endpoints
      Joker.stubJson(
        host: 'api.test.com',
        path: '/error',
        statusCode: 500,
        data: {'status': 'error', 'message': 'Something went wrong'},
      );

      final client = HttpClient();
      try {
        // Test successful request
        final successRequest = await client.getUrl(
          Uri.parse('https://api.test.com/success'),
        );
        final successResponse = await successRequest.close();
        final successBody = await successResponse
            .transform(SystemEncoding().decoder)
            .join();
        expect(successResponse.statusCode, equals(200));
        expect(successBody, contains('"status":"success"'));

        // Test error request
        final errorRequest = await client.getUrl(
          Uri.parse('https://api.test.com/error'),
        );
        final errorResponse = await errorRequest.close();
        final errorBody = await errorResponse
            .transform(SystemEncoding().decoder)
            .join();
        expect(errorResponse.statusCode, equals(500));
        expect(errorBody, contains('"status":"error"'));
        expect(errorBody, contains('"message":"Something went wrong"'));
      } finally {
        client.close();
      }
    });

    test('should handle concurrent requests', () async {
      Joker.start();

      // Setup stubs for concurrent testing
      Joker.stubJson(
        host: 'api.test.com',
        path: '/endpoint1',
        data: {'endpoint': 1},
      );
      Joker.stubJson(
        host: 'api.test.com',
        path: '/endpoint2',
        data: {'endpoint': 2},
      );
      Joker.stubJson(
        host: 'api.test.com',
        path: '/endpoint3',
        data: {'endpoint': 3},
      );

      final client = HttpClient();
      try {
        // Make concurrent requests
        final futures = [
          client
              .getUrl(Uri.parse('https://api.test.com/endpoint1'))
              .then((req) => req.close()),
          client
              .getUrl(Uri.parse('https://api.test.com/endpoint2'))
              .then((req) => req.close()),
          client
              .getUrl(Uri.parse('https://api.test.com/endpoint3'))
              .then((req) => req.close()),
        ];

        final responses = await Future.wait(futures);

        // Verify all responses
        expect(responses[0].statusCode, equals(200));
        expect(responses[1].statusCode, equals(200));
        expect(responses[2].statusCode, equals(200));

        // Verify response bodies
        final bodies = await Future.wait(
          responses.map(
            (response) => response.transform(SystemEncoding().decoder).join(),
          ),
        );

        expect(bodies[0], contains('"endpoint":1'));
        expect(bodies[1], contains('"endpoint":2'));
        expect(bodies[2], contains('"endpoint":3'));
      } finally {
        client.close();
      }
    });
  });
}

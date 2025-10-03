import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:joker_http/joker_http.dart'; // Re-exports Joker + adds createHttpClient
import 'package:test/test.dart';

void main() {
  group('createHttpClient', () {
    late http.Client client;

    setUp(() {
      Joker.stop(); // Ensure clean state
      client = createHttpClient();
    });

    tearDown(() {
      client.close();
      Joker.stop();
    });

    test('intercepts requests when Joker is active', () async {
      Joker.start();
      Joker.stubJson(
        host: 'api.test.com',
        path: '/users',
        data: {'id': 1, 'name': 'Test User'},
      );

      final response = await client.get(
        Uri.parse('https://api.test.com/users'),
      );

      expect(response.statusCode, 200);
      final json = jsonDecode(response.body);
      expect(json['name'], 'Test User');
    });

    test('handles JSON array responses', () async {
      Joker.start();
      Joker.stubJsonArray(
        host: 'api.test.com',
        path: '/posts',
        data: [
          {'id': 1, 'title': 'Post 1'},
          {'id': 2, 'title': 'Post 2'},
        ],
      );

      final response = await client.get(
        Uri.parse('https://api.test.com/posts'),
      );

      expect(response.statusCode, 200);
      final json = jsonDecode(response.body) as List;
      expect(json.length, 2);
      expect(json[0]['title'], 'Post 1');
    });

    test('supports custom status codes', () async {
      Joker.start();
      Joker.stubJson(
        host: 'api.test.com',
        path: '/error',
        data: {'error': 'Not found'},
        statusCode: 404,
      );

      final response = await client.get(
        Uri.parse('https://api.test.com/error'),
      );

      expect(response.statusCode, 404);
    });
  });
}

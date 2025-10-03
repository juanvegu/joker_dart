import 'package:dio/dio.dart';
import 'package:joker_dio/joker_dio.dart'; // Re-exports Joker + adds JokerDioInterceptor
import 'package:test/test.dart';

void main() {
  group('JokerDioInterceptor', () {
    late Dio dio;

    setUp(() {
      Joker.stop(); // Ensure clean state
      dio = Dio();
      dio.interceptors.add(JokerDioInterceptor());
    });

    tearDown(() {
      Joker.stop();
    });

    test('intercepts requests when Joker is active', () async {
      Joker.start();
      Joker.stubJson(
        host: 'api.test.com',
        path: '/users',
        data: {'id': 1, 'name': 'Test User'},
      );

      final response = await dio.get('https://api.test.com/users');

      expect(response.statusCode, 200);
      expect(response.data['name'], 'Test User');
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

      final response = await dio.get('https://api.test.com/posts');

      expect(response.statusCode, 200);
      expect(response.data, isList);
      expect((response.data as List).length, 2);
      expect(response.data[0]['title'], 'Post 1');
    });

    test('supports custom status codes', () async {
      Joker.start();
      Joker.stubJson(
        host: 'api.test.com',
        path: '/error',
        data: {'error': 'Not found'},
        statusCode: 404,
      );

      final response = await dio.get('https://api.test.com/error');

      expect(response.statusCode, 404);
      expect(response.data['error'], 'Not found');
    });

    test('supports custom headers', () async {
      Joker.start();
      Joker.stubJson(
        host: 'api.test.com',
        path: '/data',
        data: {'message': 'Hello'},
        headers: {'x-custom-header': 'custom-value'},
      );

      final response = await dio.get('https://api.test.com/data');

      expect(response.statusCode, 200);
      expect(response.headers.value('x-custom-header'), 'custom-value');
    });
  });
}

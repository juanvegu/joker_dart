import 'package:flutter_test/flutter_test.dart';
import 'package:joker/joker.dart';
import 'package:joker_http_native_example/api_service.dart';
import 'package:joker_http_native_example/models.dart';

void main() {
  late JsonPlaceholderService apiService;

  setUp(() {
    apiService = JsonPlaceholderService();
    // Limpiar stubs antes de cada test
    Joker.stop();
    Joker.clearStubs();
  });

  tearDown(() {
    // Limpiar stubs después de cada test
    Joker.stop();
    Joker.clearStubs();
  });

  group('JsonPlaceholderService Tests', () {
    group('Real API Tests', () {
      test('should fetch posts from real API when Joker is disabled', () async {
        // Arrange
        Joker.stop();

        // Act
        final posts = await apiService.getPosts();

        // Assert
        expect(posts, isNotEmpty);
        expect(posts.first, isA<Post>());
        expect(posts.first.id, isA<int>());
        expect(posts.first.title, isA<String>());
        expect(posts.first.body, isA<String>());
        expect(posts.first.userId, isA<int>());
      });

      test('should fetch users from real API when Joker is disabled', () async {
        // Arrange
        Joker.stop();

        // Act
        final users = await apiService.getUsers();

        // Assert
        expect(users, isNotEmpty);
        expect(users.first, isA<User>());
        expect(users.first.id, isA<int>());
        expect(users.first.name, isA<String>());
        expect(users.first.email, isA<String>());
      });
    });

    group('Joker Mock Tests', () {
      test('should fetch mocked posts when Joker is enabled', () async {
        // Arrange
        Joker.start();
        
        // Configurar stub para posts
        Joker.stubJsonArray(
          host: 'jsonplaceholder.typicode.com',
          path: '/posts',
          method: 'GET',
          data: [
            {
              'id': 999,
              'userId': 999,
              'title': 'Test Post from Joker',
              'body': 'This is a test post created by Joker for testing purposes.',
            }
          ],
          name: 'Test posts stub',
        );

        // Act
        final posts = await apiService.getPosts();

        // Assert
        expect(posts, hasLength(1));
        expect(posts.first.id, equals(999));
        expect(posts.first.userId, equals(999));
        expect(posts.first.title, equals('Test Post from Joker'));
        expect(posts.first.body, contains('test post created by Joker'));
      });

      test('should fetch mocked users when Joker is enabled', () async {
        // Arrange
        Joker.start();
        
        // Configurar stub para users
        Joker.stubJsonArray(
          host: 'jsonplaceholder.typicode.com',
          path: '/users',
          method: 'GET',
          data: [
            {
              'id': 888,
              'name': 'Test User',
              'username': 'testuser',
              'email': 'test@joker.com',
            }
          ],
          name: 'Test users stub',
        );

        // Act
        final users = await apiService.getUsers();

        // Assert
        expect(users, hasLength(1));
        expect(users.first.id, equals(888));
        expect(users.first.name, equals('Test User'));
        expect(users.first.email, equals('test@joker.com'));
      });

      test('should handle different HTTP status codes with Joker', () async {
        // Arrange
        Joker.start();
        
        // Stub que simula un error 404
        Joker.stubText(
          host: 'jsonplaceholder.typicode.com',
          path: '/posts',
          method: 'GET',
          text: '{"error": "Not found"}',
          statusCode: 404,
          name: 'Posts not found stub',
        );

        // Act & Assert
        expect(
          () async => await apiService.getPosts(),
          throwsException,
        );
      });

      test('should simulate network delay with Joker', () async {
        // Arrange
        Joker.start();
        const delay = Duration(milliseconds: 100);
        
        Joker.stubJsonArray(
          host: 'jsonplaceholder.typicode.com',
          path: '/posts',
          method: 'GET',
          data: [{'id': 1, 'userId': 1, 'title': 'Test', 'body': 'Test'}],
          delay: delay,
          name: 'Delayed posts stub',
        );

        // Act
        final stopwatch = Stopwatch()..start();
        await apiService.getPosts();
        stopwatch.stop();

        // Assert
        expect(stopwatch.elapsedMilliseconds, greaterThanOrEqualTo(delay.inMilliseconds - 10));
      });
    });

    group('Joker vs Real API Comparison', () {
      test('should return consistent data structure between real and mock APIs', () async {
        // Test con datos reales
        Joker.stop();
        final realPosts = await apiService.getPosts();
        final realPost = realPosts.first;

        // Test con datos mock
        Joker.start();
        Joker.stubJsonArray(
          host: 'jsonplaceholder.typicode.com',
          path: '/posts',
          method: 'GET',
          data: [
            {
              'id': realPost.id,
              'userId': realPost.userId,
              'title': realPost.title,
              'body': realPost.body,
            }
          ],
          name: 'Consistent structure stub',
        );

        final mockPosts = await apiService.getPosts();
        final mockPost = mockPosts.first;

        // Assert - misma estructura
        expect(mockPost.runtimeType, equals(realPost.runtimeType));
        expect(mockPost.id.runtimeType, equals(realPost.id.runtimeType));
        expect(mockPost.title.runtimeType, equals(realPost.title.runtimeType));
        expect(mockPost.body.runtimeType, equals(realPost.body.runtimeType));
        expect(mockPost.userId.runtimeType, equals(realPost.userId.runtimeType));
      });
    });
  });
}
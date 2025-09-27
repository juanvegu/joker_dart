import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:joker_http_native_example/models.dart';
import 'package:joker_http_native_example/api_service.dart';
import 'package:joker_http_native_example/joker_config.dart';
import 'package:joker/joker.dart';

void main() {
  group('Integration Tests', () {
    late JsonPlaceholderService apiService;

    setUpAll(() async {
      // Initialize Joker configuration for integration tests
      JokerConfiguration.setupStubs();
      apiService = JsonPlaceholderService();
    });

    tearDownAll(() {
      Joker.stop();
    });

    group('End-to-End Data Flow', () {
      test('should fetch posts and their authors using Joker stubs', () async {
        // Arrange
        Joker.start();

        // Act
        final posts = await apiService.getPosts();
        final users = await apiService.getUsers();

        // Assert
        expect(posts, isNotEmpty);
        expect(users, isNotEmpty);

        // Verify that we can match posts to users
        for (final post in posts) {
          final author = users.firstWhere(
            (user) => user.id == post.userId,
            orElse: () => User(
              id: -1,
              name: 'Not Found',
              username: 'notfound',
              email: 'notfound@example.com',
            ),
          );
          expect(author.id, isNot(equals(-1)));
          expect(author.name, isNotEmpty);
        }

        Joker.stop();
      });

      test('should fetch comments for posts using Joker stubs', () async {
        // Arrange
        Joker.start();

        // Act
        final posts = await apiService.getPosts();
        expect(posts, isNotEmpty);

        final firstPost = posts.first;
        final comments = await apiService.getPostComments(firstPost.id);

        // Assert
        expect(comments, isNotEmpty);
        for (final comment in comments) {
          expect(comment.postId, equals(firstPost.id));
          expect(comment.name, isNotEmpty);
          expect(comment.email, isNotEmpty);
          expect(comment.body, isNotEmpty);
        }

        Joker.stop();
      });

      test('should handle multiple concurrent requests with Joker', () async {
        // Arrange
        Joker.start();

        // Act - Make multiple concurrent requests
        final futures = <Future>[
          apiService.getPosts(),
          apiService.getUsers(),
          apiService.getPostComments(1),
          apiService.getPostComments(2),
        ];

        final results = await Future.wait(futures);

        // Assert
        final posts = results[0] as List<Post>;
        final users = results[1] as List<User>;
        final comments1 = results[2] as List<Comment>;
        final comments2 = results[3] as List<Comment>;

        expect(posts, isNotEmpty);
        expect(users, isNotEmpty);
        expect(comments1, isNotEmpty);
        expect(comments2, isNotEmpty);

        // Verify all comments belong to their respective posts
        expect(comments1.every((c) => c.postId == 1), isTrue);
        expect(comments2.every((c) => c.postId == 2), isTrue);

        Joker.stop();
      });
    });

    group('Real vs Mock Data Consistency', () {
      test(
        'should return consistent data structure between real API and Joker stubs',
        () async {
          // Test with real API first (if available)
          Joker.stop();
          List<Post>? realPosts;
          List<User>? realUsers;

          try {
            realPosts = await apiService.getPosts();
            realUsers = await apiService.getUsers();
          } catch (e) {
            // Skip real API test if network is unavailable
            debugPrint('Skipping real API test due to network error: $e');
          }

          // Test with Joker stubs
          Joker.start();
          final mockPosts = await apiService.getPosts();
          final mockUsers = await apiService.getUsers();

          // Assert structure consistency
          expect(mockPosts, isNotEmpty);
          expect(mockUsers, isNotEmpty);

          // Verify mock data has same structure as real data (if available)
          if (realPosts != null && realUsers != null) {
            expect(
              mockPosts.first.runtimeType,
              equals(realPosts.first.runtimeType),
            );
            expect(
              mockUsers.first.runtimeType,
              equals(realUsers.first.runtimeType),
            );

            // Verify properties exist and have correct types
            expect(mockPosts.first.id, isA<int>());
            expect(mockPosts.first.title, isA<String>());
            expect(mockUsers.first.id, isA<int>());
            expect(mockUsers.first.name, isA<String>());
          }

          Joker.stop();
        },
      );

      test('should provide realistic mock data for development', () async {
        // Arrange
        Joker.start();

        // Act
        final posts = await apiService.getPosts();
        final users = await apiService.getUsers();
        final comments = await apiService.getPostComments(1);

        // Assert - Verify mock data is realistic and useful for development

        // Posts should have meaningful content
        expect(posts.length, greaterThanOrEqualTo(3));
        for (final post in posts) {
          expect(post.title.length, greaterThan(5));
          expect(post.body.length, greaterThan(20));
          expect(post.userId, greaterThan(0));
        }

        // Users should have complete profiles
        expect(users.length, greaterThanOrEqualTo(3));
        for (final user in users) {
          expect(user.name.length, greaterThan(2));
          expect(user.username.length, greaterThan(2));
          expect(user.email, contains('@'));
        }

        // Comments should be related to posts
        expect(comments.length, greaterThanOrEqualTo(2));
        for (final comment in comments) {
          expect(comment.postId, equals(1));
          expect(comment.name.length, greaterThan(3));
          expect(comment.email, contains('@'));
          expect(comment.body.length, greaterThan(10));
        }

        Joker.stop();
      });
    });

    group('Performance and Behavior Tests', () {
      test('should respond faster with Joker stubs than real API', () async {
        // Test Joker performance
        Joker.start();

        final jokerStart = DateTime.now();
        await apiService.getPosts();
        await apiService.getUsers();
        final jokerDuration = DateTime.now().difference(jokerStart);

        Joker.stop();

        // Test real API performance (if available)
        Duration? realDuration;
        try {
          final realStart = DateTime.now();
          await apiService.getPosts().timeout(Duration(seconds: 5));
          await apiService.getUsers().timeout(Duration(seconds: 5));
          realDuration = DateTime.now().difference(realStart);
        } catch (e) {
          debugPrint(
            'Skipping real API performance test due to timeout or network error',
          );
        }

        // Assert
        expect(
          jokerDuration.inMilliseconds,
          lessThan(100),
        ); // Joker should be very fast

        if (realDuration != null) {
          expect(
            jokerDuration.inMilliseconds,
            lessThan(realDuration.inMilliseconds),
          );
        }
      });

      test(
        'should maintain state between requests within same session',
        () async {
          // Arrange
          Joker.start();

          // Act - Make multiple requests in sequence
          final posts1 = await apiService.getPosts();
          final posts2 = await apiService.getPosts();
          final users1 = await apiService.getUsers();
          final users2 = await apiService.getUsers();

          // Assert - Results should be consistent
          expect(posts1.length, equals(posts2.length));
          expect(users1.length, equals(users2.length));

          for (int i = 0; i < posts1.length; i++) {
            expect(posts1[i].id, equals(posts2[i].id));
            expect(posts1[i].title, equals(posts2[i].title));
          }

          for (int i = 0; i < users1.length; i++) {
            expect(users1[i].id, equals(users2[i].id));
            expect(users1[i].name, equals(users2[i].name));
          }

          Joker.stop();
        },
      );
    });

    group('Data Validation', () {
      test(
        'should validate that all stubbed data matches expected schema',
        () async {
          // Arrange
          Joker.start();

          // Act
          final posts = await apiService.getPosts();
          final users = await apiService.getUsers();
          final comments = await apiService.getPostComments(1);

          // Assert - Validate schema compliance

          // Posts schema validation
          for (final post in posts) {
            expect(post.id, isA<int>());
            expect(post.userId, isA<int>());
            expect(post.title, isA<String>());
            expect(post.body, isA<String>());
            expect(post.id, greaterThan(0));
            expect(post.userId, greaterThan(0));
            expect(post.title, isNotEmpty);
            expect(post.body, isNotEmpty);
          }

          // Users schema validation
          for (final user in users) {
            expect(user.id, isA<int>());
            expect(user.name, isA<String>());
            expect(user.username, isA<String>());
            expect(user.email, isA<String>());
            expect(user.id, greaterThan(0));
            expect(user.name, isNotEmpty);
            expect(user.username, isNotEmpty);
            expect(user.email, contains('@'));
            expect(user.email, contains('.'));
          }

          // Comments schema validation
          for (final comment in comments) {
            expect(comment.postId, isA<int>());
            expect(comment.id, isA<int>());
            expect(comment.name, isA<String>());
            expect(comment.email, isA<String>());
            expect(comment.body, isA<String>());
            expect(comment.postId, equals(1));
            expect(comment.id, greaterThan(0));
            expect(comment.name, isNotEmpty);
            expect(comment.email, contains('@'));
            expect(comment.body, isNotEmpty);
          }

          Joker.stop();
        },
      );
    });
  });
}

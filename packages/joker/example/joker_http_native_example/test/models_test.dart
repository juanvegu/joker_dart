import 'package:flutter_test/flutter_test.dart';
import 'package:joker_http_native_example/models.dart';

void main() {
  group('Models Tests', () {
    group('Post Model', () {
      test('should create Post from valid JSON', () {
        // Arrange
        final json = {
          'id': 1,
          'userId': 1,
          'title': 'Test Title',
          'body': 'Test Body',
        };

        // Act
        final post = Post.fromJson(json);

        // Assert
        expect(post.id, equals(1));
        expect(post.userId, equals(1));
        expect(post.title, equals('Test Title'));
        expect(post.body, equals('Test Body'));
      });

      test('should convert Post to JSON', () {
        // Arrange
        final post = Post(
          id: 1,
          userId: 1,
          title: 'Test Title',
          body: 'Test Body',
        );

        // Act
        final json = post.toJson();

        // Assert
        expect(json['id'], equals(1));
        expect(json['userId'], equals(1));
        expect(json['title'], equals('Test Title'));
        expect(json['body'], equals('Test Body'));
      });

      test('should handle various data types in JSON', () {
        // Arrange
        final json = {
          'id': 42,
          'userId': 7,
          'title': 'Complex Post Title with Special Characters',
          'body': 'Multi-line\nbody content\nwith various characters 😊',
        };

        // Act
        final post = Post.fromJson(json);

        // Assert
        expect(post.id, equals(42));
        expect(post.userId, equals(7));
        expect(post.title, contains('Special Characters'));
        expect(post.body, contains('Multi-line'));
        expect(post.body, contains('😊'));
      });
    });

    group('User Model', () {
      test('should create User from valid JSON', () {
        // Arrange
        final json = {
          'id': 1,
          'name': 'John Doe',
          'username': 'johndoe',
          'email': 'john@example.com',
        };

        // Act
        final user = User.fromJson(json);

        // Assert
        expect(user.id, equals(1));
        expect(user.name, equals('John Doe'));
        expect(user.username, equals('johndoe'));
        expect(user.email, equals('john@example.com'));
      });

      test('should convert User to JSON', () {
        // Arrange
        final user = User(
          id: 1,
          name: 'Jane Smith',
          username: 'janesmith',
          email: 'jane@example.com',
        );

        // Act
        final json = user.toJson();

        // Assert
        expect(json['id'], equals(1));
        expect(json['name'], equals('Jane Smith'));
        expect(json['username'], equals('janesmith'));
        expect(json['email'], equals('jane@example.com'));
      });

      test('should handle special characters in user data', () {
        // Arrange
        final json = {
          'id': 123,
          'name': 'José María González-Pérez',
          'username': 'jose.maria_123',
          'email': 'josé.maría@español.com',
        };

        // Act
        final user = User.fromJson(json);

        // Assert
        expect(user.id, equals(123));
        expect(user.name, contains('José'));
        expect(user.name, contains('González-Pérez'));
        expect(user.email, contains('español.com'));
      });
    });

    group('Comment Model', () {
      test('should create Comment from valid JSON', () {
        // Arrange
        final json = {
          'postId': 1,
          'id': 1,
          'name': 'Test Comment',
          'email': 'test@example.com',
          'body': 'This is a test comment',
        };

        // Act
        final comment = Comment.fromJson(json);

        // Assert
        expect(comment.postId, equals(1));
        expect(comment.id, equals(1));
        expect(comment.name, equals('Test Comment'));
        expect(comment.email, equals('test@example.com'));
        expect(comment.body, equals('This is a test comment'));
      });

      test('should convert Comment to JSON', () {
        // Arrange
        final comment = Comment(
          postId: 5,
          id: 25,
          name: 'Great post!',
          email: 'commenter@example.com',
          body: 'Really enjoyed reading this post. Thanks for sharing!',
        );

        // Act
        final json = comment.toJson();

        // Assert
        expect(json['postId'], equals(5));
        expect(json['id'], equals(25));
        expect(json['name'], equals('Great post!'));
        expect(json['email'], equals('commenter@example.com'));
        expect(json['body'], contains('Really enjoyed'));
      });

      test('should handle long comment bodies', () {
        // Arrange
        final longBody = 'Lorem ipsum ' * 100; // Very long comment
        final json = {
          'postId': 1,
          'id': 1,
          'name': 'Long Comment',
          'email': 'long@example.com',
          'body': longBody,
        };

        // Act
        final comment = Comment.fromJson(json);

        // Assert
        expect(comment.body.length, greaterThan(1000));
        expect(comment.body, startsWith('Lorem ipsum'));
        expect(comment.body, endsWith('Lorem ipsum '));
      });
    });

    group('Error Handling', () {
      test('should throw error for invalid Post JSON', () {
        // Arrange
        final invalidJson = {
          'id': 'invalid', // Should be int
          'userId': 1,
          'title': 'Test',
          'body': 'Test',
        };

        // Act & Assert
        expect(
          () => Post.fromJson(invalidJson),
          throwsA(isA<TypeError>()),
        );
      });

      test('should throw error for missing required User fields', () {
        // Arrange
        final incompleteJson = {
          'id': 1,
          'name': 'John Doe',
          // Missing username and email
        };

        // Act & Assert
        expect(
          () => User.fromJson(incompleteJson),
          throwsA(isA<TypeError>()),
        );
      });

      test('should throw error for null values in Comment', () {
        // Arrange
        final nullJson = {
          'postId': null,
          'id': 1,
          'name': 'Test',
          'email': 'test@example.com',
          'body': 'Test body',
        };

        // Act & Assert
        expect(
          () => Comment.fromJson(nullJson),
          throwsA(isA<TypeError>()),
        );
      });
    });
  });
}
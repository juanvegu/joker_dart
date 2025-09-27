import 'package:test/test.dart';
import 'package:joker/src/expections/file_load_exception.dart';

void main() {
  group('JokerFileLoadException', () {
    test('should create exception with message', () {
      const message = 'Test error message';
      const exception = JokerFileLoadException(message);

      expect(exception.message, equals(message));
    });

    test('should have correct toString representation', () {
      const message = 'File not found error';
      const exception = JokerFileLoadException(message);

      expect(
        exception.toString(),
        equals('JokerFileLoadException: File not found error'),
      );
    });

    test('should implement Exception interface', () {
      const exception = JokerFileLoadException('test');

      expect(exception, isA<Exception>());
    });
  });
}

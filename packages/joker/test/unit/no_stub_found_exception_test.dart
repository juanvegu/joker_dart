// Tests for JokerNoStubFoundException coverage
import 'package:test/test.dart';
import 'package:joker/src/expections/no_stub_found_exception.dart';

void main() {
  group('JokerNoStubFoundException', () {
    test('toString returns formatted exception message', () {
      const exception = JokerNoStubFoundException('Test error message');

      expect(
        exception.toString(),
        equals('JokerNoStubFoundException: Test error message'),
      );
      expect(exception.message, equals('Test error message'));
    });

    test('toString works with different message types', () {
      const emptyException = JokerNoStubFoundException('');
      expect(emptyException.toString(), equals('JokerNoStubFoundException: '));

      const longException = JokerNoStubFoundException(
        'This is a very long error message that should still work correctly',
      );
      expect(
        longException.toString(),
        equals(
          'JokerNoStubFoundException: This is a very long error message that should still work correctly',
        ),
      );

      const specialCharsException = JokerNoStubFoundException(
        'Error with special chars: üñíçødé',
      );
      expect(
        specialCharsException.toString(),
        equals('JokerNoStubFoundException: Error with special chars: üñíçødé'),
      );
    });

    test('exception can be thrown and caught', () {
      expect(
        () => throw const JokerNoStubFoundException('Test'),
        throwsA(isA<JokerNoStubFoundException>()),
      );

      try {
        throw const JokerNoStubFoundException('Caught exception');
      } on JokerNoStubFoundException catch (e) {
        expect(e.message, equals('Caught exception'));
        expect(e.toString(), contains('JokerNoStubFoundException'));
      }
    });
  });
}

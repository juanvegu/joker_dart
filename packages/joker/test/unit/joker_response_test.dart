// Tests for JokerResponse coverage
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:test/test.dart';
import 'package:joker/src/joker_response.dart';
import 'package:joker/src/expections/file_load_exception.dart';

void main() {
  group('JokerResponse', () {
    test('constructor with default values', () {
      const response = JokerResponse();

      expect(response.statusCode, equals(200));
      expect(response.headers, equals({}));
      expect(response.body, isNull);
      expect(response.delay, isNull);
    });

    test('constructor with custom values', () {
      final customHeaders = {'custom': 'value'};
      const customDelay = Duration(milliseconds: 500);

      final response = JokerResponse(
        statusCode: 404,
        headers: customHeaders,
        body: 'Not found',
        delay: customDelay,
      );

      expect(response.statusCode, equals(404));
      expect(response.headers, equals(customHeaders));
      expect(response.body, equals('Not found'));
      expect(response.delay, equals(customDelay));
    });

    test('json factory creates correct response', () {
      final jsonData = {'message': 'success', 'count': 42};

      final response = JokerResponse.json(jsonData);

      expect(response.statusCode, equals(200));
      expect(
        response.headers['content-type'],
        equals('application/json; charset=utf-8'),
      );
      expect(response.body, equals('{"message":"success","count":42}'));
      expect(response.delay, isNull);
    });

    test('json factory with custom parameters', () {
      final jsonData = {'error': 'validation failed'};
      final customHeaders = {'x-request-id': '12345'};
      const customDelay = Duration(seconds: 1);

      final response = JokerResponse.json(
        jsonData,
        statusCode: 400,
        headers: customHeaders,
        delay: customDelay,
      );

      expect(response.statusCode, equals(400));
      expect(
        response.headers['content-type'],
        equals('application/json; charset=utf-8'),
      );
      expect(response.headers['x-request-id'], equals('12345'));
      expect(response.body, equals('{"error":"validation failed"}'));
      expect(response.delay, equals(customDelay));
    });

    test('bytes getter handles different body types', () {
      // Test with String body
      const stringResponse = JokerResponse(body: 'hello world');
      final stringBytes = stringResponse.bytes;
      expect(stringBytes, equals(utf8.encode('hello world')));

      // Test with Uint8List body
      final originalBytes = Uint8List.fromList([1, 2, 3, 4, 5]);
      final uint8Response = JokerResponse(body: originalBytes);
      expect(uint8Response.bytes, equals(originalBytes));

      // Test with List<int> body
      final intList = [65, 66, 67]; // ABC in ASCII
      final listResponse = JokerResponse(body: intList);
      final listBytes = listResponse.bytes;
      expect(listBytes, equals(Uint8List.fromList(intList)));

      // Test with null body
      const nullResponse = JokerResponse(body: null);
      final nullBytes = nullResponse.bytes;
      expect(nullBytes, equals(Uint8List(0)));

      // Test with other type of body
      const otherResponse = JokerResponse(body: 12345);
      final otherBytes = otherResponse.bytes;
      expect(otherBytes, equals(Uint8List(0)));
    });

    test('json factory merges headers correctly', () {
      final customHeaders = {
        'authorization': 'Bearer token123',
        'x-custom': 'value',
      };

      final response = JokerResponse.json({
        'data': 'test',
      }, headers: customHeaders);

      // Default content-type should be set
      expect(
        response.headers['content-type'],
        equals('application/json; charset=utf-8'),
      );
      // Custom headers should be preserved
      expect(response.headers['authorization'], equals('Bearer token123'));
      expect(response.headers['x-custom'], equals('value'));

      // Test that custom content-type can override default
      final customContentType = {
        'content-type': 'application/json; charset=iso-8859-1',
      };
      final overrideResponse = JokerResponse.json({
        'data': 'test',
      }, headers: customContentType);
      expect(
        overrideResponse.headers['content-type'],
        equals('application/json; charset=iso-8859-1'),
      );
    });

    test('text factory creates correct response with default values', () {
      final response = JokerResponse.text('Hello World');

      expect(response.statusCode, equals(200));
      expect(
        response.headers['content-type'],
        equals('text/plain; charset=utf-8'),
      );
      expect(response.body, equals('Hello World'));
      expect(response.delay, isNull);
    });

    test('text factory creates response with custom parameters', () {
      final customHeaders = {'x-custom': 'value'};
      const customDelay = Duration(milliseconds: 300);

      final response = JokerResponse.text(
        'Custom text',
        statusCode: 201,
        headers: customHeaders,
        delay: customDelay,
      );

      expect(response.statusCode, equals(201));
      expect(
        response.headers['content-type'],
        equals('text/plain; charset=utf-8'),
      );
      expect(response.headers['x-custom'], equals('value'));
      expect(response.body, equals('Custom text'));
      expect(response.delay, equals(customDelay));
    });

    test('text factory merges headers correctly', () {
      final customHeaders = {
        'authorization': 'Bearer token',
        'content-type': 'text/html; charset=utf-8', // Override default
      };

      final response = JokerResponse.text(
        'HTML content',
        headers: customHeaders,
      );

      expect(
        response.headers['content-type'],
        equals('text/html; charset=utf-8'),
      );
      expect(response.headers['authorization'], equals('Bearer token'));
    });

    test('jsonFile factory creates response from valid JSON file', () async {
      // Create a temporary JSON file
      final tempDir = Directory.systemTemp.createTempSync('joker_test');
      final jsonFile = File('${tempDir.path}/test.json');

      final testData = {'message': 'Hello from file', 'id': 123};
      await jsonFile.writeAsString(jsonEncode(testData));

      final response = await JokerResponse.jsonFile(jsonFile.path);

      expect(response.statusCode, equals(200));
      expect(
        response.headers['content-type'],
        equals('application/json; charset=utf-8'),
      );
      expect(response.body, equals('{"message":"Hello from file","id":123}'));
      expect(response.delay, isNull);

      // Clean up
      await tempDir.delete(recursive: true);
    });

    test('jsonFile factory creates response with custom parameters', () async {
      // Create a temporary JSON file
      final tempDir = Directory.systemTemp.createTempSync('joker_test');
      final jsonFile = File('${tempDir.path}/custom.json');

      final testData = {'error': 'Not found'};
      await jsonFile.writeAsString(jsonEncode(testData));

      final customHeaders = {'x-request-id': 'abc123'};
      const customDelay = Duration(seconds: 2);

      final response = await JokerResponse.jsonFile(
        jsonFile.path,
        statusCode: 404,
        headers: customHeaders,
        delay: customDelay,
      );

      expect(response.statusCode, equals(404));
      expect(
        response.headers['content-type'],
        equals('application/json; charset=utf-8'),
      );
      expect(response.headers['x-request-id'], equals('abc123'));
      expect(response.body, equals('{"error":"Not found"}'));
      expect(response.delay, equals(customDelay));

      // Clean up
      await tempDir.delete(recursive: true);
    });

    test(
      'jsonFile factory throws JokerFileLoadException for non-existent file',
      () async {
        expect(
          () => JokerResponse.jsonFile('/non/existent/path.json'),
          throwsA(isA<JokerFileLoadException>()),
        );
      },
    );

    test(
      'jsonFile factory throws JokerFileLoadException for invalid JSON',
      () async {
        // Create a temporary file with invalid JSON
        final tempDir = Directory.systemTemp.createTempSync('joker_test');
        final jsonFile = File('${tempDir.path}/invalid.json');

        await jsonFile.writeAsString('{ invalid json }');

        expect(
          () => JokerResponse.jsonFile(jsonFile.path),
          throwsA(isA<JokerFileLoadException>()),
        );

        // Clean up
        await tempDir.delete(recursive: true);
      },
    );

    test('jsonFile factory exception contains helpful error message', () async {
      const nonExistentPath = '/definitely/does/not/exist.json';

      try {
        await JokerResponse.jsonFile(nonExistentPath);
        fail('Expected JokerFileLoadException to be thrown');
      } catch (e) {
        expect(e, isA<JokerFileLoadException>());
        final exception = e as JokerFileLoadException;
        expect(exception.message, contains('Failed to load JSON file'));
        expect(exception.message, contains(nonExistentPath));
      }
    });
  });
}

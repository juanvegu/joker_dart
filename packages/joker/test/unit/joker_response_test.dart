// Tests for JokerResponse coverage
import 'dart:convert';
import 'dart:typed_data';
import 'package:test/test.dart';
import 'package:joker/src/joker_response.dart';

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
  });
}

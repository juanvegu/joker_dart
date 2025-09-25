// Tests for JokerHttpHeaders coverage
import 'dart:io';
import 'package:test/test.dart';
import 'package:joker/joker.dart';
import 'package:joker/src/http_client/http_headers.dart';

void main() {
  group('JokerHttpHeaders Coverage', () {
    setUp(() {
      Joker.stop();
      Joker.clearStubs();
    });

    tearDown(() {
      Joker.stop();
      Joker.clearStubs();
    });

    test('should exercise all headers methods directly', () {
      final headerMap = <String, List<String>>{};
      final headers = JokerHttpHeaders(headerMap);

      // Test basic add method
      headers.add('Content-Type', 'application/json');
      headers.add('Custom-Header', 'value1');
      headers.add('Custom-Header', 'value2'); // Add another value

      // Test operator [] access
      expect(headers['content-type'], equals(['application/json']));
      expect(headers['custom-header'], equals(['value1', 'value2']));
      expect(headers['non-existent'], isNull);

      // Test set method
      headers.set('content-type', 'text/html');
      expect(headers['content-type'], equals(['text/html']));

      // Test value method
      expect(headers.value('content-type'), equals('text/html'));
      expect(headers.value('custom-header'), equals('value1, value2'));
      expect(headers.value('non-existent'), isNull);

      // Test remove method
      headers.remove('custom-header', 'value1');
      expect(headers['custom-header'], equals(['value2']));

      // Test removeAll method
      headers.removeAll('custom-header');
      expect(headers['custom-header'], isNull);

      // Test forEach method
      var forEachCalls = 0;
      headers.forEach((name, values) {
        forEachCalls++;
      });
      expect(forEachCalls, greaterThan(0));

      // Test clear method
      headers.clear();
      expect(headers['content-type'], isNull);
    });

    test('should test basic header functionality', () {
      final headerMap = <String, List<String>>{};
      final headers = JokerHttpHeaders(headerMap);

      // Test basic functionality
      headers.add('Content-Type', 'application/json');
      expect(headers.value('content-type'), equals('application/json'));

      // Test that headers are case-insensitive for value() lookup
      expect(headers.value('Content-Type'), equals('application/json'));
      expect(headers.value('CONTENT-TYPE'), equals('application/json'));
    });

    test('should test contentType getter with various inputs', () {
      final headerMap = <String, List<String>>{};
      final headers = JokerHttpHeaders(headerMap);

      // Test with no content-type header
      expect(headers.contentType, isNull);

      // Test with valid content-type
      headers.set('content-type', 'application/json; charset=utf-8');
      expect(headers.contentType?.mimeType, equals('application/json'));

      // Test with invalid content-type (should handle gracefully)
      headers.set('content-type', 'invalid-content-type-format');
      // Note: Dart's ContentType.parse might be more lenient than expected
      expect(
        headers.contentType,
        isNotNull,
      ); // May still parse as some content type

      // Test with simple content-type
      headers.set('content-type', 'text/plain');
      expect(headers.contentType?.mimeType, equals('text/plain'));
    });

    test('should test noSuchMethod for various invocations', () {
      final headerMap = <String, List<String>>{};
      final headers = JokerHttpHeaders(headerMap);

      // Test getter invocations
      expect((headers as dynamic).someNonExistentGetter, isNull);

      // Test setter invocations
      expect(
        () => (headers as dynamic).someNonExistentSetter = 'value',
        returnsNormally,
      );

      // Test method invocations
      expect((headers as dynamic).someNonExistentMethod(), isNull);
    });

    test('should exercise headers through HTTP requests', () async {
      Joker.start();

      Joker.stubJson(
        host: 'api.test.com',
        path: '/headers-integration',
        method: 'POST',
        data: {"success": true},
        statusCode: 200,
        headers: {
          'content-type': 'application/json',
          'x-custom': 'response-value',
        },
      );

      final client = HttpClient();
      final request = await client.postUrl(
        Uri.parse('https://api.test.com/headers-integration'),
      );

      // Exercise request headers through the HttpClientRequest interface
      request.headers.add('authorization', 'Bearer token123');
      request.headers.set('content-type', 'application/json');
      request.headers.add('x-custom', 'value1');
      request.headers.add('x-custom', 'value2');

      // Test that headers can be read back
      expect(request.headers.value('authorization'), equals('Bearer token123'));
      expect(request.headers.value('content-type'), equals('application/json'));
      expect(request.headers.value('x-custom'), equals('value1, value2'));

      // Test remove functionality
      request.headers.remove('x-custom', 'value1');
      expect(request.headers.value('x-custom'), equals('value2'));

      request.headers.removeAll('x-custom');
      expect(request.headers.value('x-custom'), isNull);

      // Test contentType getter
      request.headers.set('content-type', 'text/html; charset=utf-8');
      expect(request.headers.contentType?.mimeType, equals('text/html'));

      final response = await request.close();

      // Test response headers
      expect(
        response.headers.value('content-type'),
        equals('application/json'),
      );
      expect(response.headers.value('x-custom'), equals('response-value'));

      client.close();
    });

    test('should test headers case sensitivity and edge cases', () {
      final headerMap = <String, List<String>>{};
      final headers = JokerHttpHeaders(headerMap);

      // Test case insensitivity for access
      headers.add('Content-Type', 'application/json');
      expect(headers['content-type'], isNotNull);
      expect(headers['CONTENT-TYPE'], isNotNull);
      expect(headers['Content-Type'], isNotNull);

      // Test with empty values
      headers.set('empty-header', '');
      expect(headers.value('empty-header'), equals(''));

      // Test multiple values joining
      headers.clear();
      headers.add('multi', 'value1');
      headers.add('multi', 'value2');
      headers.add('multi', 'value3');
      expect(headers.value('multi'), equals('value1, value2, value3'));
    });
  });
}

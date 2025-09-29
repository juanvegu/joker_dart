// Tests for JokerHttpClientResponse coverage
import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'dart:typed_data';
import 'package:test/test.dart';
import 'package:joker/joker.dart';

void main() {
  group('JokerHttpClientResponse Coverage', () {
    setUp(() {
      Joker.stop();
      Joker.clearStubs();
    });

    tearDown(() {
      Joker.stop();
      Joker.clearStubs();
    });

    test('should test all status codes and reason phrases', () async {
      Joker.start();

      final statusCodes = [200, 201, 204, 400, 401, 403, 404, 500, 999];
      final expectedPhrases = {
        200: 'OK',
        201: 'Created',
        204: 'No Content',
        400: 'Bad Request',
        401: 'Unauthorized',
        403: 'Forbidden',
        404: 'Not Found',
        500: 'Internal Server Error',
        999: 'Unknown', // Default case
      };

      final client = HttpClient();

      for (final statusCode in statusCodes) {
        Joker.clearStubs();
        Joker.stubText(
          host: 'api.test.com',
          path: '/status-$statusCode',
          text: 'Status $statusCode response',
          statusCode: statusCode,
        );

        final request = await client.getUrl(
          Uri.parse('https://api.test.com/status-$statusCode'),
        );
        final response = await request.close();

        expect(response.statusCode, equals(statusCode));
        expect(response.reasonPhrase, equals(expectedPhrases[statusCode]));
      }

      client.close();
    });

    test('should test response headers mapping', () async {
      Joker.start();

      final responseHeaders = {
        'Content-Type': 'application/json',
        'Cache-Control': 'no-cache',
        'X-Custom-Header': 'custom-value',
      };

      Joker.stubText(
        host: 'api.test.com',
        path: '/headers-test',
        text: 'headers test',
        statusCode: 200,
        headers: responseHeaders,
      );

      final client = HttpClient();
      final request = await client.getUrl(
        Uri.parse('https://api.test.com/headers-test'),
      );
      final response = await request.close();

      // Test headers are properly mapped (should be lowercase keys)
      expect(
        response.headers.value('content-type'),
        equals('application/json'),
      );
      expect(response.headers.value('cache-control'), equals('no-cache'));
      expect(response.headers.value('x-custom-header'), equals('custom-value'));

      client.close();
    });

    test('should test contentLength property', () async {
      Joker.start();

      // Test with different body sizes
      final testCases = [
        {'body': '', 'expectedLength': 0},
        {'body': 'Hello', 'expectedLength': 5},
        {
          'body': 'Hello, World! This is a longer message.',
          'expectedLength': 39,
        },
      ];

      final client = HttpClient();

      for (int i = 0; i < testCases.length; i++) {
        final testCase = testCases[i];
        Joker.clearStubs();

        Joker.stubText(
          host: 'api.test.com',
          path: '/length-$i',
          text: testCase['body'] as String,
        );

        final request = await client.getUrl(
          Uri.parse('https://api.test.com/length-$i'),
        );
        final response = await request.close();

        expect(response.contentLength, equals(testCase['expectedLength']));
      }

      client.close();
    });

    test('should test response stream transformation', () async {
      Joker.start();

      Joker.stubText(
        host: 'api.test.com',
        path: '/transform-test',
        text: 'Transform this data',
      );

      final client = HttpClient();
      final request = await client.getUrl(
        Uri.parse('https://api.test.com/transform-test'),
      );
      final response = await request.close();

      // Test transform method with a simple transformer
      final transformedStream = response.transform(
        StreamTransformer<List<int>, String>.fromHandlers(
          handleData: (data, sink) {
            sink.add(utf8.decode(data));
          },
        ),
      );

      final transformedData = await transformedStream.join();
      expect(transformedData, equals('Transform this data'));

      client.close();
    });

    test('should test join method', () async {
      Joker.start();

      Joker.stubText(
        host: 'api.test.com',
        path: '/join-test',
        text: 'Join test data',
      );

      final client = HttpClient();
      final request = await client.getUrl(
        Uri.parse('https://api.test.com/join-test'),
      );
      final response = await request.close();

      // Test join method
      final joinedData = await response.join();
      expect(joinedData, equals('Join test data'));

      // Test join with separator (though it may not be used with single chunk)
      final joinedWithSeparator = await response.join('|');
      expect(joinedWithSeparator, equals('Join test data'));

      client.close();
    });

    test(
      'should test response with different body types for bytes conversion',
      () async {
        Joker.start();

        // Test with Uint8List body
        final binaryData = Uint8List.fromList([
          72,
          101,
          108,
          108,
          111,
        ]); // "Hello"
        Joker.stubText(
          host: 'api.test.com',
          path: '/binary-test',
          text: String.fromCharCodes(binaryData),
        );

        // Test with List<int> body
        Joker.stubText(
          host: 'api.test.com',
          path: '/list-test',
          text: String.fromCharCodes([87, 111, 114, 108, 100]), // "World"
        );

        final client = HttpClient();

        // Test binary data
        final binaryRequest = await client.getUrl(
          Uri.parse('https://api.test.com/binary-test'),
        );
        final binaryResponse = await binaryRequest.close();
        expect(binaryResponse.contentLength, equals(5));
        final binaryJoined = await binaryResponse.join();
        expect(binaryJoined, equals('Hello'));

        // Test list data
        final listRequest = await client.getUrl(
          Uri.parse('https://api.test.com/list-test'),
        );
        final listResponse = await listRequest.close();
        expect(listResponse.contentLength, equals(5));
        final listJoined = await listResponse.join();
        expect(listJoined, equals('World'));

        client.close();
      },
    );

    test('should test noSuchMethod for unsupported operations', () async {
      Joker.start();

      Joker.stubText(
        host: 'api.test.com',
        path: '/no-such-method',
        text: 'test',
      );

      final client = HttpClient();
      final request = await client.getUrl(
        Uri.parse('https://api.test.com/no-such-method'),
      );
      final response = await request.close();

      // Test getter invocations return null
      expect((response as dynamic).someNonExistentGetter, isNull);

      // Test setter invocations do nothing
      expect(
        () => (response as dynamic).someNonExistentSetter = 'value',
        returnsNormally,
      );

      // Test method invocations throw UnsupportedError
      expect(
        () => (response as dynamic).someUnsupportedMethod(),
        throwsA(isA<UnsupportedError>()),
      );

      client.close();
    });

    test('should test stream listen with all parameters', () async {
      Joker.start();

      Joker.stubText(
        host: 'api.test.com',
        path: '/listen-test',
        text: 'Listen test data',
      );

      final client = HttpClient();
      final request = await client.getUrl(
        Uri.parse('https://api.test.com/listen-test'),
      );
      final response = await request.close();

      // Test listen with all parameters
      final receivedData = <int>[];
      var errorOccurred = false;

      final subscription = response.listen(
        (data) => receivedData.addAll(data),
        onError: (error) => errorOccurred = true,
        onDone: () {}, // Simple onDone callback
        cancelOnError: true,
      );

      // Wait for stream to complete
      await subscription.asFuture();

      expect(utf8.decode(receivedData), equals('Listen test data'));
      expect(errorOccurred, isFalse);

      client.close();
    });

    test('should test isRedirect property for various status codes', () async {
      Joker.start();

      final client = HttpClient();

      // Test redirect status codes (3xx)
      final redirectCodes = [300, 301, 302, 303, 304, 307, 308];
      for (final code in redirectCodes) {
        Joker.clearStubs();
        Joker.stubText(
          host: 'api.test.com',
          path: '/redirect-$code',
          text: 'redirect response',
          statusCode: code,
        );

        final request = await client.getUrl(
          Uri.parse('https://api.test.com/redirect-$code'),
        );
        final response = await request.close();

        expect(
          response.isRedirect,
          isTrue,
          reason: 'Status $code should be redirect',
        );
      }

      // Test non-redirect status codes
      final nonRedirectCodes = [200, 201, 400, 404, 500];
      for (final code in nonRedirectCodes) {
        Joker.clearStubs();
        Joker.stubText(
          host: 'api.test.com',
          path: '/non-redirect-$code',
          text: 'non-redirect response',
          statusCode: code,
        );

        final request = await client.getUrl(
          Uri.parse('https://api.test.com/non-redirect-$code'),
        );
        final response = await request.close();

        expect(
          response.isRedirect,
          isFalse,
          reason: 'Status $code should not be redirect',
        );
      }

      client.close();
    });

    test('should test redirects property returns empty list', () async {
      Joker.start();

      Joker.stubText(
        host: 'api.test.com',
        path: '/redirects-test',
        text: 'redirects test',
        statusCode: 302,
      );

      final client = HttpClient();
      final request = await client.getUrl(
        Uri.parse('https://api.test.com/redirects-test'),
      );
      final response = await request.close();

      expect(response.redirects, isEmpty);
      expect(response.redirects, isA<List<RedirectInfo>>());

      client.close();
    });

    test('should test persistentConnection property returns false', () async {
      Joker.start();

      Joker.stubText(
        host: 'api.test.com',
        path: '/persistent-test',
        text: 'persistent test',
      );

      final client = HttpClient();
      final request = await client.getUrl(
        Uri.parse('https://api.test.com/persistent-test'),
      );
      final response = await request.close();

      expect(response.persistentConnection, isFalse);

      client.close();
    });

    test('should test connectionInfo property returns null', () async {
      Joker.start();

      Joker.stubText(
        host: 'api.test.com',
        path: '/connection-test',
        text: 'connection test',
      );

      final client = HttpClient();
      final request = await client.getUrl(
        Uri.parse('https://api.test.com/connection-test'),
      );
      final response = await request.close();

      expect(response.connectionInfo, isNull);

      client.close();
    });

    test('should test certificate property returns null', () async {
      Joker.start();

      Joker.stubText(
        host: 'api.test.com',
        path: '/certificate-test',
        text: 'certificate test',
      );

      final client = HttpClient();
      final request = await client.getUrl(
        Uri.parse('https://api.test.com/certificate-test'),
      );
      final response = await request.close();

      expect(response.certificate, isNull);

      client.close();
    });

    test('should test noSuchMethod with method invocations', () async {
      Joker.start();

      Joker.stubText(
        host: 'api.test.com',
        path: '/method-test',
        text: 'method test',
      );

      final client = HttpClient();
      final request = await client.getUrl(
        Uri.parse('https://api.test.com/method-test'),
      );
      final response = await request.close();

      // Test method invocation throws UnsupportedError
      expect(
        () => (response as dynamic).unknownMethod('arg1', 'arg2'),
        throwsA(isA<UnsupportedError>()),
      );

      // Test that the error message is descriptive
      try {
        (response as dynamic).someMethodName();
        fail('Expected UnsupportedError');
      } catch (e) {
        expect(e, isA<UnsupportedError>());
        expect(e.toString(), contains('not supported in test mode'));
      }

      client.close();
    });
  });
}

// Tests for HttpClientRequest and HttpClientResponse coverage
import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:test/test.dart';
import 'package:joker/joker.dart';
import 'package:joker/src/joker_response.dart';

void main() {
  group('HttpClientRequest and HttpClientResponse Coverage', () {
    setUp(() {
      Joker.stop();
      Joker.clearStubs();
    });

    tearDown(() {
      Joker.stop();
      Joker.clearStubs();
    });

    test('should exercise request body methods', () async {
      Joker.start();

      // Setup a stub that can capture the request body
      Joker.stubUrl(
        host: 'api.test.com',
        path: '/body-test',
        method: 'POST',
        response: JokerResponse.json({'received': 'ok'}),
      );

      final client = HttpClient();
      final request = await client.postUrl(
        Uri.parse('https://api.test.com/body-test'),
      );

      // Test different ways to add data to the request body
      request.add([65, 66, 67]); // ABC
      request.write('Hello ');
      request.writeAll(['World', '!'], ' ');
      request.writeCharCode(32); // Space
      request.writeln('New line');

      // Test addStream
      final stream = Stream.fromIterable([
        [68, 69, 70],
      ]); // DEF
      await request.addStream(stream);

      // Test flush (should do nothing but not error)
      await request.flush();

      final response = await request.close();

      // Test that request completed successfully
      expect(response.statusCode, equals(200));

      client.close();
    });

    test('should exercise request properties and headers', () async {
      Joker.start();

      Joker.stubUrl(
        host: 'api.test.com',
        path: '/headers-test',
        method: 'PUT',
        response: JokerResponse(statusCode: 204),
      );

      final client = HttpClient();
      final request = await client.putUrl(
        Uri.parse('https://api.test.com/headers-test'),
      );

      // Test request properties
      expect(request.method, equals('PUT'));
      expect(
        request.uri.toString(),
        equals('https://api.test.com/headers-test'),
      );
      expect(request.headers, isNotNull);

      // Test headers manipulation
      request.headers.add('custom-header', 'custom-value');
      request.headers.set('content-type', 'application/json');

      // Test done property (should be the same as close())
      final doneFuture = request.done;
      final closeFuture = request.close();

      final doneResponse = await doneFuture;
      final closeResponse = await closeFuture;

      expect(doneResponse.statusCode, equals(closeResponse.statusCode));

      client.close();
    });

    test('should handle write methods with various input types', () async {
      Joker.start();

      Joker.stubUrl(
        host: 'api.test.com',
        path: '/write-test',
        method: 'POST',
        response: JokerResponse.json({'status': 'received'}),
      );

      final client = HttpClient();
      final request = await client.postUrl(
        Uri.parse('https://api.test.com/write-test'),
      );

      // Test write with different object types
      request.write(null); // Should handle null gracefully
      request.write('String data');
      request.write(12345);
      request.write({'key': 'value'}); // Will be converted to string

      // Test writeAll with empty iterable
      request.writeAll([]);
      request.writeAll(['a', 'b', 'c']);
      request.writeAll(['x', 'y', 'z'], '-');

      // Test writeln variations
      request.writeln(); // Empty line
      request.writeln('Line with content');
      request.writeln(null); // Should handle null

      final response = await request.close();
      expect(response.statusCode, equals(200));

      client.close();
    });

    test('should exercise response properties and stream', () async {
      Joker.start();

      final responseHeaders = {
        'content-type': 'application/json',
        'x-custom': 'response-header',
      };

      Joker.stubUrl(
        host: 'api.test.com',
        path: '/response-test',
        method: 'GET',
        response: JokerResponse(
          statusCode: 201,
          headers: responseHeaders,
          body: '{"message": "success"}',
        ),
      );

      final client = HttpClient();
      final request = await client.getUrl(
        Uri.parse('https://api.test.com/response-test'),
      );
      final response = await request.close();

      // Test response properties
      expect(response.statusCode, equals(201));
      expect(response.headers, isNotNull);
      expect(
        response.headers.value('content-type'),
        equals('application/json'),
      );
      expect(response.headers.value('x-custom'), equals('response-header'));

      // Test response stream
      final bodyBytes = <int>[];
      await for (final chunk in response) {
        bodyBytes.addAll(chunk);
      }

      final bodyString = utf8.decode(bodyBytes);
      final bodyJson = json.decode(bodyString);
      expect(bodyJson['message'], equals('success'));

      client.close();
    });

    test('should test response with different body types', () async {
      Joker.start();

      // Test with Uint8List body
      final binaryData = Uint8List.fromList([1, 2, 3, 4, 5]);
      Joker.stubUrl(
        host: 'api.test.com',
        path: '/binary',
        response: JokerResponse(body: binaryData),
      );

      // Test with List<int> body
      Joker.stubUrl(
        host: 'api.test.com',
        path: '/list-int',
        response: JokerResponse(body: [65, 66, 67]), // ABC
      );

      // Test with null body
      Joker.stubUrl(
        host: 'api.test.com',
        path: '/null-body',
        response: JokerResponse(body: null),
      );

      final client = HttpClient();

      // Test binary response
      final binaryRequest = await client.getUrl(
        Uri.parse('https://api.test.com/binary'),
      );
      final binaryResponse = await binaryRequest.close();
      final binaryBytes = <int>[];
      await for (final chunk in binaryResponse) {
        binaryBytes.addAll(chunk);
      }
      expect(binaryBytes, equals([1, 2, 3, 4, 5]));

      // Test list int response
      final listRequest = await client.getUrl(
        Uri.parse('https://api.test.com/list-int'),
      );
      final listResponse = await listRequest.close();
      final listBytes = <int>[];
      await for (final chunk in listResponse) {
        listBytes.addAll(chunk);
      }
      expect(utf8.decode(listBytes), equals('ABC'));

      // Test null body response
      final nullRequest = await client.getUrl(
        Uri.parse('https://api.test.com/null-body'),
      );
      final nullResponse = await nullRequest.close();
      final nullBytes = <int>[];
      await for (final chunk in nullResponse) {
        nullBytes.addAll(chunk);
      }
      expect(nullBytes, equals([]));

      client.close();
    });

    test('should exercise noSuchMethod in request', () async {
      Joker.start();

      Joker.stubUrl(
        host: 'api.test.com',
        path: '/no-such-method',
        response: JokerResponse.json({'ok': true}),
      );

      final client = HttpClient();
      final request = await client.getUrl(
        Uri.parse('https://api.test.com/no-such-method'),
      );

      // Access properties that would trigger noSuchMethod
      expect(
        () => (request as dynamic).someNonExistentProperty,
        returnsNormally,
      );
      expect((request as dynamic).someNonExistentProperty, isNull);

      final response = await request.close();
      expect(response.statusCode, equals(200));

      client.close();
    });
  });
}

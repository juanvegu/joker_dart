// Tests to improve coverage of http_client classes
import 'dart:io';
import 'dart:convert';
import 'package:test/test.dart';
import 'package:joker/joker.dart';

void main() {
  group('HttpClient Coverage Tests', () {
    setUp(() {
      Joker.stop();
      Joker.clearStubs();
    });

    tearDown(() {
      Joker.stop();
      Joker.clearStubs();
    });

    test('should cover all HTTP client methods', () async {
      Joker.start();

      // Setup stubs for different methods
      Joker.stubJson(
        host: 'api.test.com',
        path: '/test',
        method: 'GET',
        data: {'method': 'GET'},
      );

      Joker.stubJson(
        host: 'api.test.com',
        path: '/test',
        method: 'POST',
        data: {'method': 'POST'},
      );

      Joker.stubJson(
        host: 'api.test.com',
        path: '/test',
        method: 'PUT',
        data: {'method': 'PUT'},
      );

      Joker.stubJson(
        host: 'api.test.com',
        path: '/test',
        method: 'DELETE',
        data: {'method': 'DELETE'},
      );

      Joker.stubJson(
        host: 'api.test.com',
        path: '/test',
        method: 'PATCH',
        data: {'method': 'PATCH'},
      );

      Joker.stubJson(
        host: 'api.test.com',
        path: '/test',
        method: 'HEAD',
        data: {'method': 'HEAD'},
      );

      final client = HttpClient();

      // Test all URL-based methods
      final getResponse = await client.getUrl(
        Uri.parse('https://api.test.com/test'),
      );
      final getRespData = await getResponse.close();
      expect(
        json.decode(await utf8.decoder.bind(getRespData).join())['method'],
        equals('GET'),
      );

      final postResponse = await client.postUrl(
        Uri.parse('https://api.test.com/test'),
      );
      final postRespData = await postResponse.close();
      expect(
        json.decode(await utf8.decoder.bind(postRespData).join())['method'],
        equals('POST'),
      );

      final putResponse = await client.putUrl(
        Uri.parse('https://api.test.com/test'),
      );
      final putRespData = await putResponse.close();
      expect(
        json.decode(await utf8.decoder.bind(putRespData).join())['method'],
        equals('PUT'),
      );

      final deleteResponse = await client.deleteUrl(
        Uri.parse('https://api.test.com/test'),
      );
      final deleteRespData = await deleteResponse.close();
      expect(
        json.decode(await utf8.decoder.bind(deleteRespData).join())['method'],
        equals('DELETE'),
      );

      final patchResponse = await client.patchUrl(
        Uri.parse('https://api.test.com/test'),
      );
      final patchRespData = await patchResponse.close();
      expect(
        json.decode(await utf8.decoder.bind(patchRespData).join())['method'],
        equals('PATCH'),
      );

      final headResponse = await client.headUrl(
        Uri.parse('https://api.test.com/test'),
      );
      final headRespData = await headResponse.close();
      expect(
        json.decode(await utf8.decoder.bind(headRespData).join())['method'],
        equals('HEAD'),
      );

      client.close();
    });

    test('should cover host/port/path methods', () async {
      Joker.start();

      // Setup stubs for all HTTP methods since they'll all use the same URL pattern
      final methods = ['GET', 'POST', 'PUT', 'DELETE', 'PATCH', 'HEAD'];
      for (final method in methods) {
        Joker.stubJson(
          host: 'localhost',
          path: '/api/test',
          method: method,
          data: {'source': 'host-port-path', 'method': method},
        );
      }

      final client = HttpClient();

      // Test host/port/path methods
      final getRequest = await client.get('localhost', 80, '/api/test');
      final getResponse = await getRequest.close();
      final getBody = await utf8.decoder.bind(getResponse).join();
      expect(json.decode(getBody)['source'], equals('host-port-path'));

      final postRequest = await client.post('localhost', 80, '/api/test');
      await postRequest.close();

      final putRequest = await client.put('localhost', 80, '/api/test');
      await putRequest.close();

      final deleteRequest = await client.delete('localhost', 80, '/api/test');
      await deleteRequest.close();

      final patchRequest = await client.patch('localhost', 80, '/api/test');
      await patchRequest.close();

      final headRequest = await client.head('localhost', 80, '/api/test');
      await headRequest.close();

      client.close();
    });

    test('should test close method and unsupported operations', () {
      Joker.start();

      final client = HttpClient();

      // Test close method - should not throw
      expect(() => client.close(), returnsNormally);
      expect(() => client.close(force: true), returnsNormally);

      // Test unsupported operations that should throw
      expect(() => client.connectionTimeout, throwsUnsupportedError);
      expect(
        () => client.connectionTimeout = Duration(seconds: 5),
        throwsUnsupportedError,
      );
    });

    test('should exercise URI construction in open method', () async {
      Joker.start();

      Joker.stubJson(
        host: 'example.com',
        path: '/api/data',
        method: 'GET',
        data: {'uri': 'constructed'},
      );

      final client = HttpClient();

      // This will exercise the URI construction in the open method
      final request = await client.get('example.com', 443, '/api/data');
      final response = await request.close();
      final body = await utf8.decoder.bind(response).join();

      expect(json.decode(body)['uri'], equals('constructed'));

      client.close();
    });
  });
}

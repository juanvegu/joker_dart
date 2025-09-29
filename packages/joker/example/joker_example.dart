import 'dart:io';
import 'package:joker/joker.dart';

/// Example demonstrating Joker HTTP request stubbing
Future<void> main() async {
  print('🃏 Joker HTTP Stubbing Example');
  print('================================\n');

  // Start Joker to intercept HTTP requests
  Joker.start();

  try {
    await basicJsonStubbing();
    await multipleEndpoints();
    await namedStubs();
    await oneTimeStubs();
    await customResponses();
  } finally {
    // Always stop Joker to restore normal HTTP behavior
    Joker.stop();
  }
}

/// Example 1: Basic JSON response stubbing
Future<void> basicJsonStubbing() async {
  print('📋 Example 1: Basic JSON Stubbing');
  print('----------------------------------');

  // Stub a simple GET request
  Joker.stubJson(
    host: 'api.example.com',
    path: '/user',
    data: {'id': 123, 'name': 'John Doe'},
  );

  final response = await _makeRequest('https://api.example.com/user');
  print('Status: ${response.statusCode}');
  print('✅ Basic stubbing works!\n');
}

/// Example 2: Multiple endpoints
Future<void> multipleEndpoints() async {
  print('🔀 Example 2: Multiple Endpoints');
  print('---------------------------------');

  Joker.clearStubs();

  // Stub different endpoints
  Joker.stubJson(
    host: 'api.example.com',
    path: '/users',
    data: {
      'users': ['Alice', 'Bob'],
    },
  );

  Joker.stubJson(
    host: 'api.example.com',
    path: '/posts',
    data: {
      'posts': ['Post 1', 'Post 2'],
    },
  );

  await _makeRequest('https://api.example.com/users');
  await _makeRequest('https://api.example.com/posts');
  print('✅ Multiple endpoints work!\n');
}

/// Example 3: Named stubs for easy management
Future<void> namedStubs() async {
  print('🏷️  Example 3: Named Stubs');
  print('---------------------------');

  Joker.clearStubs();

  // Create named stubs
  Joker.stubJson(
    host: 'api.example.com',
    path: '/config',
    name: 'config-stub',
    data: {'env': 'test'},
  );

  await _makeRequest('https://api.example.com/config');

  // Remove specific stub by name
  final removed = Joker.removeStubsByName('config-stub');
  print('Removed $removed stub(s)');
  print('✅ Named stubs work!\n');
}

/// Example 4: One-time stubs
Future<void> oneTimeStubs() async {
  print('🔂 Example 4: One-time Stubs');
  print('-----------------------------');

  Joker.clearStubs();

  // Create a one-time stub
  Joker.stubJson(
    host: 'api.example.com',
    path: '/token',
    removeAfterUse: true,
    data: {'token': 'abc123'},
  );

  // Add fallback stub
  Joker.stubJson(
    host: 'api.example.com',
    path: '/token',
    statusCode: 401,
    data: {'error': 'No token'},
  );

  // First request gets token, second gets error
  final firstResponse = await _makeRequest('https://api.example.com/token');
  final secondResponse = await _makeRequest('https://api.example.com/token');

  print(
    'First: ${firstResponse.statusCode}, Second: ${secondResponse.statusCode}',
  );
  print('✅ One-time stubs work!\n');
}

/// Example 5: Custom responses
Future<void> customResponses() async {
  print('⚙️  Example 5: Custom Responses');
  print('--------------------------------');

  Joker.clearStubs();

  // Stub with custom headers and delay
  Joker.stubJson(
    host: 'api.example.com',
    path: '/slow',
    data: {'message': 'Delayed response'},
    delay: Duration(milliseconds: 100),
    headers: {'X-Custom': 'Joker'},
  );

  final stopwatch = Stopwatch()..start();
  final response = await _makeRequest('https://api.example.com/slow');
  stopwatch.stop();

  print('Response time: ${stopwatch.elapsedMilliseconds}ms');
  print('Custom header: ${response.headers.value('X-Custom')}');
  print('✅ Custom responses work!\n');
}

/// Helper method to make HTTP requests
Future<HttpClientResponse> _makeRequest(String url) async {
  final client = HttpClient();
  try {
    final request = await client.getUrl(Uri.parse(url));
    return await request.close();
  } finally {
    client.close();
  }
}

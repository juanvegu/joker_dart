import 'package:joker_http/joker_http.dart';
import 'package:http/http.dart' as http;

/// Example demonstrating Joker with HTTP package client
Future<void> main() async {
  print('🃏 Joker HTTP Integration Example');
  print('==================================\n');

  // Start Joker to intercept HTTP requests
  Joker.start();

  // Create HTTP client with Joker integration
  final client = createHttpClient();

  try {
    await basicJsonStubbing(client);
    await multipleEndpoints(client);
    await namedStubs(client);
    await oneTimeStubs(client);
    await customResponses(client);
  } finally {
    // Always stop Joker to restore normal HTTP behavior
    Joker.stop();
    client.close();
  }
}

/// Example 1: Basic JSON response stubbing
Future<void> basicJsonStubbing(http.Client client) async {
  print('📋 Example 1: Basic JSON Stubbing');
  print('----------------------------------');

  // Stub a simple GET request
  Joker.stubJson(
    host: 'api.example.com',
    path: '/user',
    data: {'id': 123, 'name': 'John Doe'},
  );

  final response = await client.get(Uri.parse('https://api.example.com/user'));
  print('Status: ${response.statusCode}');
  print('Body: ${response.body}');
  print('✅ Basic stubbing works!\n');
}

/// Example 2: Multiple endpoints
Future<void> multipleEndpoints(http.Client client) async {
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

  final usersResponse = await client.get(
    Uri.parse('https://api.example.com/users'),
  );
  final postsResponse = await client.get(
    Uri.parse('https://api.example.com/posts'),
  );
  print('Users: ${usersResponse.body}');
  print('Posts: ${postsResponse.body}');
  print('✅ Multiple endpoints work!\n');
}

/// Example 3: Named stubs for easy management
Future<void> namedStubs(http.Client client) async {
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

  final response = await client.get(
    Uri.parse('https://api.example.com/config'),
  );
  print('Config: ${response.body}');

  // Remove specific stub by name
  final removed = Joker.removeStubsByName('config-stub');
  print('Removed $removed stub(s)');
  print('✅ Named stubs work!\n');
}

/// Example 4: One-time stubs
Future<void> oneTimeStubs(http.Client client) async {
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
  final firstResponse = await client.get(
    Uri.parse('https://api.example.com/token'),
  );
  final secondResponse = await client.get(
    Uri.parse('https://api.example.com/token'),
  );

  print('First: ${firstResponse.statusCode} - ${firstResponse.body}');
  print('Second: ${secondResponse.statusCode} - ${secondResponse.body}');
  print('✅ One-time stubs work!\n');
}

/// Example 5: Custom responses
Future<void> customResponses(http.Client client) async {
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
  final response = await client.get(Uri.parse('https://api.example.com/slow'));
  stopwatch.stop();

  print('Response time: ${stopwatch.elapsedMilliseconds}ms');
  print('Custom header: ${response.headers['x-custom']}');
  print('Body: ${response.body}');
  print('✅ Custom responses work!\n');
}

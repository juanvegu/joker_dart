import 'package:joker_dio/joker_dio.dart';
import 'package:dio/dio.dart';

/// Example demonstrating Joker with Dio HTTP client
Future<void> main() async {
  print('🃏 Joker Dio Integration Example');
  print('=================================\n');

  // Start Joker to intercept HTTP requests
  Joker.start();

  // Create Dio instance with Joker interceptor
  final dio = Dio(BaseOptions(baseUrl: 'https://api.example.com'));
  dio.interceptors.add(JokerDioInterceptor());

  try {
    await basicJsonStubbing(dio);
    await multipleEndpoints(dio);
    await namedStubs(dio);
    await oneTimeStubs(dio);
    await customResponses(dio);
  } finally {
    // Always stop Joker to restore normal HTTP behavior
    Joker.stop();
    dio.close();
  }
}

/// Example 1: Basic JSON response stubbing
Future<void> basicJsonStubbing(Dio dio) async {
  print('📋 Example 1: Basic JSON Stubbing');
  print('----------------------------------');

  // Stub a simple GET request
  Joker.stubJson(
    host: 'api.example.com',
    path: '/user',
    data: {'id': 123, 'name': 'John Doe'},
  );

  final response = await dio.get('/user');
  print('Status: ${response.statusCode}');
  print('Data: ${response.data}');
  print('✅ Basic stubbing works!\n');
}

/// Example 2: Multiple endpoints
Future<void> multipleEndpoints(Dio dio) async {
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

  final usersResponse = await dio.get('/users');
  final postsResponse = await dio.get('/posts');
  print('Users: ${usersResponse.data}');
  print('Posts: ${postsResponse.data}');
  print('✅ Multiple endpoints work!\n');
}

/// Example 3: Named stubs for easy management
Future<void> namedStubs(Dio dio) async {
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

  final response = await dio.get('/config');
  print('Config: ${response.data}');

  // Remove specific stub by name
  final removed = Joker.removeStubsByName('config-stub');
  print('Removed $removed stub(s)');
  print('✅ Named stubs work!\n');
}

/// Example 4: One-time stubs
Future<void> oneTimeStubs(Dio dio) async {
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
  final firstResponse = await dio.get('/token');
  final secondResponse = await dio.get('/token');

  print('First: ${firstResponse.statusCode} - ${firstResponse.data}');
  print('Second: ${secondResponse.statusCode} - ${secondResponse.data}');
  print('✅ One-time stubs work!\n');
}

/// Example 5: Custom responses
Future<void> customResponses(Dio dio) async {
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
  final response = await dio.get('/slow');
  stopwatch.stop();

  print('Response time: ${stopwatch.elapsedMilliseconds}ms');
  print('Custom header: ${response.headers.value('X-Custom')}');
  print('Data: ${response.data}');
  print('✅ Custom responses work!\n');
}

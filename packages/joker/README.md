# Joker 🃏

![Joker Banner](https://raw.githubusercontent.com/juanvegu/joker_dart/main/assets/joker_banner.png)

A powerful HTTP request stubbing and mocking library for Dart. Joker allows you to intercept HTTP requests made by any Dart library that uses the standard `HttpClient` and `HttpOverrides` classes, including popular packages like `dio` and `http`.

[![Pub Version](https://img.shields.io/pub/v/joker)](https://pub.dev/packages/joker)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## Features

- 🎯 **Universal HTTP Interception**: Works with any Dart HTTP library that uses `HttpClient`
- 🔧 **Flexible URL Matching**: Match requests by host, path, and HTTP method
- 📄 **JSON Response Stubbing**: Built-in support for JSON responses
- ⚡ **Custom Responses**: Full control over status codes, headers, and response bodies
- 🔄 **One-time Stubs**: Automatically remove stubs after use
- 📛 **Named Stubs**: Organize and manage stubs with custom names
- ⏱️ **Response Delays**: Simulate network latency with custom delays
- 🧪 **Test-Friendly**: Perfect for unit and integration tests

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  joker: ^0.1.0-dev.1
```

For testing only:

```yaml
dev_dependencies:
  joker: ^0.1.0-dev.1
```

Then run:

```bash
dart pub get
```

## Quick Start

```dart
import 'package:joker/joker.dart';
import 'dart:io';

Future<void> main() async {
  // Start intercepting HTTP requests
  Joker.start();

  // Stub a JSON response
  Joker.stubJson(
    host: 'api.example.com',
    path: '/users',
    data: {'users': [{'id': 1, 'name': 'John Doe'}]},
  );

  // Make an HTTP request - it will be intercepted
  final client = HttpClient();
  final request = await client.getUrl(Uri.parse('https://api.example.com/users'));
  final response = await request.close();
  
  // The response will contain the stubbed data
  print('Status: ${response.statusCode}'); // 200
  
  // Always stop intercepting when done
  Joker.stop();
}
```

## Usage Examples

### Basic JSON Stubbing

```dart
// Start Joker
Joker.start();

// Stub a simple GET request
Joker.stubJson(
  host: 'api.example.com',
  path: '/user',
  data: {'id': 123, 'name': 'John Doe'},
);

// The request will return the stubbed data
final response = await http.get(Uri.parse('https://api.example.com/user'));
```

### Multiple Endpoints

```dart
Joker.start();

// Stub multiple endpoints
Joker.stubJson(
  host: 'api.example.com',
  path: '/users',
  data: {'users': []},
);

Joker.stubJson(
  host: 'api.example.com',
  path: '/posts',
  data: {'posts': []},
);
```

### Custom Response Configuration

```dart
Joker.stubJson(
  host: 'api.example.com',
  path: '/users',
  method: 'POST',
  data: {'id': 1, 'created': true},
  statusCode: 201,
  headers: {'X-Custom-Header': 'value'},
  delay: Duration(milliseconds: 500), // Simulate network delay
);
```

### Named Stubs for Organization

```dart
// Create named stubs for better management
Joker.stubJson(
  host: 'api.example.com',
  path: '/users',
  data: {'users': []},
  name: 'empty-users',
);

// Later, remove stubs by name
Joker.removeStubsByName('empty-users');
```

### One-time Stubs

```dart
// Stub that automatically removes itself after first use
Joker.stubJson(
  host: 'api.example.com',
  path: '/auth',
  data: {'token': 'abc123'},
  removeAfterUse: true,
);

// First request gets the stubbed response
await http.get(Uri.parse('https://api.example.com/auth'));

// Second request will not be intercepted (stub was removed)
await http.get(Uri.parse('https://api.example.com/auth'));
```

### Advanced Custom Responses

```dart
import 'package:joker/joker.dart';

// Create a custom response with full control
final customResponse = JokerResponse(
  statusCode: 404,
  headers: {'Content-Type': 'application/json'},
  body: '{"error": "Not found"}',
  delay: Duration(seconds: 1),
);

Joker.stubUrl(
  host: 'api.example.com',
  path: '/missing',
  response: customResponse,
);
```

## API Reference

### Core Methods

#### `Joker.start()`

Starts intercepting HTTP requests. Must be called before any stubbing takes effect.

#### `Joker.stop()`

Stops intercepting HTTP requests and clears all stubs. Restores normal HTTP behavior.

#### `Joker.stubJson({...})`

Creates and registers a stub for JSON responses.

**Parameters:**

- `host` (String?): The host to match (e.g., 'api.example.com')
- `path` (String?): The path to match (e.g., '/users')
- `method` (String?): HTTP method to match (e.g., 'GET', 'POST')
- `data` (Map<String, dynamic>): The JSON data to return
- `statusCode` (int): HTTP status code (default: 200)
- `headers` (Map<String, String>): Additional headers
- `delay` (Duration?): Artificial delay before responding
- `name` (String?): Optional name for the stub
- `removeAfterUse` (bool): Remove stub after first match (default: false)

#### `Joker.stubUrl({...})`

Creates and registers a stub with a custom response.

**Parameters:**

- `host`, `path`, `method`: URL matching criteria
- `response` (JokerResponse): Custom response object
- `name` (String?): Optional name for the stub
- `removeAfterUse` (bool): Remove stub after first match

### Stub Management

#### `Joker.clearStubs()`

Removes all registered stubs.

#### `Joker.removeStub(JokerStub stub)`

Removes a specific stub. Returns `true` if removed.

#### `Joker.removeStubsByName(String name)`

Removes all stubs with the given name. Returns the number of removed stubs.

### Response Types

#### `JokerResponse`

Represents a response that will be returned for matched requests.

```dart
// Basic response
JokerResponse(
  statusCode: 200,
  headers: {'Content-Type': 'text/plain'},
  body: 'Hello World',
  delay: Duration(milliseconds: 100),
)

// JSON response (convenience factory)
JokerResponse.json(
  {'message': 'Hello'},
  statusCode: 200,
  headers: {'X-Custom': 'value'},
  delay: Duration(milliseconds: 100),
)
```

## Testing Integration

Joker is perfect for testing scenarios where you need to mock HTTP responses:

```dart
import 'package:test/test.dart';
import 'package:joker/joker.dart';

void main() {
  group('API Tests', () {
    setUp(() {
      Joker.start();
    });

    tearDown(() {
      Joker.stop();
      Joker.clearStubs();
    });

    test('should handle successful user fetch', () async {
      // Arrange
      Joker.stubJson(
        host: 'api.example.com',
        path: '/user/123',
        data: {'id': 123, 'name': 'Test User'},
      );

      // Act
      final user = await fetchUser(123);

      // Assert
      expect(user.id, equals(123));
      expect(user.name, equals('Test User'));
    });

    test('should handle API errors', () async {
      // Arrange
      Joker.stubUrl(
        host: 'api.example.com',
        path: '/user/999',
        response: JokerResponse(
          statusCode: 404,
          body: '{"error": "User not found"}',
        ),
      );

      // Act & Assert
      expect(() => fetchUser(999), throwsA(isA<UserNotFoundException>()));
    });
  });
}
```

## URL Matching

Joker uses flexible URL matching:

- **Host matching**: Exact string match against the request host
- **Path matching**: Exact string match against the request path
- **Method matching**: Case-insensitive HTTP method matching
- **Partial matching**: You can specify only the parameters you want to match

```dart
// Match any request to api.example.com
Joker.stubJson(host: 'api.example.com', data: {'default': true});

// Match only GET requests to /users
Joker.stubJson(path: '/users', method: 'GET', data: {'users': []});

// Match specific host and path combination
Joker.stubJson(
  host: 'api.example.com',
  path: '/posts/123',
  data: {'id': 123, 'title': 'Test Post'},
);
```

## Best Practices

1. **Always call `Joker.stop()`**: Use try-finally blocks or tearDown methods to ensure normal HTTP behavior is restored.

2. **Use named stubs for complex scenarios**: Named stubs make it easier to manage and remove specific stubs.

3. **Clear stubs between tests**: Use `Joker.clearStubs()` in tearDown to ensure test isolation.

4. **Leverage one-time stubs**: Use `removeAfterUse: true` for scenarios where a stub should only match once.

5. **Simulate realistic delays**: Add delays to test timeout handling and loading states.

```dart
// Good practice example
void main() {
  group('API Tests', () {
    setUp(() => Joker.start());
    
    tearDown(() {
      Joker.stop();
      Joker.clearStubs();
    });

    // Your tests here...
  });
}
```

## Limitations

- Only works with HTTP clients that respect `HttpOverrides.global`
- URL matching is exact string matching (no regex or wildcards yet)
- Cannot intercept HTTPS certificate validation

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

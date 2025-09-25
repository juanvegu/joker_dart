# Joker 🃏

![Joker Banner](https://raw.githubusercontent.com/juanvegu/joker_dart/main/assets/joker_banner.png)

[![Pub Version](https://img.shields.io/pub/v/joker)](https://pub.dev/packages/joker)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

HTTP request mocking for Dart & Flutter. **Beyond testing** - enable independent frontend development without backend dependencies.

## Use Cases

### 🚀 Independent Development

Build complete features before backend APIs exist:

```dart
void main() async {
  if (kDebugMode) {
    setupMockAPIs(); // Only in development
  }
  runApp(MyApp());
}

void setupMockAPIs() {
  Joker.start();
  
  // User authentication
  Joker.stubJson(
    host: 'api.myapp.com',
    path: '/auth/login',
    method: 'POST',
    data: {
      'token': 'dev_token_123',
      'user': {'id': 1, 'name': 'Dev User'}
    },
  );
  
  // Product catalog
  Joker.stubJson(
    host: 'api.myapp.com', 
    path: '/products',
    data: {
      'products': [
        {'id': 1, 'name': 'iPhone 15', 'price': 999},
        {'id': 2, 'name': 'MacBook Pro', 'price': 1999},
      ]
    },
  );
}
```

### 🧪 Testing Excellence

Reliable, fast tests with controlled responses:

```dart
group('User Profile Tests', () {
  setUp(() => Joker.start());
  tearDown(() => Joker.stop());

  test('loads user profile successfully', () async {
    Joker.stubJson(
      host: 'api.myapp.com',
      path: '/users/123',
      data: {'id': 123, 'name': 'John Doe', 'email': 'john@example.com'},
    );

    final profile = await userService.getProfile(123);
    expect(profile.name, equals('John Doe'));
  });

  test('handles network errors gracefully', () async {
    Joker.stubJson(
      host: 'api.myapp.com',
      path: '/users/456', 
      data: {'error': 'User not found'},
      statusCode: 404,
    );

    expect(
      () => userService.getProfile(456), 
      throwsA(isA<UserNotFound>())
    );
  });
});
```

## Key Features

- ✅ **Universal**: Works with any HTTP client using `HttpClient` (`http`, `dio`, etc.)
- 🎯 **Smart Matching**: Match by host, path, method, or any combination
- 📦 **JSON-First**: Built-in JSON response handling
- ⚡ **Full Control**: Custom status codes, headers, delays
- 🏷️ **Organized**: Named stubs for complex scenarios
- 🔄 **Flexible**: One-time or persistent stubs
- 🚫 **Non-Invasive**: No changes needed to existing code

## Installation

Add to your `pubspec.yaml`:

### ✅ Native Platforms (Mobile & Desktop) - Available Now

```yaml
dev_dependencies:
  joker: ^0.1.0-dev.2
```

### 🚧 Web Platform - Coming Soon

Web adapters are currently in development:

```yaml
dev_dependencies:
  joker: ^0.1.0-dev.2
  joker_http: ^0.0.1  # If using package:http (coming soon)
  # OR
  joker_dio: ^0.0.1   # If using package:dio (coming soon)
```

> **Note**: Web support is planned for a future release. Currently, Joker works on mobile and desktop platforms only.
> **Tip**: Run `dart pub deps` to see the exact versions being used.

## Quick Start

```dart
import 'package:joker/joker.dart';

// Start intercepting (required)
Joker.start();

// Simple JSON response
Joker.stubJson(
  host: 'api.example.com',
  path: '/users',
  data: {'users': [{'id': 1, 'name': 'Alice'}]},
);

// Your existing code works unchanged!
final response = await http.get(Uri.parse('https://api.example.com/users'));
final users = jsonDecode(response.body)['users'];

// Always stop when done
Joker.stop();
```

## API Guide

### Basic Stubbing

```dart
// Start intercepting
Joker.start();

// Stub a GET request
Joker.stubJson(
  host: 'api.example.com',
  path: '/posts',
  data: {'posts': [{'id': 1, 'title': 'Hello World'}]},
);

// Make request - it will be intercepted
final posts = await apiClient.getPosts();
```

### Advanced Configuration

```dart
// POST endpoint with custom response
Joker.stubJson(
  host: 'api.example.com',
  path: '/users',
  method: 'POST',
  data: {'id': 42, 'created': true},
  statusCode: 201,
  headers: {'Location': '/users/42'},
  delay: Duration(milliseconds: 300), // Simulate network latency
);

// Error responses for testing
Joker.stubJson(
  host: 'api.example.com',
  path: '/users/invalid',
  data: {'error': 'Invalid user ID', 'code': 'INVALID_ID'},
  statusCode: 400,
);
```

### Stub Management

```dart
// Named stubs for organization
Joker.stubJson(
  host: 'api.example.com',
  path: '/products',
  data: {'products': []},
  name: 'empty-catalog',
);

// Update stub data dynamically
Joker.removeStubsByName('empty-catalog');
Joker.stubJson(
  host: 'api.example.com', 
  path: '/products',
  data: {'products': [{'id': 1, 'name': 'New Product'}]},
  name: 'populated-catalog',
);

// One-time stubs (auto-remove after use)
Joker.stubJson(
  host: 'api.example.com',
  path: '/auth/refresh',
  data: {'token': 'new_token_456'},
  removeAfterUse: true,
);
```

### Real-World Development Example

```dart
class ApiMockService {
  static void setupDevelopmentMocks() {
    Joker.start();
    
    _setupAuthEndpoints();
    _setupUserEndpoints(); 
    _setupProductEndpoints();
  }
  
  static void _setupAuthEndpoints() {
    // Login success
    Joker.stubJson(
      host: 'api.myshop.com',
      path: '/auth/login',
      method: 'POST', 
      data: {
        'success': true,
        'token': 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...',
        'user': {
          'id': 1, 
          'email': 'dev@example.com', 
          'role': 'admin'
        }
      },
      name: 'login-success',
    );
  }
  
  static void _setupProductEndpoints() {
    // Product list with pagination
    Joker.stubJson(
      host: 'api.myshop.com',
      path: '/products',
      data: {
        'products': List.generate(20, (i) => {
          'id': i + 1,
          'name': 'Product ${i + 1}',
          'price': (i + 1) * 10.99,
          'image': 'https://picsum.photos/200/200?random=$i'
        }),
        'total': 100,
        'page': 1,
        'hasMore': true,
      },
      delay: Duration(milliseconds: 500), // Realistic loading time
    );
  }
}
```

## Core Methods

| Method | Purpose |
|--------|---------|
| `Joker.start()` | Begin intercepting HTTP requests |
| `Joker.stop()` | Stop intercepting and clear all stubs |
| `Joker.stubJson({...})` | Create a JSON response stub |
| `Joker.clearStubs()` | Remove all stubs |
| `Joker.removeStub(stub)` | Remove specific stub |
| `Joker.removeStubsByName(name)` | Remove stubs by name |

## `stubJson` Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `host` | `String?` | `null` | Host to match (e.g., 'api.example.com') |
| `path` | `String?` | `null` | Path to match (e.g., '/users') |
| `method` | `String?` | `null` | HTTP method ('GET', 'POST', etc.) |
| `data` | `Map<String, dynamic>` | required | JSON data to return |
| `statusCode` | `int` | `200` | HTTP status code |
| `headers` | `Map<String, String>?` | `null` | Response headers |
| `delay` | `Duration?` | `null` | Artificial delay |
| `name` | `String?` | `null` | Stub name for management |
| `removeAfterUse` | `bool` | `false` | Auto-remove after first match |

## Best Practices

### Development Workflow

- Use `kDebugMode` to enable mocks only in development
- Create realistic mock data that matches your backend schema
- Add delays to test loading states and user experience
- Use named stubs to swap between different scenarios

### Testing

- Always call `Joker.stop()` in `tearDown()` methods
- Clear stubs between tests with `Joker.clearStubs()`
- Test both success and error scenarios
- Use `removeAfterUse: true` for one-time authentication flows

### Organization

```dart
// Good: Organized by feature
void setupUserMocks() {
  // user-related stubs
}

void setupProductMocks() {
  // product-related stubs
}

void setupPaymentMocks() {
  // payment-related stubs
}

// Good: Environment-specific setup
void setupMocksForTesting() {
  // minimal, predictable data
}

void setupMocksForDemo() {
  // rich, realistic data
}
```

## How It Works

### On Native Platforms (Mobile & Desktop)

Joker uses Dart's `HttpOverrides.global` to intercept all HTTP requests made through `HttpClient`. This works transparently with any package that uses the standard Dart HTTP stack:

- `package:http`
- `package:dio`
- `dart:io` HttpClient
- Most other HTTP packages

No changes to your existing code required - just start Joker and define your stubs!

### On Web Platform (Coming Soon)

On web, `HttpOverrides` doesn't work because browsers handle HTTP requests differently. That's why we're developing specific adapters:

- `joker_http` - Will intercept requests made through `package:http` (in development)
- `joker_dio` - Will intercept requests made through `package:dio` (in development)

These adapters will integrate seamlessly with each HTTP client's architecture to provide the same mocking experience across all platforms.

## License

MIT Licensed - see [LICENSE](LICENSE) for details.

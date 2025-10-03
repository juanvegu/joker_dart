# Joker 🃏

![Joker Banner](https://raw.githubusercontent.com/juanvegu/joker_dart/main/assets/joker_banner.png)

[![ci](https://github.com/juanvegu/joker_dart/actions/workflows/ci.yaml/badge.svg)](https://github.com/juanvegu/joker_dart/actions/workflows/ci.yaml)
[![license](https://img.shields.io/badge/license-MIT-blue.svg)](https://opensource.org/licenses/MIT)

**Develop faster, test smarter.** HTTP mocking that empowers both independent frontend development and reliable testing.

## Why Joker?

🚀 **Accelerate Development** - Build frontend features before backend APIs are ready  
🧪 **Reliable Testing** - Consistent, controlled API responses for all test scenarios  
🎯 **Zero Configuration** - Intercepts any HTTP client using Dart's `HttpClient`  
📱 **Cross-Platform** - Works seamlessly on mobile, desktop, and web  

## Quick Example

```dart
import 'package:joker/joker.dart';

// Start intercepting HTTP requests
Joker.start();

// Define API responses  
Joker.stubJson(
  host: 'api.myapp.com',
  path: '/users/me',
  data: {'id': 1, 'name': 'John', 'role': 'developer'},
);

// Your app works without a backend!
final user = await apiClient.getCurrentUser();
print(user.name); // "John"

// Clean up
Joker.stop();
```

## Use Cases

### 🚀 Independent Development

- Build complete features without backend dependencies
- Work offline or with unreliable connections  
- Create demos and prototypes with realistic data
- Onboard new developers faster

### 🧪 Testing Excellence

- Unit tests with predictable responses
- Integration tests without external dependencies
- Error scenario testing (404s, timeouts, etc.)
- Performance testing with controlled delays

## 📦 Packages

| Package | Pub.dev | Status | Description |
|---------|---------|--------|-------------|
| **[joker](packages/joker)** | [![pub](https://img.shields.io/pub/v/joker.svg)](https://pub.dev/packages/joker) | ✅ Available | Core library - works on native platforms |
| **[joker_http](packages/joker_http)** | ✅ Available  | ✅ Ready | HTTP client adapter for all platform |
| **[joker_dio](packages/joker_dio)** | ✅ Available | ✅ Ready | Dio interceptor for all platform |

## Getting Started

Choose based on your platform and HTTP client:

### Native Platforms (Mobile, Desktop, Server)

**Any HTTP client** → Use `joker` only ⭐ **Recommended**

> **💡 Important**: While `joker_dio` and `joker_http` work on all platforms including native, we **strongly recommend using `joker` directly** for native-only development. It provides automatic interception with zero configuration and better performance.

Joker uses `HttpOverrides` to automatically intercept all HTTP requests made through Dart's `HttpClient`. This works transparently with popular packages like `http`, `dio`, etc.

```dart
import 'package:joker/joker.dart';
import 'package:http/http.dart' as http;

Joker.start();
Joker.stubJson(
  host: 'api.example.com',
  path: '/users',
  data: {'users': []},
);

// Works automatically - no client configuration needed
final response = await http.get(Uri.parse('https://api.example.com/users'));
```

### Web Platform

Web requires explicit HTTP client configuration since `HttpOverrides` doesn't work in browsers.

The recommended approach is **Dependency Injection with a single import**:

#### Using `package:http`

```dart
// Single import - re-exports joker + adds createHttpClient()
import 'package:joker_http/joker_http.dart';
import 'package:http/http.dart' as http;

// 1. Define service with injected client
class ApiService {
  final http.Client client;
  ApiService(this.client);
  
  Future<User> getUser(int id) async {
    final response = await client.get(
      Uri.parse('https://api.example.com/users/$id'),
    );
    return User.fromJson(jsonDecode(response.body));
  }
}

// 2. Setup in main.dart
void main() {
  if (kDebugMode) {
    Joker.start(); // From joker (re-exported)
    Joker.stubJson(
      host: 'api.example.com',
      path: '/users/1',
      data: {'id': 1, 'name': 'Dev User'},
    );
  }
  
  // Create and inject the client
  final httpClient = createHttpClient(); // From joker_http
  final apiService = ApiService(httpClient);
  
  runApp(MyApp(apiService: apiService));
}
```

#### Using `package:dio`

```dart
// Single import - re-exports joker + adds JokerDioInterceptor
import 'package:joker_dio/joker_dio.dart';
import 'package:dio/dio.dart';

void main() {
  if (kDebugMode) {
    Joker.start(); // From joker (re-exported)
    Joker.stubJson(
      host: 'api.example.com',
      path: '/users',
      data: {'users': []},
    );
  }

  // Just add the interceptor
  final dio = Dio();
  dio.interceptors.add(JokerDioInterceptor());
  
  runApp(MyApp());
}
```

> **💡 Tip**: Both `joker_http` and `joker_dio` re-export everything from `joker`, so you only need one import!

Check the individual package documentation for detailed setup instructions.

## Development

This monorepo uses [Melos](https://melos.invertase.dev) for package management.

```bash
# Setup workspace
dart pub global activate melos
melos bootstrap

# Run all tests
melos run test

# Run tests for specific package
melos run test --scope="joker"
```

## Contributing

We welcome contributions! Please:

1. Read our [contributing guide](CONTRIBUTING.md)
2. Check existing [issues](https://github.com/juanvegu/joker_dart/issues)
3. Open an issue before major changes
4. Follow our coding standards

## License

MIT Licensed - see [LICENSE](LICENSE) for details.

## Support the Project

If you find `joker` helpful for your projects and it has saved you time, consider supporting its development with a coffee!

Every contribution is highly appreciated and motivates me to keep improving the library, adding new features, and providing support.

<a href="https://www.buymeacoffee.com/juanvegu">
  <img src="https://cdn.buymeacoffee.com/buttons/v2/default-yellow.png" height="40">
</a>

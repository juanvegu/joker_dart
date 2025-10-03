# Joker HTTP

HTTP client factory for Joker that works on **all platforms including web**.

> **💡 For Native-Only Development**: If you're building exclusively for native platforms (mobile, desktop, server), we recommend using the [`joker`](https://pub.dev/packages/joker) package directly instead. It provides automatic interception with zero configuration via `HttpOverrides`.

## Why This Package?

On native platforms (mobile, desktop, server), Joker uses `HttpOverrides` to automatically intercept all HTTP requests. However, `HttpOverrides` doesn't work on web platforms.

`joker_http` provides a factory function that creates `http.Client` instances compatible with Joker on **all platforms**.

**Use this package when:**

- You need to support web platform alongside native platforms
- You're already using `package:http` and want consistent behavior across all platforms

## Installation

```yaml
dependencies:
  joker_http: ^0.0.1  # Includes joker as dependency
  http: ^1.0.0
```

> **Note**: You don't need to add `joker` separately - `joker_http` includes it and re-exports everything!

## Usage with Dependency Injection (Recommended)

> **💡 Best Practice**: Always use dependency injection with `joker_http`. This approach keeps your code clean, testable, and platform-agnostic. Your services never need to know about Joker - they just use standard `http.Client`.

**Single import** - `joker_http` re-exports everything from `joker`:

### 1. Define Your Service with Injected Client

```dart
import 'package:http/http.dart' as http;

class ApiService {
  final http.Client client;
  
  // Client is injected via constructor
  ApiService(this.client);
  
  Future<User> getUser(int id) async {
    final response = await client.get(
      Uri.parse('https://api.example.com/users/$id'),
    );
    
    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to load user');
  }
}
```

### 2. Setup in main.dart

```dart
// Single import - re-exports Joker + adds createHttpClient()
import 'package:joker_http/joker_http.dart';
import 'package:http/http.dart' as http;

void main() {
  // Setup mock data in debug mode
  if (kDebugMode) {
    Joker.start(); // From joker (re-exported)
    Joker.stubJson(
      host: 'api.example.com',
      path: '/users/1',
      data: {'id': 1, 'name': 'Dev User'},
    );
  }
  
  // Create the HTTP client (works on all platforms)
  final httpClient = createHttpClient(); // From joker_http
  
  // Inject into your services
  final apiService = ApiService(httpClient);
  
  runApp(MyApp(apiService: apiService));
}
```

## With Dependency Injection Packages

### Using get_it

```dart
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:joker_http/joker_http.dart'; // Re-exports Joker

final getIt = GetIt.instance;

void setupDependencies() {
  if (kDebugMode) {
    Joker.start();
    // Setup your stubs here...
  }
  
  // Register HTTP client
  getIt.registerSingleton<http.Client>(createHttpClient());
  
  // Register services with injected client
  getIt.registerSingleton<ApiService>(
    ApiService(getIt<http.Client>()),
  );
}
```

### Using provider

```dart
import 'package:provider/provider.dart';
import 'package:joker_http/joker_http.dart'; // Re-exports Joker

void main() {
  if (kDebugMode) {
    Joker.start();
    // Setup stubs...
  }
  
  runApp(
    MultiProvider(
      providers: [
        Provider<http.Client>(
          create: (_) => createHttpClient(),
          dispose: (_, client) => client.close(),
        ),
        ProxyProvider<http.Client, ApiService>(
          update: (_, client, __) => ApiService(client),
        ),
      ],
      child: MyApp(),
    ),
  );
}
```

## Why Dependency Injection?

**Dependency injection is the recommended approach** for using `joker_http`:

1. **Clean Architecture**: Your services use standard `http.Client` - no Joker-specific code
2. **Easy Testing**: Inject mock clients in tests without changing service code
3. **Platform Agnostic**: Same service code works on native and web
4. **Production Ready**: Just change the injected client in production (or use conditional logic)
5. **Maintainable**: Clear separation of concerns and easier refactoring

## Platform Behavior

- **Native** (mobile, desktop, server): `createHttpClient()` is optional since HttpOverrides works automatically, but using it provides consistency
- **Web**: `createHttpClient()` is required because HttpOverrides doesn't exist in browsers

For more examples and documentation, see the [main Joker README](https://github.com/juanvegu/joker_dart).

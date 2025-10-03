# Joker Dio

Dio interceptor for Joker that works on **all platforms including web**.

> **💡 For Native-Only Development**: If you're building exclusively for native platforms (mobile, desktop, server), we recommend using the [`joker`](https://pub.dev/packages/joker) package directly instead. It provides automatic interception with zero configuration via `HttpOverrides`.

## Why This Package?

On native platforms (mobile, desktop, server), Joker uses `HttpOverrides` to automatically intercept all HTTP requests. However, `HttpOverrides` doesn't work on web platforms.

`joker_dio` provides a Dio interceptor that enables Joker support on **all platforms** with minimal setup.

**Use this package when:**

- You need to support web platform alongside native platforms
- You're already using Dio and want consistent behavior across all platforms

## Installation

```yaml
dependencies:
  joker_dio: ^0.0.1  # Includes joker as dependency
  dio: ^5.0.0
```

> **Note**: You don't need to add `joker` separately - `joker_dio` includes it and re-exports everything!

## Usage with Dependency Injection (Recommended)

**Single import** - `joker_dio` re-exports everything from `joker`:

### 1. Define Your Service with Injected Dio

```dart
import 'package:dio/dio.dart';

class ApiService {
  final Dio dio;
  
  // Dio is injected via constructor
  ApiService(this.dio);
  
  Future<User> getUser(int id) async {
    final response = await dio.get('/users/$id');
    return User.fromJson(response.data);
  }
  
  Future<List<Post>> getPosts() async {
    final response = await dio.get('/posts');
    return (response.data as List)
        .map((json) => Post.fromJson(json))
        .toList();
  }
}
```

### 2. Setup in main.dart

```dart
// Single import - re-exports Joker + adds JokerDioInterceptor
import 'package:joker_dio/joker_dio.dart';
import 'package:dio/dio.dart';

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
  
  // Create Dio with base options
  final dio = Dio(BaseOptions(
    baseUrl: 'https://api.example.com',
  ));
  
  // Add Joker interceptor
  // ⚠️ IMPORTANT: JokerDioInterceptor must be the LAST interceptor in the list
  // if you have other interceptors. This ensures Joker can intercept requests
  // before they reach the network layer.
  dio.interceptors.add(JokerDioInterceptor()); // From joker_dio
  
  // Inject into your services
  final apiService = ApiService(dio);
  
  runApp(MyApp(apiService: apiService));
}
```

## With Dependency Injection Packages

### Using get_it

```dart
import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:joker_dio/joker_dio.dart';

final getIt = GetIt.instance;

void setupDependencies() {
  if (kDebugMode) {
    Joker.start();
    // Setup your stubs here...
  }
  
  // Register Dio instance
  getIt.registerSingleton<Dio>(() {
    final dio = Dio(BaseOptions(
      baseUrl: 'https://api.example.com',
    ));
    // ⚠️ IMPORTANT: Add JokerDioInterceptor as the LAST interceptor
    dio.interceptors.add(JokerDioInterceptor());
    return dio;
  }());
  
  // Register services with injected Dio
  getIt.registerSingleton<ApiService>(
    ApiService(getIt<Dio>()),
  );
}
```

### Using provider

```dart
import 'package:provider/provider.dart';
import 'package:joker_dio/joker_dio.dart';
import 'package:dio/dio.dart';

void main() {
  if (kDebugMode) {
    Joker.start();
    // Setup stubs...
  }
  
  runApp(
    MultiProvider(
      providers: [
        Provider<Dio>(
          create: (_) {
            final dio = Dio(BaseOptions(
              baseUrl: 'https://api.example.com',
            ));
            // ⚠️ IMPORTANT: Add JokerDioInterceptor as the LAST interceptor
            dio.interceptors.add(JokerDioInterceptor());
            return dio;
          },
          dispose: (_, dio) => dio.close(),
        ),
        ProxyProvider<Dio, ApiService>(
          update: (_, dio, __) => ApiService(dio),
        ),
      ],
      child: MyApp(),
    ),
  );
}
```

## ⚠️ Important: Interceptor Order

**`JokerDioInterceptor` must be the LAST interceptor in your interceptor list.**

This is critical because Dio executes interceptors in order, and Joker needs to intercept requests **before** they reach the network layer.

### ✅ Correct

```dart
final dio = Dio();

// Other interceptors first
dio.interceptors.add(LogInterceptor());
dio.interceptors.add(AuthInterceptor());
dio.interceptors.add(RetryInterceptor());

// JokerDioInterceptor LAST
dio.interceptors.add(JokerDioInterceptor());
```

### ❌ Incorrect

```dart
final dio = Dio();

// Wrong! Joker won't intercept properly
dio.interceptors.add(JokerDioInterceptor());
dio.interceptors.add(LogInterceptor());
dio.interceptors.add(AuthInterceptor());
```

## Why Dependency Injection?

1. **Minimal Code Changes**: Your services use standard `Dio` - no Joker-specific code
2. **Easy Testing**: Inject mock Dio instances in tests without changing service code
3. **Platform Agnostic**: Same service code works on native and web
4. **Flexible**: Easy to add/remove interceptors or change configuration

## Platform Behavior

- **Native** (mobile, desktop, server): The interceptor provides explicit stub matching even though HttpOverrides works automatically
- **Web**: The interceptor is required because HttpOverrides doesn't exist in browsers

## Comparison with Native Joker

**Native (Automatic)**:

```dart
Joker.start();
// That's it! All Dio requests are intercepted via HttpOverrides
```

**Web (Explicit Interceptor)**:

```dart
Joker.start();
dio.interceptors.add(JokerDioInterceptor());
// Now Dio will check Joker stubs
```

For more examples and documentation, see the [main Joker README](https://github.com/juanvegu/joker_dart).

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

| Package | Pub.dev | Description |
|---------|---------|-------------|
| **[joker](packages/joker)** | [![pub](https://img.shields.io/pub/v/joker.svg)](https://pub.dev/packages/joker) | Core library with `HttpOverrides` magic (works on native platforms) |
| **[joker_http](packages/joker_http)** | [![pub](https://img.shields.io/pub/v/joker_http.svg)](https://pub.dev/packages/joker_http) | Web adapter for `package:http` (required for web platform) |
| **[joker_dio](packages/joker_dio)** | [![pub](https://img.shields.io/pub/v/joker_dio.svg)](https://pub.dev/packages/joker_dio) | Web adapter for `package:dio` (required for web platform) |

## Getting Started

Choose based on your platform and HTTP client:

### Native Platforms (Mobile & Desktop)

- **Any HTTP client using `HttpClient`** → Use `joker` only
- Works automatically with `http`, `dio`, and most HTTP packages via `HttpOverrides`

### Web Platform

- **Using `package:http`** → Use `joker` + `joker_http`
- **Using `package:dio`** → Use `joker` + `joker_dio`
- Web requires specific adapters since `HttpOverrides` doesn't work in browsers

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

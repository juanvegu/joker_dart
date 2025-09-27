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
| **[joker](packages/joker)** | [![pub](https://img.shields.io/pub/v/joker.svg)](https://pub.dev/packages/joker) | ✅ Available | Core library with `HttpOverrides` magic (works on native platforms) |
| **[joker_http](packages/joker_http)** | 🚧 Coming Soon | 🚧 In Development | Web adapter for `package:http` |
| **[joker_dio](packages/joker_dio)** | 🚧 Coming Soon | 🚧 In Development | Web adapter for `package:dio` |

## Getting Started

Choose based on your platform and HTTP client:

### ✅ Native Platforms (Mobile & Desktop) - Available Now

- **Any HTTP client using `HttpClient`** → Use `joker` only
- Works automatically with `http`, `dio`, and most HTTP packages via `HttpOverrides`

### 🚧 Web Platform - Coming Soon

- **Using `package:http`** → Will use `joker` + `joker_http` (in development)
- **Using `package:dio`** → Will use `joker` + `joker_dio` (in development)
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

## Support the Project

If you find `joker` helpful for your projects and it has saved you time, consider supporting its development with a coffee!

Every contribution is highly appreciated and motivates me to keep improving the library, adding new features, and providing support.

[![Buy Me A Coffee](https://cdn.buymeacoffee.com/buttons/v2/default-yellow.png)](https://www.buymeacoffee.com/juanvegu)

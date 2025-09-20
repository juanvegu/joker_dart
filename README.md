# Joker 🃏

![Joker Banner](https://raw.githubusercontent.com/juanvegu/joker_dart/main/assets/joker_banner.png)

[![ci](https://github.com/juanvegu/joker_dart/actions/workflows/ci.yaml/badge.svg)](https://github.com/juanvegu/joker_dart/actions/workflows/ci.yaml)
[![license](https://img.shields.io/badge/license-MIT-blue.svg)](https://opensource.org/licenses/MIT)

A powerful and unified HTTP mocking ecosystem for Dart & Flutter tests, inspired by `OHHTTPStubs`.

Joker provides a single, fluent, and consistent API to stub network requests, making your tests clean, fast, and reliable. It's designed from the ground up to work with popular clients like `http` and `dio` across all platforms (mobile, desktop, and web).

---

## ✨ Features

* **Unified API:** Learn one API, mock everything. Use the same `Joker.when(...)` syntax to mock both `http` and `dio` requests.
* **Non-Invasive on Native:** Thanks to Dart's `HttpOverrides`, Joker can automatically intercept all network traffic on mobile and desktop without any changes to your application code.
* **Cross-Platform Ready:** A first-class, consistent testing experience whether you're running tests on the Dart VM (IO) or in the browser (Web).
* **Fluent & Expressive:** A declarative API that makes your test stubs easy to write and understand.
* **Extensible Ecosystem:** Built as a modular platform, ready for future adapters to support other clients.

---

## 📦 Packages

This monorepo contains the full Joker ecosystem. All packages are managed with [Melos](https://melos.invertase.dev).

| Package | Pub.dev | Description |
| :--- | :--- | :--- |
| **`joker`** | [![pub package](https://img.shields.io/pub/v/joker.svg)](https://pub.dev/packages/joker) | The core package. Contains the public API and the non-invasive `HttpOverrides` magic for native platforms. |
| **`joker_http`** | [![pub package](https://img.shields.io/pub/v/joker_http.svg)](https://pub.dev/packages/joker_http) | Adapter to provide mocking support for the `package:http`. |
| **`joker_dio`** | [![pub package](https://img.shields.io/pub/v/joker_dio.svg)](https://pub.dev/packages/joker_dio) | Adapter to provide mocking support for the `package:dio`. |

---

## 🚀 Getting Started (for Contributors)

Interested in contributing? Welcome! Here's how to set up your development environment.

### Prerequisites

* Flutter SDK installed.
* Dart CLI installed.

### 1. Clone the Repository

```bash
git clone https://github.com/juanvegu/joker_dart.git
cd joker_dart
```

### 2. Install Melos

Activate Melos, the tool we use to manage this monorepo.

```bash
dart pub global activate melos
```

### 3. Bootstrap the Workspace

This command will install all dependencies for all packages and link them together locally.

```bash
melos bootstrap
```

### 4. Run Tests

You can run all tests across the entire ecosystem with a single command:

```bash
melos test:all 
```

---

## 🤝 Contributing

Contributions, issues, and feature requests are welcome! Feel free to check the [issues page](https://github.com/juanvegu/joker_dart/issues).

Please read our [contributing guide](CONTRIBUTING.md) to learn about our development process.

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

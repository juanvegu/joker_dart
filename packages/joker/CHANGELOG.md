# Changelog

## 0.1.1+1

- **Improved compatibility** with `dio` and `http` packages by fixing several `noSuchMethod` errors in HTTP client implementations
- **Enhanced HTTP client response handling** to provide better compatibility with different HTTP client libraries
- **Updated README** with comprehensive API documentation including all available methods:
  - Added documentation for `stubJsonArray()` method for JSON array responses
  - Added documentation for `stubText()` method for plain text responses  
  - Added documentation for `stubJsonFile()` method for loading JSON from files
  - Added complete parameter tables for all stubbing methods
  - Added detailed examples for stub management and dynamic configuration
  - Improved organization with clear method categorization
- **Better error handling** and more robust HTTP request/response mocking
- **Fixed internal method implementations** to prevent runtime errors when used with popular HTTP client packages

## 0.1.0

- Initial release of the Joker library for HTTP request stubbing and mocking in Dart.
- Intercept HTTP requests from any library using HttpOverrides.
- Provides a simple and flexible API for defining request handlers and responses.
- Supports various HTTP methods, headers, and body content types.
- Includes utilities for verifying requests and managing mock server state.

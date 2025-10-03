// Web implementation using a custom HTTP interceptor
import 'joker_request.dart';
import 'joker_stub.dart';

/// Web implementation of Joker
///
/// Since HttpOverrides doesn't work on web, we need a different approach.
/// Users need to manually configure their HTTP clients to use Joker's
/// interception logic.
class JokerPlatform {
  static final List<JokerStub> _stubs = [];
  static bool _isActive = false;

  /// Returns a list of all currently registered stubs
  static List<JokerStub> get stubs => List.unmodifiable(_stubs);

  /// Returns true if Joker is currently active and intercepting requests
  static bool get isActive => _isActive;

  /// Starts intercepting HTTP requests
  ///
  /// On web, this only sets the active flag. Actual interception needs to be
  /// configured in your HTTP client (http package or dio package).
  static void start() {
    _isActive = true;
  }

  /// Stops intercepting HTTP requests and clears all stubs
  static void stop() {
    _isActive = false;
    _stubs.clear();
  }

  /// Adds a stub for HTTP request interception
  static JokerStub addStub(JokerStub stub) {
    _stubs.add(stub);
    return stub;
  }

  /// Removes a specific stub
  static bool removeStub(JokerStub stub) {
    return _stubs.remove(stub);
  }

  /// Removes all stubs with the given name
  static int removeStubsByName(String name) {
    final toRemove = _stubs.where((stub) => stub.name == name).toList();
    for (final stub in toRemove) {
      _stubs.remove(stub);
    }
    return toRemove.length;
  }

  /// Clears all registered stubs
  static void clearStubs() {
    _stubs.clear();
  }

  /// Finds a stub that matches the given request parameters
  static JokerStub? findStubForRequest({
    required String method,
    required Uri uri,
  }) {
    if (!_isActive) return null;

    final jokerRequest = _WebRequestAdapter(method: method, uri: uri);

    for (int i = 0; i < _stubs.length; i++) {
      final stub = _stubs[i];
      if (stub.matcher.matches(jokerRequest)) {
        if (stub.removeAfterUse) {
          _stubs.removeAt(i);
        }
        return stub;
      }
    }
    return null;
  }
}

/// Adapter for web requests
class _WebRequestAdapter implements JokerRequest {
  @override
  final String method;

  @override
  final Uri uri;

  _WebRequestAdapter({required this.method, required this.uri});
}

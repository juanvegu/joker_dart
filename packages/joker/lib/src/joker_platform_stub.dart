// Stub implementation - this should never be used
// The actual implementation will come from conditional imports

import 'joker_stub.dart';

/// Stub platform that should never be instantiated
class JokerPlatform {
  static List<JokerStub> get stubs =>
      throw UnimplementedError('Platform not supported');

  static bool get isActive =>
      throw UnimplementedError('Platform not supported');

  static void start() => throw UnimplementedError('Platform not supported');

  static void stop() => throw UnimplementedError('Platform not supported');

  static JokerStub addStub(JokerStub stub) =>
      throw UnimplementedError('Platform not supported');

  static bool removeStub(JokerStub stub) =>
      throw UnimplementedError('Platform not supported');

  static int removeStubsByName(String name) =>
      throw UnimplementedError('Platform not supported');

  static void clearStubs() =>
      throw UnimplementedError('Platform not supported');
}

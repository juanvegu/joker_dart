/// Exception thrown when no stub is found for a request
class JokerNoStubFoundException implements Exception {
  /// Creates a no stub found exception
  const JokerNoStubFoundException(this.message);

  /// The error message
  final String message;

  @override
  String toString() => 'JokerNoStubFoundException: $message';
}

/// Exception thrown when a file-based response cannot be loaded
class JokerFileLoadException implements Exception {
  /// Creates a file load exception
  const JokerFileLoadException(this.message);

  /// The error message
  final String message;

  @override
  String toString() => 'JokerFileLoadException: $message';
}

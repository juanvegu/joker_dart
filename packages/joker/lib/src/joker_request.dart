/// A platform-agnostic request interface for matching
abstract class JokerRequest {
  String get method;
  Uri get uri;
}

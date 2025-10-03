import '../joker_request.dart';

/// A matcher that determines if a request should be intercepted
abstract class JokerMatcher {
  /// Returns true if this matcher should handle the given request
  bool matches(JokerRequest request);
}

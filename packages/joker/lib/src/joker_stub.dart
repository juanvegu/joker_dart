import 'joker_request.dart';
import 'joker_response.dart';
import 'matchers/joker_matcher.dart';

/// A stub that defines how to respond to a matched HTTP request
class JokerStub {
  final JokerMatcher matcher;
  final JokerResponse Function(JokerRequest request) responseProvider;
  final String? name;

  /// Whether this stub should be removed after being used once
  final bool removeAfterUse;

  const JokerStub({
    required this.matcher,
    required this.responseProvider,
    this.name,
    this.removeAfterUse = false,
  });

  /// Creates a stub with a static response
  factory JokerStub.create({
    required JokerMatcher matcher,
    required JokerResponse response,
    String? name,
    bool removeAfterUse = false,
  }) {
    return JokerStub(
      matcher: matcher,
      responseProvider: (request) => response,
      name: name,
      removeAfterUse: removeAfterUse,
    );
  }
}

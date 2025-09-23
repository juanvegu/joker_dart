import 'dart:io';
import 'joker_matcher.dart';

/// A matcher that uses a custom function to determine matches
class CustomMatcher implements JokerMatcher {
  final bool Function(HttpClientRequest request) _matcher;

  const CustomMatcher(this._matcher);

  @override
  bool matches(HttpClientRequest request) => _matcher(request);
}

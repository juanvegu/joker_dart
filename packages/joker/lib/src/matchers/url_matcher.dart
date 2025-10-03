import 'joker_matcher.dart';
import '../joker_request.dart';

class UrlMatcher implements JokerMatcher {
  final String? host;
  final String? path;
  final String? method;

  const UrlMatcher({this.host, this.path, this.method});

  @override
  bool matches(JokerRequest request) {
    // Check method if specified
    if (method != null &&
        request.method.toLowerCase() != method!.toLowerCase()) {
      return false;
    }

    // Check host if specified
    if (host != null && request.uri.host != host) {
      return false;
    }

    // Check path if specified
    if (path != null && request.uri.path != path) {
      return false;
    }

    return true;
  }
}

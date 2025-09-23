import 'dart:io';

/// Custom HttpClientResponse that returns stubbed data
class JokerHttpClientResponse implements HttpClientResponse {
  // Use noSuchMethod for all other unimplemented methods
  @override
  dynamic noSuchMethod(Invocation invocation) {
    // Most getters can return null in test mode
    if (invocation.isGetter) return null;

    // Most setters can do nothing in test mode
    if (invocation.isSetter) return null;

    throw UnsupportedError(
      '${invocation.memberName} not supported in test mode',
    );
  }
}

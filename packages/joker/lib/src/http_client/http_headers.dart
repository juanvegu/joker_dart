import 'dart:io';

/// Simple HttpHeaders implementation for test mode
class JokerHttpHeaders implements HttpHeaders {
  final Map<String, List<String>> _headers;

  JokerHttpHeaders(this._headers);

  @override
  List<String>? operator [](String name) => _headers[name.toLowerCase()];

  @override
  void add(String name, Object value, {bool preserveHeaderCase = false}) {
    final key = preserveHeaderCase ? name : name.toLowerCase();
    _headers.putIfAbsent(key, () => []).add(value.toString());
  }

  @override
  void set(String name, Object value, {bool preserveHeaderCase = false}) {
    final key = preserveHeaderCase ? name : name.toLowerCase();
    _headers[key] = [value.toString()];
  }

  @override
  void remove(String name, Object value) {
    _headers[name.toLowerCase()]?.remove(value.toString());
  }

  @override
  void removeAll(String name) {
    _headers.remove(name.toLowerCase());
  }

  @override
  void forEach(void Function(String name, List<String> values) action) {
    _headers.forEach(action);
  }

  @override
  void clear() {
    _headers.clear();
  }

  @override
  String? value(String name) {
    final values = _headers[name.toLowerCase()];
    return values?.isNotEmpty == true ? values!.join(', ') : null;
  }

  @override
  ContentType? get contentType {
    final contentTypeHeader = value('content-type');
    if (contentTypeHeader == null) return null;

    try {
      return ContentType.parse(contentTypeHeader);
    } catch (e) {
      return null;
    }
  }

  // Use noSuchMethod for all other unimplemented methods
  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (invocation.isGetter) {
      return null; // Most getters can return null in test mode
    }
    if (invocation.isSetter) {
      return null; // Most setters can do nothing in test mode
    }
    return null;
  }
}

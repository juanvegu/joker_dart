import 'package:dio/dio.dart';
import 'package:joker/joker.dart';

/// JokerDio provides integration between Joker HTTP mocking library and Dio HTTP client.
///
/// This class allows you to use Joker's powerful stubbing capabilities with Dio
/// by automatically configuring Dio to work with Joker's HTTP interception.
class JokerDio {
  /// Creates a Dio instance configured to work with Joker.
  ///
  /// The returned Dio instance will automatically use Joker's HTTP interception
  /// when Joker is active. This means any stubs registered with Joker will be
  /// used instead of making actual network requests.
  ///
  /// Example:
  /// ```dart
  /// // Start Joker
  /// Joker.start();
  ///
  /// // Register a stub
  /// Joker.stubJson(
  ///   host: 'pokeapi.co',
  ///   path: '/api/v2/pokemon/1',
  ///   data: {'name': 'bulbasaur', 'id': 1},
  /// );
  ///
  /// // Create Dio instance
  /// final dio = JokerDio.create();
  ///
  /// // Make request - will use stub if available
  /// final response = await dio.get('https://pokeapi.co/api/v2/pokemon/1');
  /// ```
  static Dio create({
    BaseOptions? options,
    String? baseUrl,
    Map<String, dynamic>? headers,
  }) {
    final baseOptions = BaseOptions(
      baseUrl: baseUrl ?? '',
      headers: headers,
      // Configure Dio to use the system's HTTP client
      // which will be intercepted by Joker when active
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    );

    if (options != null) {
      baseOptions.baseUrl = options.baseUrl.isNotEmpty
          ? options.baseUrl
          : baseOptions.baseUrl;
      baseOptions.connectTimeout =
          options.connectTimeout ?? baseOptions.connectTimeout;
      baseOptions.receiveTimeout =
          options.receiveTimeout ?? baseOptions.receiveTimeout;
      baseOptions.headers.addAll(options.headers);
      baseOptions.queryParameters = options.queryParameters;
      baseOptions.extra = options.extra;
      baseOptions.contentType = options.contentType ?? baseOptions.contentType;
      baseOptions.responseType = options.responseType;
      baseOptions.validateStatus = options.validateStatus;
      baseOptions.followRedirects = options.followRedirects;
      baseOptions.maxRedirects = options.maxRedirects;
      baseOptions.persistentConnection = options.persistentConnection;
      baseOptions.requestEncoder = options.requestEncoder;
      baseOptions.responseDecoder = options.responseDecoder;
      baseOptions.listFormat = options.listFormat;
    }

    return Dio(baseOptions);
  }

  /// Convenience method that starts Joker and returns a configured Dio instance.
  ///
  /// This is equivalent to calling `Joker.start()` followed by `JokerDio.create()`.
  ///
  /// Example:
  /// ```dart
  /// final dio = JokerDio.createWithJoker();
  /// // Joker is now active and dio is ready to use
  /// ```
  static Dio createWithJoker({
    BaseOptions? options,
    String? baseUrl,
    Map<String, dynamic>? headers,
  }) {
    Joker.start();
    return create(options: options, baseUrl: baseUrl, headers: headers);
  }
}

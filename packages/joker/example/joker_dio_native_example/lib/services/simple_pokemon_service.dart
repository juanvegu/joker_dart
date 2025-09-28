import 'package:dio/dio.dart';
import '../models/pokemon.dart';
import '../models/pokemon_list.dart';

/// Simple Pokemon service using only Dio
/// No Joker dependencies - just pure HTTP calls
class SimplePokemonService {
  late final Dio _dio;
  static const String _baseUrl = 'https://pokeapi.co/api/v2';

  SimplePokemonService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'User-Agent': 'Simple-Dio-Example/1.0',
        },
      ),
    );

    // Debug interceptor
    _dio.interceptors.add(
      LogInterceptor(
        requestBody: false,
        responseBody: true,
        requestHeader: false,
        responseHeader: false,
        error: true,
        logPrint: (object) => print('🌐 DIO: $object'),
      ),
    );
  }

  Future<PokemonListResponse> getPokemonList({
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      print('🌐 Calling real Pokemon API...');
      final response = await _dio.get(
        '/pokemon',
        queryParameters: {'limit': limit, 'offset': offset},
      );

      print('🌐 Real API response received: ${response.statusCode}');

      final data = response.data as Map<String, dynamic>;
      return PokemonListResponse.fromJson(data);
    } catch (e) {
      print('❌ Error calling real API: $e');
      rethrow;
    }
  }

  Future<Pokemon> getPokemon(int id) async {
    try {
      print('🌐 Fetching Pokemon $id from real API...');
      final response = await _dio.get('/pokemon/$id');

      final data = response.data as Map<String, dynamic>;
      return Pokemon.fromJson(data);
    } catch (e) {
      print('❌ Error fetching Pokemon $id: $e');
      rethrow;
    }
  }

  void dispose() {
    _dio.close();
  }
}

/// Exception class for Pokemon service errors
class PokemonServiceException implements Exception {
  final String message;
  final int? statusCode;

  PokemonServiceException(this.message, {this.statusCode});

  @override
  String toString() => 'PokemonServiceException: $message';
}

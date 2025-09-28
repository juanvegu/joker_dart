import 'package:dio/dio.dart';
import '../models/pokemon.dart';
import '../models/pokemon_list.dart';

/// Service class for interacting with the Pokemon API using Dio.
///
/// This is the base implementation using only Dio for HTTP calls.
/// Joker integration will be added later once this works properly.
class PokemonService {
  late final Dio _dio;
  static const String _baseUrl = 'https://pokeapi.co/api/v2';

  /// Creates a new Pokemon service with a standard Dio client
  PokemonService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'User-Agent': 'Dio-Pokemon-Example/1.0',
        },
      ),
    );

    // Add logging interceptor to debug requests
    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: false,
        requestHeader: true,
        responseHeader: false,
        error: true,
      ),
    );
  }

  /// Fetches a list of Pokemon from the API
  ///
  /// [limit] - Number of Pokemon to fetch (default: 20)
  /// [offset] - Number of Pokemon to skip (default: 0)
  ///
  /// Returns a [PokemonListResponse] containing the list of Pokemon.
  Future<PokemonListResponse> getPokemonList({
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      print(
        '🔍 Making request to: $_baseUrl/pokemon?limit=$limit&offset=$offset',
      );

      final response = await _dio.get(
        '/pokemon',
        queryParameters: {'limit': limit, 'offset': offset},
      );

      print('✅ Response received: ${response.statusCode}');
      print('📦 Response type: ${response.data.runtimeType}');

      if (response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        print('📦 Response keys: ${data.keys.toList()}');
        return PokemonListResponse.fromJson(data);
      } else {
        throw Exception(
          'Invalid response format: expected Map<String, dynamic>',
        );
      }
    } on DioException catch (e) {
      print('❌ DioException occurred:');
      print('  Type: ${e.type}');
      print('  Message: ${e.message}');
      print('  Error: ${e.error}');
      if (e.response != null) {
        print('  Status Code: ${e.response!.statusCode}');
        print('  Response Data: ${e.response!.data}');
      }
      print('  Request URL: ${e.requestOptions.uri}');

      throw PokemonServiceException(
        'Failed to fetch Pokemon list: ${e.message ?? 'Unknown error'}',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      print('❌ Unexpected error: $e');
      throw PokemonServiceException('Unexpected error: $e');
    }
  }

  /// Fetches detailed information about a specific Pokemon
  ///
  /// [id] - The Pokemon ID to fetch
  ///
  /// Returns a [Pokemon] object with detailed information.
  Future<Pokemon> getPokemon(int id) async {
    try {
      print('🔍 Fetching Pokemon with ID: $id');
      final response = await _dio.get('/pokemon/$id');

      print('✅ Pokemon response received: ${response.statusCode}');

      if (response.data is Map<String, dynamic>) {
        return Pokemon.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception('Invalid response format for Pokemon $id');
      }
    } on DioException catch (e) {
      print('❌ Failed to fetch Pokemon $id: ${e.message}');
      throw PokemonServiceException(
        'Failed to fetch Pokemon with ID $id: ${e.message ?? 'Unknown error'}',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      print('❌ Unexpected error fetching Pokemon $id: $e');
      throw PokemonServiceException('Unexpected error: $e');
    }
  }

  /// Fetches detailed information about a Pokemon by name
  ///
  /// [name] - The Pokemon name to fetch
  ///
  /// Returns a [Pokemon] object with detailed information.
  Future<Pokemon> getPokemonByName(String name) async {
    try {
      final response = await _dio.get('/pokemon/${name.toLowerCase()}');
      return Pokemon.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw PokemonServiceException(
        'Failed to fetch Pokemon "$name": ${e.message}',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      throw PokemonServiceException('Unexpected error: $e');
    }
  }

  /// Fetches multiple Pokemon by their IDs in parallel
  ///
  /// [ids] - List of Pokemon IDs to fetch
  ///
  /// Returns a list of [Pokemon] objects. If any request fails, the entire
  /// operation will fail.
  Future<List<Pokemon>> getMultiplePokemon(List<int> ids) async {
    try {
      final futures = ids.map((id) => getPokemon(id));
      return await Future.wait(futures);
    } catch (e) {
      throw PokemonServiceException('Failed to fetch multiple Pokemon: $e');
    }
  }

  /// Searches for Pokemon by name (partial match)
  ///
  /// [query] - The search term
  /// [limit] - Maximum number of results to return
  ///
  /// This method fetches a list of Pokemon and filters by name.
  /// Note: In a real application, you might want to implement server-side search.
  Future<List<PokemonListItem>> searchPokemon({
    required String query,
    int limit = 1000,
  }) async {
    final pokemonList = await getPokemonList(limit: limit);
    final lowercaseQuery = query.toLowerCase();

    return pokemonList.results
        .where((pokemon) => pokemon.name.contains(lowercaseQuery))
        .toList();
  }

  /// Closes the Dio client and cleans up resources
  void dispose() {
    _dio.close();
  }
}

/// Exception thrown by [PokemonService] when an error occurs
class PokemonServiceException implements Exception {
  final String message;
  final int? statusCode;

  const PokemonServiceException(this.message, {this.statusCode});

  @override
  String toString() {
    if (statusCode != null) {
      return 'PokemonServiceException ($statusCode): $message';
    }
    return 'PokemonServiceException: $message';
  }
}

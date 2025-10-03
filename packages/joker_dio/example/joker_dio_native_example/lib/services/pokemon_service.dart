import 'package:dio/dio.dart';
import 'package:joker/joker.dart';
import 'package:joker_dio/joker_dio.dart';
import 'package:joker_dio_native_example/models/pokemon_list.dart';
import '../models/pokemon.dart';
import '../config/pokemon_stubs.dart';

/// Pokemon service that integrates Joker with Dio
///
/// This service can work in two modes:
/// 1. Real API mode: Makes actual HTTP calls to PokeAPI
/// 2. Joker mode: Returns stubbed responses when Joker is active
///
/// Stub configuration is handled by PokemonStubConfig, not by this service.
class PokemonService {
  late Dio _dio;
  static const String _baseUrl = 'https://pokeapi.co/api/v2';

  PokemonService() {
    _initializeDio();
  }

  void _initializeDio() {
    _dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'User-Agent': 'Joker-Dio-Pokemon/1.0',
        },
      ),
    );

    // Add logging interceptor for debugging
    _dio.interceptors.add(
      LogInterceptor(
        requestBody: false,
        responseBody: false, // Avoid large response logs
        requestHeader: true,
        responseHeader: false,
        error: true,
        logPrint: (object) => print('🔧 HTTP: $object'),
      ),
    );

    _dio.interceptors.add(JokerDioInterceptor());
  }

  /// Recreate Dio instance to ensure clean state
  void _recreateDio() {
    print('🔄 Recreating Dio instance for clean state...');

    // Dispose old instance
    try {
      _dio.close(force: true);
    } catch (e) {
      print('⚠️ Warning disposing old Dio: $e');
    }

    // Create fresh instance
    _initializeDio();
    print('✅ New Dio instance created');
  }

  /// Enable Joker mode - HTTP calls will be intercepted
  void enableJoker() {
    print('🃏 Enabling Joker mode...');
    PokemonStubConfig.setupStubs();

    // Recreate Dio to ensure it picks up Joker's interception
    _recreateDio();
    print('🃏 Joker mode enabled with fresh Dio instance');
  }

  /// Disable Joker mode - HTTP calls will go to real API
  void disableJoker() {
    print('🌐 Disabling Joker mode...');
    Joker.stop();

    // Recreate Dio to ensure it's no longer affected by Joker
    _recreateDio();
    print('🌐 Real API mode enabled with fresh Dio instance');
  }

  /// Check if Joker is currently active
  /// We rely primarily on our internal flag since we control the state
  bool get isJokerActive => Joker.isActive;

  /// Fetch Pokemon list with proper source indication
  Future<PokemonListResponse> getPokemonList({
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final source = isJokerActive ? 'STUB' : 'REAL API';
      print('🔍 Fetching Pokemon list from: $source');
      print('🔍 URL: $_baseUrl/pokemon?limit=$limit&offset=$offset');
      print('🔍 Joker.isActive: ${Joker.isActive}');
      print('🔍 Total stubs available: ${Joker.stubs.length}');

      final response = await _dio.get(
        '/pokemon',
        queryParameters: {'limit': limit, 'offset': offset},
      );

      print('✅ Response received: ${response.statusCode}');

      final data = response.data as Map<String, dynamic>;

      // Check if response came from Joker
      if (data.containsKey('loaded_from_joker') &&
          data['loaded_from_joker'] == true) {
        print('🃏 ✨ Data loaded from Joker stubs!');
      } else {
        print('🌐 📡 Data loaded from real Pokemon API');
      }

      return PokemonListResponse.fromJson(data);
    } catch (e) {
      print('❌ Error fetching Pokemon list: $e');
      rethrow;
    }
  }

  /// Fetch individual Pokemon
  Future<Pokemon> getPokemon(int id) async {
    try {
      final source = isJokerActive ? 'STUB' : 'REAL API';
      print('🔍 Fetching Pokemon $id from: $source');

      final response = await _dio.get('/pokemon/$id');

      final data = response.data as Map<String, dynamic>;

      // Check if response came from Joker
      if (data.containsKey('loaded_from_joker') &&
          data['loaded_from_joker'] == true) {
        print('🃏 ✨ Pokemon $id loaded from Joker stub!');
      } else {
        print('🌐 📡 Pokemon $id loaded from real API');
      }

      return Pokemon.fromJson(data);
    } catch (e) {
      print('❌ Error fetching Pokemon $id: $e');
      rethrow;
    }
  }

  void dispose() {
    try {
      _dio.close(force: true);
      print('🧹 PokemonService disposed');
    } catch (e) {
      print('⚠️ Warning disposing PokemonService: $e');
    }
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

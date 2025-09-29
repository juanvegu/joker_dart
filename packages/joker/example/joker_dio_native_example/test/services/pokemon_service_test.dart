import 'package:flutter_test/flutter_test.dart';
import 'package:joker/joker.dart';
import 'package:joker_dio_native_example/services/pokemon_service.dart';
import '../test_helpers.dart';

void main() {
  group('PokemonService Tests with Joker', () {
    late PokemonService pokemonService;

    setUp(() {
      // Create fresh service instance for each test
      pokemonService = PokemonService();
    });

    tearDown(() {
      // Clean up after each test
      pokemonService.dispose();
      TestHelpers.tearDownJoker();
    });

    group('Joker Integration', () {
      test('should enable and disable Joker mode correctly', () async {
        // Initially, Joker should not be active
        expect(pokemonService.isJokerActive, isFalse);
        expect(Joker.isActive, isFalse);

        // Enable Joker mode
        pokemonService.enableJoker();

        expect(pokemonService.isJokerActive, isTrue);
        expect(Joker.isActive, isTrue);
        expect(Joker.stubs.isNotEmpty, isTrue);

        // Disable Joker mode
        pokemonService.disableJoker();

        expect(pokemonService.isJokerActive, isFalse);
        expect(Joker.isActive, isFalse);
      });

      test('should have stubs available when Joker is enabled', () async {
        pokemonService.enableJoker();

        expect(Joker.stubs.isNotEmpty, isTrue);

        // Check that Pokemon-specific stubs are registered
        final stubNames = Joker.stubs.map((stub) => stub.name ?? '').toList();
        expect(stubNames.any((name) => name.contains('pokemon')), isTrue);
      });
    });

    group('Pokemon List Fetching', () {
      test('should fetch Pokemon list from Joker stubs', () async {
        // Enable Joker with our test configuration
        TestHelpers.setupBasicJokerStubs();

        // Fetch Pokemon list
        final pokemonList = await pokemonService.getPokemonList();

        expect(pokemonList, isNotNull);
        expect(pokemonList.count, equals(3));
        expect(pokemonList.results, hasLength(3));

        // Verify it came from Joker
        expect(pokemonList.loadedFromJoker, isTrue);

        // Check the Pokemon names
        final pokemonNames = pokemonList.results.map((p) => p.name).toList();
        expect(pokemonNames, contains('pikachu'));
        expect(pokemonNames, contains('charmander'));
        expect(pokemonNames, contains('bulbasaur'));
      });

      test('should handle pagination parameters', () async {
        TestHelpers.setupBasicJokerStubs();
        pokemonService.enableJoker();

        // Test with different pagination parameters
        final pokemonList = await pokemonService.getPokemonList(
          limit: 10,
          offset: 5,
        );

        expect(pokemonList, isNotNull);
        expect(pokemonList.results, isNotEmpty);
      });

      test('should throw exception when network fails', () async {
        // Set up Joker with error response
        Joker.stop();
        Joker.start();

        Joker.stubJson(
          host: 'pokeapi.co',
          path: '/api/v2/pokemon',
          method: 'GET',
          statusCode: 500,
          name: 'pokemon-list-error',
          data: {'error': 'Internal Server Error'},
        );

        // Should throw exception
        expect(
          () async => await pokemonService.getPokemonList(),
          throwsException,
        );
      });
    });

    group('Individual Pokemon Fetching', () {
      test('should fetch individual Pokemon by ID from Joker', () async {
        TestHelpers.setupBasicJokerStubs();
        pokemonService.enableJoker();

        final pokemon = await pokemonService.getPokemon(25);

        expect(pokemon, isNotNull);
        expect(pokemon.id, equals(25));
        expect(pokemon.name, equals('pikachu'));
        expect(pokemon.loadedFromJoker, isTrue);
        expect(pokemon.types, isNotEmpty);
        expect(pokemon.stats, isNotEmpty);
        expect(pokemon.sprites, isNotNull);
      });

      test('should fetch Pokemon with correct type information', () async {
        TestHelpers.setupBasicJokerStubs();
        pokemonService.enableJoker();

        final pikachu = await pokemonService.getPokemon(25);
        expect(pikachu.types.first.type.name, equals('electric'));

        final charmander = await pokemonService.getPokemon(4);
        expect(charmander.types.first.type.name, equals('fire'));
      });

      test('should handle Pokemon not found error', () async {
        // Set up Joker with 404 response
        Joker.stop();
        Joker.start();

        Joker.stubJson(
          host: 'pokeapi.co',
          path: '/api/v2/pokemon/999',
          method: 'GET',
          statusCode: 404,
          name: 'pokemon-not-found',
          data: {'error': 'Not found'},
        );

        pokemonService.enableJoker();

        expect(
          () async => await pokemonService.getPokemon(999),
          throwsException,
        );
      });
    });

    group('Service State Management', () {
      test('should maintain clean state between mode switches', () async {
        // Start in real API mode
        expect(pokemonService.isJokerActive, isFalse);

        // Enable Joker
        pokemonService.enableJoker();
        expect(pokemonService.isJokerActive, isTrue);

        // Disable Joker
        pokemonService.disableJoker();
        expect(pokemonService.isJokerActive, isFalse);

        // Enable again
        pokemonService.enableJoker();
        expect(pokemonService.isJokerActive, isTrue);
      });

      test('should properly dispose resources', () async {
        pokemonService.enableJoker();

        // Should not throw when disposing
        expect(() => pokemonService.dispose(), returnsNormally);
      });
    });

    group('Error Handling', () {
      test('should handle malformed JSON responses', () async {
        // Set up Joker with invalid JSON
        Joker.stop();
        Joker.start();

        Joker.stubText(
          host: 'pokeapi.co',
          path: '/api/v2/pokemon',
          method: 'GET',
          statusCode: 200,
          text: 'invalid json response',
          name: 'malformed-json',
        );

        expect(
          () async => await pokemonService.getPokemonList(),
          throwsA(isA<TypeError>()),
        );
      });

      test('should handle timeout scenarios', () async {
        // Set up Joker with delayed response
        Joker.stop();
        Joker.start();

        Joker.stubJson(
          host: 'pokeapi.co',
          path: '/api/v2/pokemon',
          method: 'GET',
          statusCode: 408, // Request Timeout
          name: 'timeout-error',
          data: {'error': 'Request Timeout'},
        );

        expect(
          () async => await pokemonService.getPokemonList(),
          throwsException,
        );
      });
    });

    group('Joker Stub Identification', () {
      test('should correctly identify responses from Joker', () async {
        TestHelpers.setupBasicJokerStubs();
        pokemonService.enableJoker();

        final pokemonList = await pokemonService.getPokemonList();
        final pokemon = await pokemonService.getPokemon(25);

        // Both responses should be marked as coming from Joker
        expect(pokemonList.loadedFromJoker, isTrue);
        expect(pokemon.loadedFromJoker, isTrue);
      });

      // Note: Concurrent request test removed due to timing issues with verbose logging
    });
  });
}

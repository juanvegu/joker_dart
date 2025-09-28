import 'package:flutter_test/flutter_test.dart';
import 'package:joker_dio_native_example/config/pokemon_stubs.dart';
import 'package:joker_dio_native_example/services/pokemon_service.dart';
import 'package:joker_dio_native_example/managers/joker_manager.dart';

void main() {
  group('Pokemon Joker Integration Tests', () {
    late PokemonService pokemonService;
    late JokerManager jokerManager;

    setUp(() {
      pokemonService = PokemonService();
      jokerManager = JokerManager();
    });

    tearDown(() {
      pokemonService.dispose();
      jokerManager.disableJoker();
    });

    test('should use Joker stubs when enabled', () async {
      // Arrange
      jokerManager.enableJoker();

      // Act
      final pokemonList = await pokemonService.getPokemonList(limit: 5);

      // Assert
      expect(pokemonList.loadedFromJoker, isTrue);
      expect(pokemonList.results, isNotEmpty);
      expect(pokemonList.results.length, equals(5));
      expect(pokemonList.count, equals(1302));
    });

    test('should get individual Pokemon from stubs', () async {
      // Arrange
      jokerManager.enableJoker();

      // Act - Get Pikachu
      final pikachu = await pokemonService.getPokemon(25);

      // Assert
      expect(pikachu.loadedFromJoker, isTrue);
      expect(pikachu.name, equals('pikachu'));
      expect(pikachu.id, equals(25));
      expect(pikachu.types, isNotEmpty);
      expect(pikachu.types.first.type.name, equals('electric'));
    });

    test('should get Pokemon by name from stubs', () async {
      // Arrange
      jokerManager.enableJoker();

      // Act - Get Charmander by name
      final charmander = await pokemonService.getPokemonByName('charmander');

      // Assert
      expect(charmander.loadedFromJoker, isTrue);
      expect(charmander.name, equals('charmander'));
      expect(charmander.id, equals(4));
      expect(charmander.types, isNotEmpty);
      expect(charmander.types.first.type.name, equals('fire'));
    });

    test('should get multiple Pokemon from stubs', () async {
      // Arrange
      jokerManager.enableJoker();

      // Act - Get first 3 starter Pokemon
      final starters = await pokemonService.getMultiplePokemon([1, 4, 7]);

      // Assert
      expect(starters, hasLength(3));
      expect(starters[0].name, equals('bulbasaur'));
      expect(starters[0].loadedFromJoker, isTrue);
      expect(starters[1].name, equals('charmander'));
      expect(starters[1].loadedFromJoker, isTrue);
      expect(starters[2].name, equals('squirtle'));
      expect(starters[2].loadedFromJoker, isTrue);
    });

    test('joker manager should toggle states correctly', () {
      // Arrange
      expect(jokerManager.isJokerActive, isFalse);

      // Act & Assert - Enable
      jokerManager.enableJoker();
      expect(jokerManager.isJokerActive, isTrue);

      // Act & Assert - Disable
      jokerManager.disableJoker();
      expect(jokerManager.isJokerActive, isFalse);

      // Act & Assert - Toggle
      jokerManager.toggleJoker();
      expect(jokerManager.isJokerActive, isTrue);

      jokerManager.toggleJoker();
      expect(jokerManager.isJokerActive, isFalse);
    });

    test('should handle search functionality', () async {
      // Arrange
      jokerManager.enableJoker();

      // Act
      final searchResults = await pokemonService.searchPokemon(
        query: 'char',
        limit: 50,
      );

      // Assert
      expect(searchResults, isNotEmpty);
      // Should find charmander at minimum
      final charmander = searchResults.where((p) => p.name.contains('char'));
      expect(charmander, isNotEmpty);
    });
  });
}

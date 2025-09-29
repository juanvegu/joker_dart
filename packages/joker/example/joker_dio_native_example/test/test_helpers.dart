import 'package:flutter_test/flutter_test.dart';
import 'package:joker/joker.dart';

/// Test helper utilities for Pokemon API tests using Joker
class TestHelpers {
  /// Sets up Joker with basic Pokemon stubs for testing
  static void setupBasicJokerStubs() {
    // Ensure clean state
    Joker.stop();
    Joker.start();

    // Basic Pokemon list stub
    Joker.stubJson(
      host: 'pokeapi.co',
      path: '/api/v2/pokemon',
      method: 'GET',
      name: 'test-pokemon-list',
      data: {
        'count': 3,
        'next': null,
        'previous': null,
        'loaded_from_joker': true,
        'results': [
          {'name': 'pikachu', 'url': 'https://pokeapi.co/api/v2/pokemon/25/'},
          {'name': 'charmander', 'url': 'https://pokeapi.co/api/v2/pokemon/4/'},
          {'name': 'bulbasaur', 'url': 'https://pokeapi.co/api/v2/pokemon/1/'},
        ],
      },
    );

    // Individual Pokemon stubs
    _stubPokemon(25, 'pikachu', 'electric');
    _stubPokemon(4, 'charmander', 'fire');
    _stubPokemon(1, 'bulbasaur', 'grass');
  }

  /// Creates a stub for an individual Pokemon
  static void _stubPokemon(int id, String name, String type) {
    final pokemonData = {
      'id': id,
      'name': name,
      'height': 4,
      'weight': 60,
      'loaded_from_joker': true,
      'sprites': {
        'front_default':
            'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/$id.png',
        'back_default':
            'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/back/$id.png',
        'front_shiny':
            'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/shiny/$id.png',
        'back_shiny':
            'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/back/shiny/$id.png',
      },
      'types': [
        {
          'slot': 1,
          'type': {'name': type, 'url': 'https://pokeapi.co/api/v2/type/13/'},
        },
      ],
      'stats': [
        {
          'base_stat': 55,
          'effort': 0,
          'stat': {'name': 'hp', 'url': 'https://pokeapi.co/api/v2/stat/1/'},
        },
        {
          'base_stat': 40,
          'effort': 0,
          'stat': {
            'name': 'attack',
            'url': 'https://pokeapi.co/api/v2/stat/2/',
          },
        },
        {
          'base_stat': 50,
          'effort': 0,
          'stat': {
            'name': 'defense',
            'url': 'https://pokeapi.co/api/v2/stat/3/',
          },
        },
        {
          'base_stat': 90,
          'effort': 2,
          'stat': {'name': 'speed', 'url': 'https://pokeapi.co/api/v2/stat/6/'},
        },
      ],
    };

    // Stub by ID
    Joker.stubJson(
      host: 'pokeapi.co',
      path: '/api/v2/pokemon/$id',
      name: 'test-pokemon-$name-id',
      data: pokemonData,
    );

    // Stub by name
    Joker.stubJson(
      host: 'pokeapi.co',
      path: '/api/v2/pokemon/$name',
      name: 'test-pokemon-$name-name',
      data: pokemonData,
    );
  }

  /// Cleans up Joker state after tests
  static void tearDownJoker() {
    Joker.stop();
  }

  /// Creates test data for Pokemon list response
  static Map<String, dynamic> createTestPokemonListData({
    int count = 3,
    List<Map<String, String>>? results,
  }) {
    return {
      'count': count,
      'next': null,
      'previous': null,
      'loaded_from_joker': true,
      'results':
          results ??
          [
            {'name': 'pikachu', 'url': 'https://pokeapi.co/api/v2/pokemon/25/'},
            {
              'name': 'charmander',
              'url': 'https://pokeapi.co/api/v2/pokemon/4/',
            },
            {
              'name': 'bulbasaur',
              'url': 'https://pokeapi.co/api/v2/pokemon/1/',
            },
          ],
    };
  }

  /// Creates test data for individual Pokemon
  static Map<String, dynamic> createTestPokemonData({
    int id = 25,
    String name = 'pikachu',
    String type = 'electric',
  }) {
    return {
      'id': id,
      'name': name,
      'height': 4,
      'weight': 60,
      'loaded_from_joker': true,
      'sprites': {
        'front_default': 'https://example.com/pokemon/$id.png',
        'back_default': 'https://example.com/pokemon/back/$id.png',
        'front_shiny': null,
        'back_shiny': null,
      },
      'types': [
        {
          'slot': 1,
          'type': {'name': type, 'url': 'https://pokeapi.co/api/v2/type/13/'},
        },
      ],
      'stats': [
        {
          'base_stat': 55,
          'effort': 0,
          'stat': {'name': 'hp', 'url': 'https://pokeapi.co/api/v2/stat/1/'},
        },
        {
          'base_stat': 40,
          'effort': 0,
          'stat': {
            'name': 'attack',
            'url': 'https://pokeapi.co/api/v2/stat/2/',
          },
        },
        {
          'base_stat': 50,
          'effort': 0,
          'stat': {
            'name': 'defense',
            'url': 'https://pokeapi.co/api/v2/stat/3/',
          },
        },
        {
          'base_stat': 90,
          'effort': 2,
          'stat': {'name': 'speed', 'url': 'https://pokeapi.co/api/v2/stat/6/'},
        },
      ],
    };
  }
}

/// Custom matchers for testing Pokemon data
class PokemonMatchers {
  /// Matches Pokemon data that was loaded from Joker
  static Matcher isFromJoker() {
    return predicate<Map<String, dynamic>>(
      (pokemon) => pokemon['loaded_from_joker'] == true,
      'is loaded from Joker',
    );
  }

  /// Matches Pokemon with specific name
  static Matcher hasPokemonName(String expectedName) {
    return predicate<Map<String, dynamic>>(
      (pokemon) => pokemon['name'] == expectedName,
      'has Pokemon name "$expectedName"',
    );
  }

  /// Matches Pokemon list with specific count
  static Matcher hasPokemonCount(int expectedCount) {
    return predicate<Map<String, dynamic>>(
      (pokemonList) => pokemonList['count'] == expectedCount,
      'has Pokemon count of $expectedCount',
    );
  }
}

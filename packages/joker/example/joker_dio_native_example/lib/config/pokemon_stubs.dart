import 'package:joker/joker.dart';

/// Configuration class for setting up Pokemon API stubs using Joker.
///
/// This class provides pre-configured stubs that simulate responses from
/// the Pokemon API. All stubbed responses include a special `loaded_from_joker`
/// flag to clearly indicate they came from Joker and not the real API.
class PokemonStubConfig {
  static const String pokemonApiHost = 'pokeapi.co';

  /// Sets up all Pokemon-related stubs for the example app
  ///
  /// This method ensures clean setup by stopping any previous Joker instance
  /// and starting fresh with new stubs.
  static void setupStubs() {
    // Ensure clean state by stopping any previous instance
    Joker.stop();

    // Start fresh
    Joker.start();
    print(
      '🃏 Starting fresh Joker instance and registering Pokemon API stubs...',
    );

    // Stub Pokemon list endpoint
    _setupPokemonListStubs();

    // Stub individual Pokemon endpoints
    _setupIndividualPokemonStubs();

    print('🃏 Joker: Pokemon API stubs configured successfully!');
    print('🃏 Total stubs registered: ${Joker.stubs.length}');
    print('🃏 Joker.isActive: ${Joker.isActive}');
    print('🃏 All Pokemon data will be loaded from Joker stubs.');

    // Debug: Print all registered stubs
    for (var stub in Joker.stubs) {
      print('🃏 Stub registered: ${stub.name}');
    }
  }

  /// Sets up stubs for Pokemon list endpoints
  static void _setupPokemonListStubs() {
    // Stub for any Pokemon list request (ignores query parameters)
    print(
      '🃏 Setting up Pokemon list stub for host: $pokemonApiHost, path: /api/v2/pokemon',
    );

    Joker.stubJson(
      host: pokemonApiHost,
      path: '/api/v2/pokemon',
      method: 'GET',
      name: 'pokemon-list-any',
      data: {
        'count': 1300,
        'next': 'https://pokeapi.co/api/v2/pokemon?limit=20&offset=0',
        'previous': null,
        'loaded_from_joker': true, // 🃏 Joker identifier
        'results': _generatePokemonList(20, 40),
      },
    );

    print('🃏 Pokemon list stub configured');
  }

  /// Sets up stubs for individual Pokemon endpoints
  static void _setupIndividualPokemonStubs() {
    // Popular Pokemon with detailed data
    final popularPokemon = [
      _createPikachuData(),
      _createCharmanderData(),
      _createBulbasaurData(),
      _createSquirtleData(),
      _createMewtwoData(),
    ];

    for (final pokemon in popularPokemon) {
      // Stub by ID
      Joker.stubJson(
        host: pokemonApiHost,
        path: '/api/v2/pokemon/${pokemon['id']}',
        name: 'pokemon-${pokemon['name']}-by-id',
        data: pokemon,
      );

      // Stub by name
      Joker.stubJson(
        host: pokemonApiHost,
        path: '/api/v2/pokemon/${pokemon['name']}',
        name: 'pokemon-${pokemon['name']}-by-name',
        data: pokemon,
      );
    }

    // Generic stub for any other Pokemon ID (1-151)
    for (int id = 1; id <= 151; id++) {
      if (!popularPokemon.any((p) => p['id'] == id)) {
        Joker.stubJson(
          host: pokemonApiHost,
          path: '/api/v2/pokemon/$id',
          name: 'pokemon-generic-$id',
          data: _createGenericPokemonData(id),
        );
      }
    }
  }

  /// Generates a list of Pokemon for list endpoints
  static List<Map<String, dynamic>> _generatePokemonList(
    int offset,
    int limit,
  ) {
    final pokemonNames = [
      'bulbasaur',
      'ivysaur',
      'venusaur',
      'charmander',
      'charmeleon',
      'charizard',
      'squirtle',
      'wartortle',
      'blastoise',
      'caterpie',
      'metapod',
      'butterfree',
      'weedle',
      'kakuna',
      'beedrill',
      'pidgey',
      'pidgeotto',
      'pidgeot',
      'rattata',
      'raticate',
      'spearow',
      'fearow',
      'ekans',
      'arbok',
      'pikachu',
      'raichu',
      'sandshrew',
      'sandslash',
      'nidoran-f',
      'nidorina',
      'nidoqueen',
      'nidoran-m',
      'nidorino',
      'nidoking',
      'clefairy',
      'clefable',
      'vulpix',
      'ninetales',
      'jigglypuff',
      'wigglytuff',
      'zubat',
      'golbat',
      'oddish',
      'gloom',
      'vileplume',
      'paras',
      'parasect',
      'venonat',
      'venomoth',
      'diglett',
      'dugtrio',
      'meowth',
      'persian',
      'psyduck',
      'golduck',
      'mankey',
      'primeape',
      'growlithe',
      'arcanine',
      'poliwag',
      'poliwhirl',
      'poliwrath',
      'abra',
      'kadabra',
      'alakazam',
      'machop',
      'machoke',
      'machamp',
      'bellsprout',
      'weepinbell',
      'victreebel',
      'tentacool',
      'tentacruel',
      'geodude',
      'graveler',
      'golem',
      'ponyta',
      'rapidash',
      'slowpoke',
      'slowbro',
      'magnemite',
      'magneton',
      'farfetchd',
      'doduo',
      'dodrio',
      'seel',
      'dewgong',
      'grimer',
      'muk',
      'shellder',
      'cloyster',
      'gastly',
      'haunter',
      'gengar',
      'onix',
      'drowzee',
      'hypno',
      'krabby',
      'kingler',
      'voltorb',
    ];

    final results = <Map<String, dynamic>>[];
    for (int i = 0; i < limit && (offset + i) < pokemonNames.length; i++) {
      final index = offset + i;
      final name = pokemonNames[index];
      results.add({
        'name': name,
        'url': 'https://pokeapi.co/api/v2/pokemon/${index + 1}/',
      });
    }
    return results;
  }

  /// Creates detailed Pikachu data
  static Map<String, dynamic> _createPikachuData() {
    return {
      'id': 25,
      'name': 'pikachu',
      'height': 4,
      'weight': 60,
      'loaded_from_joker': true, // 🃏 Joker identifier
      'types': [
        {
          'slot': 1,
          'type': {
            'name': 'electric',
            'url': 'https://pokeapi.co/api/v2/type/13/',
          },
        },
      ],
      'sprites': {
        'front_default':
            'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/25.png',
        'back_default':
            'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/back/25.png',
        'front_shiny':
            'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/shiny/25.png',
        'back_shiny':
            'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/back/shiny/25.png',
      },
      'stats': [
        {
          'base_stat': 35,
          'effort': 0,
          'stat': {'name': 'hp', 'url': 'https://pokeapi.co/api/v2/stat/1/'},
        },
        {
          'base_stat': 55,
          'effort': 0,
          'stat': {
            'name': 'attack',
            'url': 'https://pokeapi.co/api/v2/stat/2/',
          },
        },
        {
          'base_stat': 40,
          'effort': 0,
          'stat': {
            'name': 'defense',
            'url': 'https://pokeapi.co/api/v2/stat/3/',
          },
        },
        {
          'base_stat': 50,
          'effort': 0,
          'stat': {
            'name': 'special-attack',
            'url': 'https://pokeapi.co/api/v2/stat/4/',
          },
        },
        {
          'base_stat': 50,
          'effort': 0,
          'stat': {
            'name': 'special-defense',
            'url': 'https://pokeapi.co/api/v2/stat/5/',
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

  /// Creates detailed Charmander data
  static Map<String, dynamic> _createCharmanderData() {
    return {
      'id': 4,
      'name': 'charmander',
      'height': 6,
      'weight': 85,
      'loaded_from_joker': true, // 🃏 Joker identifier
      'types': [
        {
          'slot': 1,
          'type': {'name': 'fire', 'url': 'https://pokeapi.co/api/v2/type/10/'},
        },
      ],
      'sprites': {
        'front_default':
            'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/4.png',
        'back_default':
            'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/back/4.png',
        'front_shiny':
            'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/shiny/4.png',
        'back_shiny':
            'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/back/shiny/4.png',
      },
      'stats': [
        {
          'base_stat': 39,
          'effort': 0,
          'stat': {'name': 'hp', 'url': 'https://pokeapi.co/api/v2/stat/1/'},
        },
        {
          'base_stat': 52,
          'effort': 0,
          'stat': {
            'name': 'attack',
            'url': 'https://pokeapi.co/api/v2/stat/2/',
          },
        },
        {
          'base_stat': 43,
          'effort': 0,
          'stat': {
            'name': 'defense',
            'url': 'https://pokeapi.co/api/v2/stat/3/',
          },
        },
        {
          'base_stat': 60,
          'effort': 0,
          'stat': {
            'name': 'special-attack',
            'url': 'https://pokeapi.co/api/v2/stat/4/',
          },
        },
        {
          'base_stat': 50,
          'effort': 0,
          'stat': {
            'name': 'special-defense',
            'url': 'https://pokeapi.co/api/v2/stat/5/',
          },
        },
        {
          'base_stat': 65,
          'effort': 1,
          'stat': {'name': 'speed', 'url': 'https://pokeapi.co/api/v2/stat/6/'},
        },
      ],
    };
  }

  /// Creates detailed Bulbasaur data
  static Map<String, dynamic> _createBulbasaurData() {
    return {
      'id': 1,
      'name': 'bulbasaur',
      'height': 7,
      'weight': 69,
      'loaded_from_joker': true, // 🃏 Joker identifier
      'types': [
        {
          'slot': 1,
          'type': {
            'name': 'grass',
            'url': 'https://pokeapi.co/api/v2/type/12/',
          },
        },
        {
          'slot': 2,
          'type': {
            'name': 'poison',
            'url': 'https://pokeapi.co/api/v2/type/4/',
          },
        },
      ],
      'sprites': {
        'front_default':
            'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/1.png',
        'back_default':
            'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/back/1.png',
        'front_shiny':
            'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/shiny/1.png',
        'back_shiny':
            'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/back/shiny/1.png',
      },
      'stats': [
        {
          'base_stat': 45,
          'effort': 0,
          'stat': {'name': 'hp', 'url': 'https://pokeapi.co/api/v2/stat/1/'},
        },
        {
          'base_stat': 49,
          'effort': 0,
          'stat': {
            'name': 'attack',
            'url': 'https://pokeapi.co/api/v2/stat/2/',
          },
        },
        {
          'base_stat': 49,
          'effort': 0,
          'stat': {
            'name': 'defense',
            'url': 'https://pokeapi.co/api/v2/stat/3/',
          },
        },
        {
          'base_stat': 65,
          'effort': 1,
          'stat': {
            'name': 'special-attack',
            'url': 'https://pokeapi.co/api/v2/stat/4/',
          },
        },
        {
          'base_stat': 65,
          'effort': 0,
          'stat': {
            'name': 'special-defense',
            'url': 'https://pokeapi.co/api/v2/stat/5/',
          },
        },
        {
          'base_stat': 45,
          'effort': 0,
          'stat': {'name': 'speed', 'url': 'https://pokeapi.co/api/v2/stat/6/'},
        },
      ],
    };
  }

  /// Creates detailed Squirtle data
  static Map<String, dynamic> _createSquirtleData() {
    return {
      'id': 7,
      'name': 'squirtle',
      'height': 5,
      'weight': 90,
      'loaded_from_joker': true, // 🃏 Joker identifier
      'types': [
        {
          'slot': 1,
          'type': {
            'name': 'water',
            'url': 'https://pokeapi.co/api/v2/type/11/',
          },
        },
      ],
      'sprites': {
        'front_default':
            'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/7.png',
        'back_default':
            'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/back/7.png',
        'front_shiny':
            'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/shiny/7.png',
        'back_shiny':
            'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/back/shiny/7.png',
      },
      'stats': [
        {
          'base_stat': 44,
          'effort': 0,
          'stat': {'name': 'hp', 'url': 'https://pokeapi.co/api/v2/stat/1/'},
        },
        {
          'base_stat': 48,
          'effort': 0,
          'stat': {
            'name': 'attack',
            'url': 'https://pokeapi.co/api/v2/stat/2/',
          },
        },
        {
          'base_stat': 65,
          'effort': 1,
          'stat': {
            'name': 'defense',
            'url': 'https://pokeapi.co/api/v2/stat/3/',
          },
        },
        {
          'base_stat': 50,
          'effort': 0,
          'stat': {
            'name': 'special-attack',
            'url': 'https://pokeapi.co/api/v2/stat/4/',
          },
        },
        {
          'base_stat': 64,
          'effort': 0,
          'stat': {
            'name': 'special-defense',
            'url': 'https://pokeapi.co/api/v2/stat/5/',
          },
        },
        {
          'base_stat': 43,
          'effort': 0,
          'stat': {'name': 'speed', 'url': 'https://pokeapi.co/api/v2/stat/6/'},
        },
      ],
    };
  }

  /// Creates detailed Mewtwo data
  static Map<String, dynamic> _createMewtwoData() {
    return {
      'id': 150,
      'name': 'mewtwo',
      'height': 20,
      'weight': 1220,
      'loaded_from_joker': true, // 🃏 Joker identifier
      'types': [
        {
          'slot': 1,
          'type': {
            'name': 'psychic',
            'url': 'https://pokeapi.co/api/v2/type/14/',
          },
        },
      ],
      'sprites': {
        'front_default':
            'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/150.png',
        'back_default':
            'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/back/150.png',
        'front_shiny':
            'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/shiny/150.png',
        'back_shiny':
            'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/back/shiny/150.png',
      },
      'stats': [
        {
          'base_stat': 106,
          'effort': 0,
          'stat': {'name': 'hp', 'url': 'https://pokeapi.co/api/v2/stat/1/'},
        },
        {
          'base_stat': 110,
          'effort': 0,
          'stat': {
            'name': 'attack',
            'url': 'https://pokeapi.co/api/v2/stat/2/',
          },
        },
        {
          'base_stat': 90,
          'effort': 0,
          'stat': {
            'name': 'defense',
            'url': 'https://pokeapi.co/api/v2/stat/3/',
          },
        },
        {
          'base_stat': 154,
          'effort': 3,
          'stat': {
            'name': 'special-attack',
            'url': 'https://pokeapi.co/api/v2/stat/4/',
          },
        },
        {
          'base_stat': 90,
          'effort': 0,
          'stat': {
            'name': 'special-defense',
            'url': 'https://pokeapi.co/api/v2/stat/5/',
          },
        },
        {
          'base_stat': 130,
          'effort': 0,
          'stat': {'name': 'speed', 'url': 'https://pokeapi.co/api/v2/stat/6/'},
        },
      ],
    };
  }

  /// Creates generic Pokemon data for any ID
  static Map<String, dynamic> _createGenericPokemonData(int id) {
    final names = [
      'bulbasaur', 'ivysaur', 'venusaur', 'charmander', 'charmeleon',
      'charizard', 'squirtle', 'wartortle', 'blastoise', 'caterpie',
      // ... (truncated for brevity, would include all 151)
    ];

    final name = id <= names.length ? names[id - 1] : 'pokemon-$id';

    return {
      'id': id,
      'name': name,
      'height': 5 + (id % 15),
      'weight': 50 + (id % 100),
      'loaded_from_joker': true, // 🃏 Joker identifier
      'types': [
        {
          'slot': 1,
          'type': {
            'name': 'normal',
            'url': 'https://pokeapi.co/api/v2/type/1/',
          },
        },
      ],
      'sprites': {
        'front_default':
            'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/$id.png',
        'back_default':
            'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/back/$id.png',
        'front_shiny': null,
        'back_shiny': null,
      },
      'stats': [
        {
          'base_stat': 45 + (id % 20),
          'effort': 0,
          'stat': {'name': 'hp', 'url': 'https://pokeapi.co/api/v2/stat/1/'},
        },
        {
          'base_stat': 49 + (id % 30),
          'effort': 0,
          'stat': {
            'name': 'attack',
            'url': 'https://pokeapi.co/api/v2/stat/2/',
          },
        },
        {
          'base_stat': 49 + (id % 25),
          'effort': 0,
          'stat': {
            'name': 'defense',
            'url': 'https://pokeapi.co/api/v2/stat/3/',
          },
        },
        {
          'base_stat': 65 + (id % 35),
          'effort': 0,
          'stat': {
            'name': 'special-attack',
            'url': 'https://pokeapi.co/api/v2/stat/4/',
          },
        },
        {
          'base_stat': 65 + (id % 20),
          'effort': 0,
          'stat': {
            'name': 'special-defense',
            'url': 'https://pokeapi.co/api/v2/stat/5/',
          },
        },
        {
          'base_stat': 45 + (id % 40),
          'effort': 0,
          'stat': {'name': 'speed', 'url': 'https://pokeapi.co/api/v2/stat/6/'},
        },
      ],
    };
  }

  /// Clears all Pokemon stubs (but keeps Joker running)
  static void clearStubs() {
    Joker.clearStubs();
    print('🃏 Joker: All Pokemon stubs cleared.');
  }
}

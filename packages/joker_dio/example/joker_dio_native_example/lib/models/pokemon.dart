/// Pokemon model representing the basic Pokemon data from PokeAPI
class Pokemon {
  final int id;
  final String name;
  final int height;
  final int weight;
  final List<PokemonType> types;
  final PokemonSprites sprites;
  final List<PokemonStat> stats;

  /// Indicates if this data was loaded from Joker stubs
  final bool loadedFromJoker;

  const Pokemon({
    required this.id,
    required this.name,
    required this.height,
    required this.weight,
    required this.types,
    required this.sprites,
    required this.stats,
    this.loadedFromJoker = false,
  });

  factory Pokemon.fromJson(Map<String, dynamic> json) {
    return Pokemon(
      id: json['id'] as int,
      name: json['name'] as String,
      height: json['height'] as int,
      weight: json['weight'] as int,
      types: (json['types'] as List)
          .map((e) => PokemonType.fromJson(e as Map<String, dynamic>))
          .toList(),
      sprites: PokemonSprites.fromJson(json['sprites'] as Map<String, dynamic>),
      stats: (json['stats'] as List)
          .map((e) => PokemonStat.fromJson(e as Map<String, dynamic>))
          .toList(),
      loadedFromJoker: json['loaded_from_joker'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'height': height,
      'weight': weight,
      'types': types.map((e) => e.toJson()).toList(),
      'sprites': sprites.toJson(),
      'stats': stats.map((e) => e.toJson()).toList(),
      'loaded_from_joker': loadedFromJoker,
    };
  }

  @override
  String toString() {
    return 'Pokemon(id: $id, name: $name, loadedFromJoker: $loadedFromJoker)';
  }
}

/// Pokemon type information
class PokemonType {
  final int slot;
  final TypeInfo type;

  const PokemonType({required this.slot, required this.type});

  factory PokemonType.fromJson(Map<String, dynamic> json) {
    return PokemonType(
      slot: json['slot'] as int,
      type: TypeInfo.fromJson(json['type'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {'slot': slot, 'type': type.toJson()};
  }
}

/// Type information
class TypeInfo {
  final String name;
  final String url;

  const TypeInfo({required this.name, required this.url});

  factory TypeInfo.fromJson(Map<String, dynamic> json) {
    return TypeInfo(name: json['name'] as String, url: json['url'] as String);
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'url': url};
  }
}

/// Pokemon sprite images
class PokemonSprites {
  final String? frontDefault;
  final String? backDefault;
  final String? frontShiny;
  final String? backShiny;

  const PokemonSprites({
    this.frontDefault,
    this.backDefault,
    this.frontShiny,
    this.backShiny,
  });

  factory PokemonSprites.fromJson(Map<String, dynamic> json) {
    return PokemonSprites(
      frontDefault: json['front_default'] as String?,
      backDefault: json['back_default'] as String?,
      frontShiny: json['front_shiny'] as String?,
      backShiny: json['back_shiny'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'front_default': frontDefault,
      'back_default': backDefault,
      'front_shiny': frontShiny,
      'back_shiny': backShiny,
    };
  }
}

/// Pokemon stat information
class PokemonStat {
  final int baseStat;
  final int effort;
  final StatInfo stat;

  const PokemonStat({
    required this.baseStat,
    required this.effort,
    required this.stat,
  });

  factory PokemonStat.fromJson(Map<String, dynamic> json) {
    return PokemonStat(
      baseStat: json['base_stat'] as int,
      effort: json['effort'] as int,
      stat: StatInfo.fromJson(json['stat'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {'base_stat': baseStat, 'effort': effort, 'stat': stat.toJson()};
  }
}

/// Stat information
class StatInfo {
  final String name;
  final String url;

  const StatInfo({required this.name, required this.url});

  factory StatInfo.fromJson(Map<String, dynamic> json) {
    return StatInfo(name: json['name'] as String, url: json['url'] as String);
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'url': url};
  }
}

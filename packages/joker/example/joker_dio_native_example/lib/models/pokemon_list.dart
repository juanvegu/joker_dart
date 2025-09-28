/// Model for Pokemon list response from PokeAPI
class PokemonListResponse {
  final int count;
  final String? next;
  final String? previous;
  final List<PokemonListItem> results;

  /// Indicates if this data was loaded from Joker stubs
  final bool loadedFromJoker;

  const PokemonListResponse({
    required this.count,
    this.next,
    this.previous,
    required this.results,
    this.loadedFromJoker = false,
  });

  factory PokemonListResponse.fromJson(Map<String, dynamic> json) {
    return PokemonListResponse(
      count: json['count'] as int,
      next: json['next'] as String?,
      previous: json['previous'] as String?,
      results: (json['results'] as List)
          .map((e) => PokemonListItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      loadedFromJoker: json['loaded_from_joker'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'count': count,
      'next': next,
      'previous': previous,
      'results': results.map((e) => e.toJson()).toList(),
      'loaded_from_joker': loadedFromJoker,
    };
  }

  @override
  String toString() {
    return 'PokemonListResponse(count: $count, results: ${results.length}, loadedFromJoker: $loadedFromJoker)';
  }
}

/// Individual item in Pokemon list
class PokemonListItem {
  final String name;
  final String url;

  const PokemonListItem({required this.name, required this.url});

  factory PokemonListItem.fromJson(Map<String, dynamic> json) {
    return PokemonListItem(
      name: json['name'] as String,
      url: json['url'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'url': url};
  }

  /// Extracts the Pokemon ID from the URL
  int get id {
    final parts = url.split('/');
    final idString = parts[parts.length - 2]; // Last part is empty, so -2
    return int.parse(idString);
  }

  @override
  String toString() {
    return 'PokemonListItem(name: $name, id: $id)';
  }
}

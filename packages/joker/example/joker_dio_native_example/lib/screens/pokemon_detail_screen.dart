import 'package:flutter/material.dart';
import '../services/pokemon_service.dart';
import '../models/pokemon.dart';
import '../managers/joker_manager.dart';

/// Detail screen that shows comprehensive Pokemon information
///
/// This screen demonstrates:
/// - Loading individual Pokemon data via Joker + Dio
/// - Displaying Pokemon stats, types, and sprites
/// - Clear indication when data comes from Joker stubs
class PokemonDetailScreen extends StatefulWidget {
  final int pokemonId;
  final String pokemonName;

  const PokemonDetailScreen({
    super.key,
    required this.pokemonId,
    required this.pokemonName,
  });

  @override
  State<PokemonDetailScreen> createState() => _PokemonDetailScreenState();
}

class _PokemonDetailScreenState extends State<PokemonDetailScreen> {
  final PokemonService _pokemonService = PokemonService();
  final JokerManager _jokerManager = JokerManager();

  Pokemon? _pokemon;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPokemon();
  }

  @override
  void dispose() {
    _pokemonService.dispose();
    super.dispose();
  }

  Future<void> _loadPokemon() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final pokemon = await _pokemonService.getPokemon(widget.pokemonId);

      setState(() {
        _pokemon = pokemon;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.pokemonName.toUpperCase()),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          // Status indicator
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Chip(
              label: Text(
                _jokerManager.isJokerActive ? '🃏 Joker' : '🌐 Real API',
                style: const TextStyle(fontSize: 12),
              ),
              backgroundColor: _jokerManager.isJokerActive
                  ? Colors.orange
                  : Colors.green,
              labelStyle: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading Pokemon details...'),
            SizedBox(height: 8),
            Text(
              '🃏 Powered by Joker + Dio',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Error loading Pokemon',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _loadPokemon, child: const Text('Retry')),
          ],
        ),
      );
    }

    final pokemon = _pokemon!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (pokemon.loadedFromJoker)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.orange),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '🃏 This Pokemon data was loaded from Joker stubs!',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Pokemon basic info card
          _buildBasicInfoCard(pokemon),
          const SizedBox(height: 16),

          // Pokemon sprites
          _buildSpritesCard(pokemon),
          const SizedBox(height: 16),

          // Pokemon types
          _buildTypesCard(pokemon),
          const SizedBox(height: 16),

          // Pokemon stats
          _buildStatsCard(pokemon),
        ],
      ),
    );
  }

  Widget _buildBasicInfoCard(Pokemon pokemon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.info, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  'Basic Information',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildInfoItem('ID', '#${pokemon.id}')),
                Expanded(
                  child: _buildInfoItem('Name', pokemon.name.toUpperCase()),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem('Height', '${pokemon.height / 10} m'),
                ),
                Expanded(
                  child: _buildInfoItem('Weight', '${pokemon.weight / 10} kg'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildSpritesCard(Pokemon pokemon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.image, color: Colors.green),
                const SizedBox(width: 8),
                Text(
                  'Pokemon Sprites',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if (pokemon.sprites.frontDefault != null)
                  _buildSpriteImage(pokemon.sprites.frontDefault!, 'Front'),
                if (pokemon.sprites.backDefault != null)
                  _buildSpriteImage(pokemon.sprites.backDefault!, 'Back'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpriteImage(String url, String label) {
    return Column(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              url,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return const Center(
                  child: Icon(
                    Icons.image_not_supported,
                    size: 40,
                    color: Colors.grey,
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildTypesCard(Pokemon pokemon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.category, color: Colors.purple),
                const SizedBox(width: 8),
                Text('Types', style: Theme.of(context).textTheme.titleLarge),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: pokemon.types.map((type) {
                return Chip(
                  label: Text(
                    type.type.name.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  backgroundColor: _getTypeColor(type.type.name),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard(Pokemon pokemon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.bar_chart, color: Colors.orange),
                const SizedBox(width: 8),
                Text(
                  'Base Stats',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...pokemon.stats.map((stat) => _buildStatBar(stat)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatBar(PokemonStat stat) {
    final statName = stat.stat.name
        .replaceAll('-', ' ')
        .split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                statName,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              Text(
                '${stat.baseStat}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: stat.baseStat / 200.0, // Max stat is usually around 200
            backgroundColor: Colors.grey.shade300,
            valueColor: AlwaysStoppedAnimation<Color>(
              _getStatColor(stat.baseStat),
            ),
          ),
        ],
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'fire':
        return Colors.red;
      case 'water':
        return Colors.blue;
      case 'grass':
        return Colors.green;
      case 'electric':
        return Colors.yellow.shade700;
      case 'psychic':
        return Colors.pink;
      case 'ice':
        return Colors.cyan;
      case 'dragon':
        return Colors.indigo;
      case 'poison':
        return Colors.purple;
      case 'ground':
        return Colors.brown;
      case 'flying':
        return Colors.lightBlue;
      case 'bug':
        return Colors.lightGreen;
      default:
        return Colors.grey;
    }
  }

  Color _getStatColor(int value) {
    if (value >= 100) return Colors.green;
    if (value >= 70) return Colors.orange;
    return Colors.red;
  }
}

import 'package:flutter/material.dart';
import '../services/pokemon_service.dart';
import '../models/pokemon_list.dart';
import '../models/pokemon.dart';

/// Main Pokemon screen that demonstrates Joker + Dio integration
class PokemonScreen extends StatefulWidget {
  const PokemonScreen({super.key});

  @override
  State<PokemonScreen> createState() => _PokemonScreenState();
}

class _PokemonScreenState extends State<PokemonScreen> {
  final PokemonService _service = PokemonService();
  List<PokemonListItem> _pokemonList = [];
  bool _isLoading = true;
  String? _error;
  Pokemon? _selectedPokemon;
  bool _loadingPokemonDetail = false;

  @override
  void initState() {
    super.initState();
    _loadPokemonList();
  }

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }

  Future<void> _loadPokemonList() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final response = await _service.getPokemonList(limit: 20);

      setState(() {
        _pokemonList = response.results;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleJokerMode() async {
    try {
      print(
        '🔄 Toggling Joker mode from ${_service.isJokerActive ? "JOKER" : "REAL API"}',
      );

      // Clear current state
      _selectedPokemon = null;
      setState(() {
        _error = null;
        _isLoading = true;
      });

      // Toggle the mode
      if (_service.isJokerActive) {
        _service.disableJoker();
      } else {
        _service.enableJoker();
      }

      print(
        '🔄 Mode toggled to ${_service.isJokerActive ? "JOKER" : "REAL API"}',
      );

      // Wait a brief moment to ensure state is settled
      await Future.delayed(const Duration(milliseconds: 100));

      // Reload data with new mode
      await _loadPokemonList();

      print('✅ Mode toggle completed successfully');
    } catch (e) {
      print('❌ Error during mode toggle: $e');

      setState(() {
        _error = 'Failed to switch API mode: $e';
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error toggling Joker mode: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _loadPokemonDetail(int id) async {
    try {
      setState(() {
        _loadingPokemonDetail = true;
        _selectedPokemon = null;
      });

      final pokemon = await _service.getPokemon(id);

      setState(() {
        _selectedPokemon = pokemon;
        _loadingPokemonDetail = false;
      });
    } catch (e) {
      setState(() {
        _loadingPokemonDetail = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading Pokemon details: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🃏 Joker + Dio Pokemon'),
        backgroundColor: _service.isJokerActive ? Colors.orange : Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          // Mode indicator
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: Chip(
                label: Text(
                  _service.isJokerActive ? '🃏 Joker Mode' : '🌐 Real API',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                backgroundColor: _service.isJokerActive
                    ? Colors.orange.shade700
                    : Colors.blue.shade700,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Toggle button and status
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: _service.isJokerActive
                ? Colors.orange.shade50
                : Colors.blue.shade50,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _service.isJokerActive
                          ? '🃏 Joker Mode Active'
                          : '🌐 Real API Mode',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _service.isJokerActive
                            ? Colors.orange.shade800
                            : Colors.blue.shade800,
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      onPressed: _toggleJokerMode,
                      icon: Icon(
                        _service.isJokerActive ? Icons.api : Icons.gamepad,
                      ),
                      label: Text(
                        _service.isJokerActive
                            ? 'Use Real API'
                            : 'Use Joker Stubs',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _service.isJokerActive
                            ? Colors.blue
                            : Colors.orange,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _service.isJokerActive
                      ? 'HTTP requests are being intercepted and stubbed'
                      : 'HTTP requests are going to the real Pokemon API',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),

          // Content area
          Expanded(
            child: Row(
              children: [
                // Pokemon list (left side)
                Expanded(flex: 1, child: _buildPokemonList()),

                // Pokemon detail (right side)
                Expanded(flex: 1, child: _buildPokemonDetail()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPokemonList() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading Pokemon...'),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, color: Colors.red, size: 64),
            const SizedBox(height: 16),
            Text('Error: $_error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadPokemonList,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Pokemon List (${_pokemonList.length})',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _pokemonList.length,
            itemBuilder: (context, index) {
              final pokemon = _pokemonList[index];
              return ListTile(
                title: Text(pokemon.name.toUpperCase()),
                subtitle: Text('ID: ${pokemon.id}'),
                leading: const CircleAvatar(
                  child: Icon(Icons.catching_pokemon),
                ),
                onTap: () => _loadPokemonDetail(pokemon.id),
                selected: _selectedPokemon?.id == pokemon.id,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPokemonDetail() {
    if (_loadingPokemonDetail) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading Pokemon details...'),
          ],
        ),
      );
    }

    if (_selectedPokemon == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.catching_pokemon, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('Select a Pokemon to see details'),
          ],
        ),
      );
    }

    final pokemon = _selectedPokemon!;
    final isFromJoker = pokemon.loadedFromJoker;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Source indicator
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isFromJoker
                  ? Colors.orange.shade100
                  : Colors.green.shade100,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isFromJoker ? Colors.orange : Colors.green,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  isFromJoker ? Icons.gamepad : Icons.api,
                  color: isFromJoker ? Colors.orange : Colors.green,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    isFromJoker
                        ? '🃏 Loaded from Joker stub'
                        : '🌐 Loaded from real API',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isFromJoker
                          ? Colors.orange.shade800
                          : Colors.green.shade800,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Pokemon details
          Text(
            pokemon.name.toUpperCase(),
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          Text('ID: ${pokemon.id}'),
          Text('Height: ${pokemon.height} decimetres'),
          Text('Weight: ${pokemon.weight} hectograms'),

          const SizedBox(height: 16),

          if (pokemon.sprites.frontDefault != null)
            Image.network(
              pokemon.sprites.frontDefault!,
              height: 150,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.image_not_supported, size: 100);
              },
            ),
        ],
      ),
    );
  }
}

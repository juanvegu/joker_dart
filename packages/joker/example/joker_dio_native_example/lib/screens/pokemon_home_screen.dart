import 'package:flutter/material.dart';
import '../services/pokemon_service.dart';
import '../models/pokemon_list.dart';
import '../managers/joker_manager.dart';
import 'pokemon_detail_screen.dart';

/// Home screen that displays a list of Pokemon fetched using Joker + Dio
///
/// This screen demonstrates:
/// - How Joker intercepts HTTP requests made by Dio in native environments
/// - Loading states and error handling
/// - Clear indication when data comes from Joker stubs vs real API
class PokemonHomeScreen extends StatefulWidget {
  const PokemonHomeScreen({super.key});

  @override
  State<PokemonHomeScreen> createState() => _PokemonHomeScreenState();
}

class _PokemonHomeScreenState extends State<PokemonHomeScreen> {
  final PokemonService _pokemonService = PokemonService();
  final ScrollController _scrollController = ScrollController();
  final JokerManager _jokerManager = JokerManager();

  List<PokemonListItem> _pokemonList = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  String? _error;
  int _currentOffset = 0;
  static const int _limit = 20;
  bool _hasJokerIndicator = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _jokerManager.addListener(_onJokerStateChanged);
    // Start with real API calls - Joker disabled by default
    // _jokerManager.enableJoker(); // Commented out to test real API first
    _loadInitialPokemon();
  }

  void _onJokerStateChanged() {
    setState(() {
      _hasJokerIndicator = _jokerManager.isJokerActive;
    });
    // Reload data when Joker state changes
    _refreshPokemon();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _pokemonService.dispose();
    _jokerManager.removeListener(_onJokerStateChanged);
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMorePokemon();
    }
  }

  Future<void> _loadInitialPokemon() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final response = await _pokemonService.getPokemonList(
        limit: _limit,
        offset: 0,
      );

      setState(() {
        _pokemonList = response.results;
        _currentOffset = _limit;
        _isLoading = false;
        _hasJokerIndicator = response.loadedFromJoker;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMorePokemon() async {
    if (_isLoadingMore) return;

    try {
      setState(() {
        _isLoadingMore = true;
      });

      final response = await _pokemonService.getPokemonList(
        limit: _limit,
        offset: _currentOffset,
      );

      setState(() {
        _pokemonList.addAll(response.results);
        _currentOffset += _limit;
        _isLoadingMore = false;
        // Update Joker indicator if this batch was from Joker
        if (response.loadedFromJoker) {
          _hasJokerIndicator = true;
        }
      });
    } catch (e) {
      setState(() {
        _isLoadingMore = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load more Pokemon: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _refreshPokemon() async {
    _currentOffset = 0;
    await _loadInitialPokemon();
  }

  void _navigateToPokemonDetail(PokemonListItem pokemon) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PokemonDetailScreen(
          pokemonId: pokemon.id,
          pokemonName: pokemon.name,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🃏 Joker + Dio Pokemon'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          // Joker toggle switch
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _jokerManager.isJokerActive ? '🃏' : '🌐',
                  style: const TextStyle(fontSize: 16),
                ),
                Switch(
                  value: _jokerManager.isJokerActive,
                  onChanged: (value) {
                    _jokerManager.toggleJoker();
                  },
                  activeColor: Colors.orange,
                ),
              ],
            ),
          ),
          if (_hasJokerIndicator)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Chip(
                label: Text('Joker', style: TextStyle(fontSize: 12)),
                backgroundColor: Colors.orange,
                labelStyle: TextStyle(
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
            Text('Loading Pokemon...'),
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
            ElevatedButton(
              onPressed: _loadInitialPokemon,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Status banner
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _jokerManager.isJokerActive
                ? Colors.orange.shade100
                : Colors.green.shade100,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _jokerManager.isJokerActive ? Colors.orange : Colors.green,
            ),
          ),
          child: Row(
            children: [
              Icon(
                _jokerManager.isJokerActive ? Icons.bug_report : Icons.cloud,
                color: _jokerManager.isJokerActive
                    ? Colors.orange
                    : Colors.green,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _jokerManager.isJokerActive
                      ? '🃏 Using Joker stubs - Instant offline responses!'
                      : '🌐 Using real PokeAPI - Live data from internet',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _jokerManager.isJokerActive
                        ? Colors.orange
                        : Colors.green,
                  ),
                ),
              ),
              Icon(
                _jokerManager.isJokerActive ? Icons.offline_bolt : Icons.wifi,
                color: _jokerManager.isJokerActive
                    ? Colors.orange
                    : Colors.green,
                size: 20,
              ),
            ],
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _refreshPokemon,
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(8),
              itemCount: _pokemonList.length + (_isLoadingMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index >= _pokemonList.length) {
                  return const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final pokemon = _pokemonList[index];
                return _buildPokemonCard(pokemon);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPokemonCard(PokemonListItem pokemon) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          child: Text(
            '#${pokemon.id}',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
        title: Text(
          pokemon.name.toUpperCase(),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('Pokemon ID: ${pokemon.id}'),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () => _navigateToPokemonDetail(pokemon),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../services/simple_pokemon_service.dart';
import '../models/pokemon_list.dart';

/// Simple test screen to verify Dio works without Joker
class SimpleTestScreen extends StatefulWidget {
  const SimpleTestScreen({super.key});

  @override
  State<SimpleTestScreen> createState() => _SimpleTestScreenState();
}

class _SimpleTestScreenState extends State<SimpleTestScreen> {
  final SimplePokemonService _service = SimplePokemonService();
  List<PokemonListItem> _pokemon = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPokemon();
  }

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }

  Future<void> _loadPokemon() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final response = await _service.getPokemonList(limit: 10);

      setState(() {
        _pokemon = response.results;
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
        title: const Text('Simple Dio Test'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
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
            Text('Testing Dio connection...'),
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
            Text('Error:', style: Theme.of(context).textTheme.headlineSmall),
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

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          color: Colors.green.shade100,
          child: const Text(
            '✅ Dio is working! Real API calls successful',
            style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _pokemon.length,
            itemBuilder: (context, index) {
              final pokemon = _pokemon[index];
              return ListTile(
                title: Text(pokemon.name.toUpperCase()),
                subtitle: Text('ID: ${pokemon.id}'),
                leading: const Icon(Icons.catching_pokemon),
              );
            },
          ),
        ),
      ],
    );
  }
}

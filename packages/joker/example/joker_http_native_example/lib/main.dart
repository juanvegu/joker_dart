import 'package:flutter/material.dart';
import 'package:joker/joker.dart';
import 'joker_config.dart';
import 'api_service.dart';
import 'models.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Joker HTTP Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const JokerDemoPage(),
    );
  }
}

class JokerDemoPage extends StatefulWidget {
  const JokerDemoPage({super.key});

  @override
  State<JokerDemoPage> createState() => _JokerDemoPageState();
}

class _JokerDemoPageState extends State<JokerDemoPage> {
  final JsonPlaceholderService _apiService = JsonPlaceholderService();
  bool _isJokerActive = false;
  bool _isLoading = false;
  List<Post> _posts = [];
  List<User> _users = [];
  String _status = 'Joker no está activo';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Joker HTTP Example'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [Switch(value: _isJokerActive, onChanged: _toggleJoker)],
      ),
      body: Column(
        children: [
          // Panel de control
          Card(
            margin: const EdgeInsets.all(16.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Estado de Joker',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8.0),
                  Text(_status),
                  const SizedBox(height: 16.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: _isLoading ? null : _loadPosts,
                        child: const Text('Cargar Posts'),
                      ),
                      ElevatedButton(
                        onPressed: _isLoading ? null : _loadUsers,
                        child: const Text('Cargar Usuarios'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Indicador de carga
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
          // Lista de contenido
          Expanded(child: _buildContent()),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_posts.isNotEmpty) {
      return ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: _posts.length,
        itemBuilder: (context, index) {
          final post = _posts[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 8.0),
            child: ListTile(
              title: Text(
                post.title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                post.body,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              leading: CircleAvatar(child: Text(post.id.toString())),
              trailing: Text('Usuario ${post.userId}'),
            ),
          );
        },
      );
    }

    if (_users.isNotEmpty) {
      return ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: _users.length,
        itemBuilder: (context, index) {
          final user = _users[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 8.0),
            child: ListTile(
              title: Text(user.name),
              subtitle: Text(user.email),
              leading: CircleAvatar(child: Text(user.id.toString())),
              trailing: Text('@${user.username}'),
            ),
          );
        },
      );
    }

    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.info_outline, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Presiona un botón para cargar datos',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          SizedBox(height: 8),
          Text(
            'Activa Joker para ver respuestas simuladas',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  void _toggleJoker(bool value) {
    setState(() {
      _isJokerActive = value;
      if (value) {
        Joker.start();
        JokerConfiguration.setupStubs();
        _status = '✅ Joker activo - Interceptando requests';
      } else {
        Joker.stop();
        _status = '❌ Joker inactivo - Requests reales';
      }
    });
  }

  Future<void> _loadPosts() async {
    setState(() {
      _isLoading = true;
      _users = [];
    });

    try {
      final posts = await _apiService.getPosts();
      setState(() {
        _posts = posts;
      });
    } catch (e) {
      _showError('Error cargando posts: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
      _posts = [];
    });

    try {
      final users = await _apiService.getUsers();
      setState(() {
        _users = users;
      });
    } catch (e) {
      _showError('Error cargando usuarios: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }
}

import 'package:joker/joker.dart';

/// Configuración de stubs para demostrar las capacidades de Joker
/// con la API de JSONPlaceholder
class JokerConfiguration {
  /// Configura todos los stubs para simular la API de JSONPlaceholder
  static void setupStubs() {
    // Stub para obtener todos los posts
    Joker.stubJsonArray(
      host: 'jsonplaceholder.typicode.com',
      path: '/posts',
      method: 'GET',
      data: _mockPosts,
      name: 'Get all posts',
      delay: const Duration(milliseconds: 500), // Simula latencia de red
    );

    // Stub para obtener un post específico
    Joker.stubJson(
      host: 'jsonplaceholder.typicode.com',
      path: '/posts/1',
      method: 'GET',
      data: _mockPosts[0],
      name: 'Get post 1',
      delay: const Duration(milliseconds: 300),
    );

    // Stub para obtener todos los usuarios
    Joker.stubJsonArray(
      host: 'jsonplaceholder.typicode.com',
      path: '/users',
      method: 'GET',
      data: _mockUsers,
      name: 'Get all users',
      delay: const Duration(milliseconds: 400),
    );

    // Stub para obtener un usuario específico
    Joker.stubJson(
      host: 'jsonplaceholder.typicode.com',
      path: '/users/1',
      method: 'GET',
      data: _mockUsers[0],
      name: 'Get user 1',
      delay: const Duration(milliseconds: 200),
    );

    // Stub para obtener comentarios de un post
    Joker.stubJsonArray(
      host: 'jsonplaceholder.typicode.com',
      path: '/posts/1/comments',
      method: 'GET',
      data: _mockComments,
      name: 'Get post 1 comments',
      delay: const Duration(milliseconds: 350),
    );

    // Stub para crear un nuevo post
    Joker.stubJson(
      host: 'jsonplaceholder.typicode.com',
      path: '/posts',
      method: 'POST',
      statusCode: 201,
      data: {
        'id': 101,
        'userId': 1,
        'title': 'Nuevo post creado',
        'body': 'Este es el contenido del nuevo post creado mediante Joker.',
      },
      name: 'Create new post',
      delay: const Duration(milliseconds: 600),
    );

    // Stub para actualizar un post
    Joker.stubJson(
      host: 'jsonplaceholder.typicode.com',
      path: '/posts/1',
      method: 'PUT',
      data: {
        'id': 1,
        'userId': 1,
        'title': 'Post actualizado',
        'body': 'Este post ha sido actualizado usando Joker.',
      },
      name: 'Update post 1',
      delay: const Duration(milliseconds: 400),
    );

    // Stub para eliminar un post
    Joker.stubJson(
      host: 'jsonplaceholder.typicode.com',
      path: '/posts/1',
      method: 'DELETE',
      data: {},
      name: 'Delete post 1',
      delay: const Duration(milliseconds: 300),
    );
  }

  /// Datos de ejemplo para posts
  static final List<Map<String, dynamic>> _mockPosts = [
    {
      'id': 1,
      'userId': 1,
      'title':
          'sunt aut facere repellat provident occaecati excepturi optio reprehenderit',
      'body':
          'quia et suscipit\nsuscipit recusandae consequuntur expedita et cum\nreprehenderit molestiae ut ut quas totam\nnostrum rerum est autem sunt rem eveniet architecto',
    },
    {
      'id': 2,
      'userId': 1,
      'title': 'qui est esse',
      'body':
          'est rerum tempore vitae\nsequi sint nihil reprehenderit dolor beatae ea dolores neque\nfugiat blanditiis voluptate porro vel nihil molestiae ut reiciendis\nqui aperiam non debitis possimus qui neque nisi nulla',
    },
    {
      'id': 3,
      'userId': 1,
      'title': 'ea molestias quasi exercitationem repellat qui ipsa sit aut',
      'body':
          'et iusto sed quo iure\nvoluptatem occaecati omnis eligendi aut ad\nvoluptatem doloribus vel accusantium quis pariatur\nmolestiae porro eius odio et labore et velit aut',
    },
    {
      'id': 4,
      'userId': 2,
      'title': 'eum et est occaecati',
      'body':
          'ullam et saepe reiciendis voluptatem adipisci\nsit amet autem assumenda provident rerum culpa\nquis hic commodi nesciunt rem tenetur doloremque ipsam iure\nquis sunt voluptatem rerum illo velit',
    },
    {
      'id': 5,
      'userId': 2,
      'title': 'nesciunt quas odio',
      'body':
          'repudiandae veniam quaerat sunt sed\nalias aut fugiat sit autem sed est\nvoluptatem omnis possimus esse voluptatibus quis\nest aut tenetur dolor neque',
    },
  ];

  /// Datos de ejemplo para usuarios
  static final List<Map<String, dynamic>> _mockUsers = [
    {
      'id': 1,
      'name': 'Leanne Graham',
      'username': 'Bret',
      'email': 'Sincere@april.biz',
    },
    {
      'id': 2,
      'name': 'Ervin Howell',
      'username': 'Antonette',
      'email': 'Shanna@melissa.tv',
    },
    {
      'id': 3,
      'name': 'Clementine Bauch',
      'username': 'Samantha',
      'email': 'Nathan@yesenia.net',
    },
  ];

  /// Datos de ejemplo para comentarios
  static final List<Map<String, dynamic>> _mockComments = [
    {
      'id': 1,
      'postId': 1,
      'name': 'id labore ex et quam laborum',
      'email': 'Eliseo@gardner.biz',
      'body':
          'laudantium enim quasi est quidem magnam voluptate ipsam eos\ntempora quo necessitatibus\ndolor quam autem quasi\nreiciendis et nam sapiente accusantium',
    },
    {
      'id': 2,
      'postId': 1,
      'name': 'quo vero reiciendis velit similique earum',
      'email': 'Jayne_Kuhic@sydney.com',
      'body':
          'est natus enim nihil est dolore omnis voluptatem numquam\net omnis occaecati quod ullam at\nvoluptatem error expedita pariatur\nnihil sint nostrum voluptatem reiciendis et',
    },
    {
      'id': 3,
      'postId': 1,
      'name': 'odio adipisci rerum aut animi',
      'email': 'Nikita@garfield.biz',
      'body':
          'quia molestiae reprehenderit quasi aspernatur\naut expedita occaecati aliquam eveniet laudantium\nomnis quibusdam delectus saepe quia accusamus maiores nam est\ncum et ducimus et vero voluptates excepturi deleniti ratione',
    },
  ];
}

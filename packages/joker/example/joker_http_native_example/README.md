# Joker HTTP Native Example - Testing Guide

Este proyecto de ejemplo demuestra como usar Joker para testear aplicaciones Flutter que consumen APIs HTTP usando la API de [JSONPlaceholder](https://jsonplaceholder.typicode.com/).

## Estructura del Proyecto

```plaintext
lib/
├── main.dart              # Aplicación principal con UI Flutter
├── models.dart            # Modelos de datos (Post, User, Comment)
├── api_service.dart       # Servicio para consumir JSONPlaceholder API
└── joker_config.dart      # Configuración de stubs de Joker

test/
├── models_test.dart       # Tests unitarios para modelos de datos
├── api_service_test.dart  # Tests de servicio API (real y mock)
├── integration_test.dart  # Tests de integración end-to-end
└── widget_test.dart       # Tests de interfaz de usuario
```

## Funcionalidades de Testing Implementadas

### 1. Tests Unitarios de Modelos (`test/models_test.dart`)

- ✅ **Serialización/Deserialización JSON**: Valida que los modelos `Post`, `User`, y `Comment` se conviertan correctamente entre objetos Dart y JSON
- ✅ **Manejo de Datos Especiales**: Testa caracteres especiales, emojis, y contenido multilinea
- ✅ **Validación de Errores**: Verifica que se lancen excepciones apropiadas con datos inválidos

### 2. Tests del Servicio API (`test/api_service_test.dart`)

- ✅ **API Real vs Mock**: Compara respuestas de la API real de JSONPlaceholder con stubs de Joker
- ✅ **Rendimiento**: Mide y compara la velocidad entre requests reales y simulados
- ✅ **Manejo de Errores**: Testa scenarios de error y timeout
- ✅ **Consistencia de Datos**: Valida que los stubs mantengan la misma estructura que la API real

### 3. Tests de Integración (`test/integration_test.dart`)

- ⚠️ **Flujo End-to-End**: Tests completos de carga de posts, users y comentarios
- ⚠️ **Requests Concurrentes**: Valida múltiples requests simultáneos
- ⚠️ **Cambio de Estado**: Testa el switch entre API real y Joker stubs
- ⚠️ **Validación de Schema**: Verifica que todos los datos cumplan el schema esperado

### 4. Tests de UI/Widget (`test/widget_test.dart`)

- ⚠️ **Interfaz de Usuario**: Tests de la aplicación Flutter completa
- ⚠️ **Interacciones**: Testa botones, switches, y navegación
- ⚠️ **Estados de Carga**: Valida indicadores de progreso y manejo de errores
- ⚠️ **Accesibilidad**: Verifica compatibilidad con lectores de pantalla

### Nota: ⚠️ indica tests que necesitan ajustes para coincidir con el UI actual

## Comandos de Testing

### Ejecutar tests específicos

```bash
# Solo tests de modelos (✅ FUNCIONAN)
flutter test test/models_test.dart

# Solo tests de API service (✅ FUNCIONAN)
flutter test test/api_service_test.dart

# Solo tests de integración (⚠️ necesitan ajustes)
flutter test test/integration_test.dart

# Solo tests de widgets (⚠️ necesitan ajustes)
flutter test test/widget_test.dart
```

- **GET /users/1** - Usuario específico
- **GET /posts/1/comments** - Comentarios de una publicación
- **POST /posts** - Crear nueva publicación
- **PUT /posts/1** - Actualizar publicación
- **DELETE /posts/1** - Eliminar publicación

### Funcionalidades de Joker

- ✅ Activación/desactivación en tiempo real
- ⏱️ Simulación de latencia de red
- 📊 Manejo de diferentes códigos de estado HTTP
- 🔄 Comparación entre respuestas reales vs simuladas

## Uso

### 1. Instalar dependencias

```bash
flutter pub get
```

### 2. Ejecutar la aplicación

```bash
flutter run
```

### 3. Probar las funcionalidades

1. **Sin Joker (requests reales):**
   - Deja el switch desactivado
   - Presiona "Cargar Posts" o "Cargar Usuarios"
   - Verás datos reales de la API JSONPlaceholder

2. **Con Joker (respuestas simuladas):**
   - Activa el switch de Joker
   - Presiona "Cargar Posts" o "Cargar Usuarios"
   - Verás datos simulados con latencia artificial

## Cómo Funciona

### 1. Configuración de Stubs

```dart
// Ejemplo de stub para GET /posts
Joker.stubJson(
  host: 'jsonplaceholder.typicode.com',
  path: '/posts',
  method: 'GET',
  data: mockPostsData,
  delay: Duration(milliseconds: 500),
);
```

### 2. Uso del Servicio API

```dart
class JsonPlaceholderService {
  Future<List<Post>> getPosts() async {
    // Este request será interceptado por Joker cuando esté activo
    final response = await http.get(Uri.parse('$baseUrl/posts'));
    // ... procesamiento normal
  }
}
```

### 3. Control de Interceptación

```dart
// Activar Joker
Joker.start();
JokerConfiguration.setupStubs();

// Desactivar Joker
Joker.stop();
```

## Beneficios Demostrados

### Para Desarrollo

- **Desarrollo offline**: Continúa trabajando sin conexión a internet
- **Datos consistentes**: Siempre los mismos datos para desarrollo
- **Respuestas rápidas**: No dependes de la velocidad de la API externa
- **Control total**: Simula diferentes escenarios (errores, demoras, etc.)

### Para Testing

- **Pruebas predecibles**: Datos conocidos y controlados
- **Aislamiento**: No dependes de servicios externos
- **Simulación de errores**: Prueba manejo de errores fácilmente
- **Performance**: Tests más rápidos sin network I/O

## Recursos Adicionales

- [Documentación de Joker](../../README.md)
- [JSONPlaceholder API](https://jsonplaceholder.typicode.com/)
- [Flutter HTTP Package](https://pub.dev/packages/http)

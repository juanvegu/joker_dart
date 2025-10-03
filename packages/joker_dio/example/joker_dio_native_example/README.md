# 🃏 Joker + Dio Native Example

Este ejemplo demuestra cómo usar **Joker** (core) con **Dio** en aplicaciones nativas Flutter para interceptar y falsificar respuestas HTTP de la PokeAPI.

## 🎯 Propósito del Ejemplo

Este es un ejemplo **NATIVO** que muestra:

- ✅ Cómo usar `joker` core para interceptar requests HTTP
- ✅ Integración con `dio` como cliente HTTP
- ✅ Stubs de respuestas que claramente indican que vienen de Joker
- ✅ Interfaz Flutter que consume la PokeAPI (real o stubeada)
- ❌ **NO** usa `joker_dio` (esa librería es solo para web)

## 🏗️ Arquitectura

```plaintext
┌─────────────────────┐
│   Flutter App       │
│                     │
├─────────────────────┤
│   PokemonService    │
│   (usa Dio)         │
│                     │
├─────────────────────┤
│   Dio HTTP Client   │
│                     │
├─────────────────────┤
│   Joker Core        │ ← Intercepción a nivel HttpClient
│   (HttpOverrides)   │
│                     │
├─────────────────────┤
│   HttpClient        │
│   (Dart native)     │
│                     │
└─────────────────────┘
```

## 🚀 Características

### 🃏 Integración con Joker Core

- **Automática**: Joker intercepta a nivel de `HttpClient`, por lo que funciona transparentemente con Dio
- **Sin configuración especial**: Solo necesitas llamar `Joker.start()` antes de hacer requests
- **Indicadores visuales**: La app muestra claramente cuando los datos vienen de Joker stubs

### 📱 Funcionalidades de la App

- **Lista de Pokemon**: Scroll infinito con paginación
- **Detalles de Pokemon**: Stats, tipos, sprites e información completa  
- **Manejo de errores**: Estados de loading y error bien definidos
- **Refresh**: Pull-to-refresh para recargar datos

### 🔍 Datos de Prueba

El ejemplo incluye stubs pre-configurados para:

- **Pokemon populares**: Pikachu, Charmander, Bulbasaur, Squirtle, Mewtwo
- **Lista paginada**: Primeros 100+ Pokemon con nombres reales
- **Pokemon genéricos**: Fallbacks para otros IDs (1-151)

## 📂 Estructura del Proyecto

```plaintext
lib/
├── main.dart                    # App principal + setup de Joker
├── config/
│   └── pokemon_stubs.dart       # Configuración de stubs
├── models/
│   ├── pokemon.dart             # Modelo de Pokemon individual  
│   └── pokemon_list.dart        # Modelo de lista de Pokemon
├── services/
│   └── pokemon_service.dart     # Servicio HTTP con Dio
└── screens/
    ├── pokemon_home_screen.dart # Pantalla principal con lista
    └── pokemon_detail_screen.dart # Pantalla de detalles
```

## 🛠️ Cómo Funciona

### 1. Setup Inicial

```dart
// main.dart
void main() {
  // 🃏 Configura todos los stubs de Pokemon
  PokemonStubConfig.setupStubs();
  
  runApp(const PokemonApp());
}
```

### 2. Servicio con Dio Normal

```dart
// pokemon_service.dart
class PokemonService {
  PokemonService() {
    // Dio normal, sin configuración especial
    _dio = Dio(BaseOptions(
      baseUrl: 'https://pokeapi.co/api/v2',
      // ...
    ));
  }
  
  Future<Pokemon> getPokemon(int id) async {
    // Joker intercepta automáticamente este request
    final response = await _dio.get('/pokemon/$id');
    return Pokemon.fromJson(response.data);
  }
}
```

### 3. Stubs con Indicadores

```dart
// pokemon_stubs.dart
static Map<String, dynamic> _createPikachuData() {
  return {
    'id': 25,
    'name': 'pikachu',
    'loaded_from_joker': true, // 🃏 Indicador clave
    // ... resto de datos
  };
}
```

### 4. UI con Indicadores Visuales

La aplicación muestra claramente cuando los datos vienen de Joker:

- 🟠 **Chip naranja** en AppBar: "🃏 Joker Active"  
- 🟠 **Banner informativo**: "Data loaded from Joker stubs"
- 🟠 **Chip en detalles**: "🃏 Joker" cuando el Pokemon viene de stub

## 🏃‍♂️ Cómo Ejecutar

1. **Navega al directorio del ejemplo**:

   ```bash
   cd packages/joker/example/joker_dio_native_example
   ```

2. **Instala dependencias**:

   ```bash
   flutter pub get
   ```

3. **Ejecuta la app**:

   ```bash
   flutter run
   ```

## 🔄 Modos de Operación

### Con Joker Activo (por defecto)

- ✅ Todas las requests son interceptadas
- ✅ Respuestas instantáneas desde stubs
- ✅ Indicadores visuales activos
- ✅ Sin conectividad de red requerida

### Sin Joker (deshabilitado)

Para probar requests reales, comenta el setup en `main.dart`:

```dart
void main() {
  // PokemonStubConfig.setupStubs(); // ← Comentar esta línea
  runApp(const PokemonApp());
}
```

## 🧪 Testing

El ejemplo está diseñado para ser fácil de testear:

```dart
// En tests
test('should use Joker stubs in test environment', () async {
  // Setup
  PokemonStubConfig.setupStubs();
  final service = PokemonService();
  
  // Execute  
  final pokemon = await service.getPokemon(25);
  
  // Verify
  expect(pokemon.loadedFromJoker, isTrue);
  expect(pokemon.name, 'pikachu');
});
```

## 🔍 Diferencias Clave

| Aspecto | Este Ejemplo (Nativo) | joker_dio (Web) |
|---------|----------------------|-----------------|
| **Entorno** | Flutter Native (iOS/Android) | Flutter Web |
| **Dependencias** | `joker` + `dio` | `joker_dio` |
| **Intercepción** | HttpClient level | XMLHttpRequest level |
| **Setup** | `Joker.start()` | `JokerDio.setup()` |
| **Compatibilidad** | Automática con Dio | Requiere adapter especial |

## 📚 Recursos

- **Joker Core**: [../../../README.md](../../../README.md)
- **PokeAPI**: [https://pokeapi.co/](https://pokeapi.co/)
- **Dio**: [https://pub.dev/packages/dio](https://pub.dev/packages/dio)

---

> 🃏 **¡Este ejemplo demuestra el poder de Joker para testing y desarrollo sin necesidad de conexión real a APIs!**

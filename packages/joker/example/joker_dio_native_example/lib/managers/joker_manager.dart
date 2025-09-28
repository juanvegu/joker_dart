import 'package:flutter/foundation.dart';
import '../config/pokemon_stubs.dart';

/// Manager class to control Joker state and toggle between real API and stubs
/// This is designed for native platforms only (iOS/Android)
class JokerManager extends ChangeNotifier {
  static final JokerManager _instance = JokerManager._internal();
  factory JokerManager() => _instance;
  JokerManager._internal();

  bool _isJokerActive = false; // Start with Joker disabled

  /// Returns whether Joker is currently active
  bool get isJokerActive => _isJokerActive;

  /// Activates Joker stubs for Pokemon API
  void enableJoker() {
    if (!_isJokerActive) {
      PokemonStubConfig.setupStubs();
      _isJokerActive = true;
      notifyListeners();
      debugPrint('🃏 Joker activated - Using stubbed data');
    }
  }

  /// Deactivates Joker and uses real API calls
  void disableJoker() {
    if (_isJokerActive) {
      PokemonStubConfig.clearStubs();
      _isJokerActive = false;
      notifyListeners();
      debugPrint('🌐 Joker deactivated - Using real API calls');
    }
  }

  /// Toggles Joker state
  void toggleJoker() {
    if (_isJokerActive) {
      disableJoker();
    } else {
      enableJoker();
    }
  }
}

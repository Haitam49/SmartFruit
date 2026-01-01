import 'dart:io';

// Stub pour les plateformes non supportées (web)
class FruitDetectionService {
  bool _isLoaded = false;

  bool get isLoaded => _isLoaded;

  Future<void> loadModel() async {
    throw UnsupportedError(
      'La détection de fruits n\'est pas supportée sur cette plateforme. '
      'Veuillez utiliser Android ou iOS.'
    );
  }

  Future<Map<String, double>> predictFruit(File imageFile) async {
    throw UnsupportedError(
      'La détection de fruits n\'est pas supportée sur cette plateforme. '
      'Veuillez utiliser Android ou iOS.'
    );
  }

  void dispose() {
    _isLoaded = false;
  }
}


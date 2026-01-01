import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

class FruitDetectionService {
  Interpreter? _interpreter;
  bool _isLoaded = false;
  
  // Liste des 36 classes de fruits
  // Ces labels doivent correspondre à l'ordre de sortie de votre modèle
  final List<String> _labels = [
    'Apple',
    'Banana',
    'Orange',
    'Strawberry',
    'Grape',
    'Mango',
    'Pineapple',
    'Watermelon',
    'Kiwi',
    'Peach',
    'Pear',
    'Cherry',
    'Plum',
    'Apricot',
    'Lemon',
    'Lime',
    'Coconut',
    'Avocado',
    'Papaya',
    'Pomegranate',
    'Dragon Fruit',
    'Passion Fruit',
    'Guava',
    'Lychee',
    'Raspberry',
    'Blackberry',
    'Blueberry',
    'Cranberry',
    'Fig',
    'Date',
    'Persimmon',
    'Cantaloupe',
    'Honeydew',
    'Tangerine',
    'Grapefruit',
    'Clementine',
  ];

  bool get isLoaded => _isLoaded;

  Future<void> loadModel() async {
    try {
      // Charger le modèle depuis les assets
      final ByteData data = await rootBundle.load('assets/cnn_model.tflite');
      final Uint8List bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      
      // Créer l'interpréteur TensorFlow Lite
      _interpreter = Interpreter.fromBuffer(bytes);
      
      // Obtenir les dimensions d'entrée du modèle
      final inputShape = _interpreter!.getInputTensor(0).shape;
      final outputShape = _interpreter!.getOutputTensor(0).shape;
      
      // Vérifier que le nombre de classes correspond à 36
      final numClasses = outputShape.reduce((a, b) => a * b);
      if (numClasses != 36) {
        throw Exception(
          'Le modèle doit avoir exactement 36 classes, mais $numClasses classes ont été détectées. '
          'Vérifiez que vous utilisez le bon modèle.'
        );
      }
      
      if (_labels.length != 36) {
        throw Exception(
          'Le nombre de labels (${_labels.length}) ne correspond pas au nombre de classes (36).'
        );
      }
      
      // Debug: Modèle chargé avec succès
      debugPrint('Modèle chargé avec succès');
      debugPrint('Input shape: $inputShape');
      debugPrint('Output shape: $outputShape');
      debugPrint('Nombre de classes: $numClasses');
      
      _isLoaded = true;
    } catch (e) {
      debugPrint('Erreur lors du chargement du modèle: $e');
      _isLoaded = false;
      rethrow;
    }
  }

  Future<Map<String, double>> predictFruit(File imageFile) async {
    if (!_isLoaded || _interpreter == null) {
      throw Exception('Le modèle n\'est pas chargé');
    }

    try {
      // Charger et préprocesser l'image
      final imageBytes = await imageFile.readAsBytes();
      final image = img.decodeImage(imageBytes);
      
      if (image == null) {
        throw Exception('Impossible de décoder l\'image');
      }

      // Redimensionner l'image à la taille attendue par le modèle (généralement 224x224)
      final resizedImage = img.copyResize(image, width: 224, height: 224);
      
      // Convertir l'image en tensor (normaliser les valeurs entre 0 et 1)
      final inputBuffer = _imageToByteListFloat32(resizedImage, 224, 224);
      
      // Obtenir les dimensions d'entrée et de sortie
      final inputTensor = _interpreter!.getInputTensor(0);
      final outputTensor = _interpreter!.getOutputTensor(0);
      
      final inputShape = inputTensor.shape;
      final outputShape = outputTensor.shape;
      
      debugPrint('Input shape: $inputShape');
      debugPrint('Output shape: $outputShape');
      
      // Créer le buffer de sortie avec la forme exacte du modèle
      // Le modèle retourne [1, 36], donc on doit créer un buffer de cette forme
      dynamic output;
      if (outputShape.length == 2) {
        // Format [batch, classes] - ex: [1, 36]
        output = List.generate(
          outputShape[0],
          (_) => List<double>.filled(outputShape[1], 0.0),
        );
      } else if (outputShape.length == 1) {
        // Format [classes] - ex: [36]
        output = List<double>.filled(outputShape[0], 0.0);
      } else {
        // Format complexe, créer un buffer plat
        final outputSize = outputShape.reduce((a, b) => a * b);
        output = List<double>.filled(outputSize, 0.0);
      }
      
      // Préparer l'input selon le format attendu par le modèle
      dynamic input;
      if (inputShape.length == 4) {
        // Format [1, height, width, channels] - format standard pour CNN
        final List<List<List<List<double>>>> input4D = List.generate(
          inputShape[0],
          (_) => List.generate(
            inputShape[1],
            (i) => List.generate(
              inputShape[2],
              (j) => List.generate(
                inputShape[3],
                (k) {
                  final index = (i * inputShape[2] * inputShape[3]) + 
                               (j * inputShape[3]) + k;
                  return inputBuffer[index.toInt()];
                },
              ),
            ),
          ),
        );
        input = input4D;
      } else {
        // Format plat si nécessaire
        input = inputBuffer;
      }
      
      // Exécuter l'inférence
      _interpreter!.run(input, output);
      
      // Extraire les prédictions selon la forme de sortie
      List<double> predictions;
      if (outputShape.length == 2 && outputShape[0] == 1) {
        // Format [1, 36] - extraire le premier (et seul) élément du batch
        predictions = (output as List<List<double>>)[0];
      } else if (outputShape.length == 1) {
        // Format [36] - utiliser directement
        predictions = output as List<double>;
      } else {
        // Format complexe - convertir en liste plate
        final flatOutput = <double>[];
        void flatten(dynamic item) {
          if (item is List) {
            for (var element in item) {
              flatten(element);
            }
          } else if (item is double || item is int) {
            flatOutput.add(item.toDouble());
          }
        }
        flatten(output);
        predictions = flatOutput;
      }
      
      // Créer un map avec les labels et leurs probabilités
      // Le modèle doit avoir exactement 36 classes
      final Map<String, double> results = {};
      final numPredictions = predictions.length;
      final numLabels = _labels.length;
      
      if (numPredictions != numLabels) {
        debugPrint('Avertissement: Le nombre de prédictions ($numPredictions) ne correspond pas au nombre de labels ($numLabels)');
      }
      
      // Mapper les prédictions aux labels (prendre le minimum pour éviter les erreurs)
      final maxIndex = numPredictions < numLabels ? numPredictions : numLabels;
      for (int i = 0; i < maxIndex; i++) {
        results[_labels[i]] = predictions[i];
      }
      
      // Trier par probabilité décroissante
      final sortedResults = Map.fromEntries(
        results.entries.toList()..sort((a, b) => b.value.compareTo(a.value)),
      );
      
      return sortedResults;
    } catch (e) {
      debugPrint('Erreur lors de la prédiction: $e');
      rethrow;
    }
  }

  // Convertir l'image en liste de bytes normalisés (0-1)
  List<double> _imageToByteListFloat32(img.Image image, int inputSize, int inputSizeHeight) {
    final convertedBytes = Float32List(inputSize * inputSizeHeight * 3);
    final buffer = Float32List.view(convertedBytes.buffer);
    
    int pixelIndex = 0;
    for (int i = 0; i < inputSize; i++) {
      for (int j = 0; j < inputSizeHeight; j++) {
        final pixel = image.getPixel(j, i);
        // Extraire les composantes RGB du pixel
        final r = pixel.r;
        final g = pixel.g;
        final b = pixel.b;
        buffer[pixelIndex++] = (r / 255.0);
        buffer[pixelIndex++] = (g / 255.0);
        buffer[pixelIndex++] = (b / 255.0);
      }
    }
    return convertedBytes;
  }

  void dispose() {
    _interpreter?.close();
    _interpreter = null;
    _isLoaded = false;
  }
}


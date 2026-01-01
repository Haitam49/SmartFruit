import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Service pour appeler l'API Gemini.
class VoiceAssistantService {
  // ============================================
  // CONFIGURATION - MODIFIEZ ICI
  // ============================================
  
  // Remplacez 'YOUR_API_KEY' par votre clé API réelle
  static const String apiKey = 'AIzaSyAzIq7PTq8XlFiwA_2tVNVwh1n1vhlQmAE';
  
  // ============================================
  // Configuration Google Gemini
  // ============================================
  static const String geminiEndpoint = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent';
  static const String geminiModel = 'gemini-1.5-flash';

  Future<String> ask(String prompt) async {
    // Vérification de la clé API
    if (apiKey.isEmpty) {
      throw Exception(
        '⚠️ Clé API non configurée !\n\n',
      );
    }

    return _askGemini(prompt);
  }

  Future<String> _askGemini(String prompt) async {
    final uri = Uri.parse('$geminiEndpoint?key=$apiKey');
    final headers = {
      'Content-Type': 'application/json',
    };
    final body = jsonEncode({
      'contents': [
        {
          'parts': [
            {
              'text': 'Tu es un assistant vocal expert des fruits. Réponds de manière concise et amicale en français.\n\nQuestion: $prompt'
            }
          ]
        }
      ],
      'generationConfig': {
        'temperature': 0.7,
        'maxOutputTokens': 150,
      },
    });

    final response = await http.post(uri, headers: headers, body: body);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final candidates = json['candidates'] as List<dynamic>?;
      if (candidates == null || candidates.isEmpty) {
        throw Exception('Réponse vide de l\'API Gemini');
      }
      final content = candidates.first['content']?['parts']?[0]?['text']?.toString().trim() ?? '';
      if (content.isEmpty) {
        throw Exception('Contenu de réponse vide');
      }
      return content;
    } else {
      debugPrint('Erreur API Gemini: ${response.statusCode} ${response.body}');
      if (response.statusCode == 400) {
        throw Exception('Requête invalide. Vérifiez votre clé API Gemini.');
      } else if (response.statusCode == 403) {
        throw Exception('Clé API Gemini invalide ou quota dépassé.');
      }
      throw Exception('Erreur API Gemini (${response.statusCode})');
    }
  }
}

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import 'login_page.dart';
import 'fruit_detection_page.dart';
import 'profile_page.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'settings_page.dart';
import 'about_page.dart';
import '../services/voice_assistant_service.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final user = authService.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Fruit App'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // Header avec infos utilisateur
            DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.secondary,
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    backgroundImage: user?.photoUrl != null
                        ? FileImage(File(user!.photoUrl!))
                        : null,
                    child: user?.photoUrl == null
                        ? Text(
                            user?.name.isNotEmpty == true
                                ? user!.name.substring(0, 1).toUpperCase()
                                : 'U',
                            style: TextStyle(
                              fontSize: 30,
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    user?.name ?? 'Utilisateur',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.email ?? '',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            
            // Boutons de navigation
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Accueil'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Détection de Fruits'),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const FruitDetectionPage(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profil'),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const ProfilePage(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.help),
              title: const Text('À propos / Aide'),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const AboutPage(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('Historique'),
              onTap: () {
                Navigator.pop(context);
                // Navigation vers la page historique
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Page Historique')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Paramètres'),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const SettingsPage(),
                  ),
                );
              },
            ),
            
            const Divider(),
            
            // Bouton de déconnexion
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                'Déconnexion',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () async {
                Navigator.pop(context);
                await authService.logout();
                if (context.mounted) {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  );
                }
              },
            ),
          ],
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.surface,
              Colors.green.shade50,
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.2),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.shopping_bag,
                    size: 80,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'Bienvenue,',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  user?.name ?? 'Utilisateur',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    user?.email ?? '',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 48),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const FruitDetectionPage(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('DÉTECTER UN FRUIT'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 20,
                    ),
                    textStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                const VoiceAssistantSection(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class VoiceAssistantSection extends StatefulWidget {
  const VoiceAssistantSection({super.key});

  @override
  State<VoiceAssistantSection> createState() => _VoiceAssistantSectionState();
}

class _VoiceAssistantSectionState extends State<VoiceAssistantSection> {
  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _tts = FlutterTts();
  final VoiceAssistantService _assistantService = VoiceAssistantService();

  bool _isListening = false;
  bool _isLoading = false;
  String _transcript = '';
  String _assistantReply = '';

  @override
  void initState() {
    super.initState();
    _initTts();
  }

  Future<void> _initTts() async {
    await _tts.setLanguage('fr-FR');
    await _tts.setSpeechRate(0.9);
    await _tts.setVolume(1.0);
  }

  Future<void> _startListening() async {
    try {
      // Initialiser le service de reconnaissance vocale
      bool available = await _speech.initialize(
        onError: (error) {
          debugPrint('Erreur SpeechToText: ${error.errorMsg}');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Erreur de reconnaissance: ${error.errorMsg}'),
                duration: const Duration(seconds: 3),
              ),
            );
          }
        },
        onStatus: (status) {
          debugPrint('Status SpeechToText: $status');
        },
      );
      
      if (!mounted) return;
      
      if (!available) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Micro indisponible. Vérifiez que les permissions du micro sont accordées dans les paramètres de l\'application.',
            ),
            duration: Duration(seconds: 4),
          ),
        );
        return;
      }

      setState(() {
        _isListening = true;
        _transcript = '';
        _assistantReply = '';
      });

      await _speech.listen(
        localeId: 'fr_FR',
        listenOptions: stt.SpeechListenOptions(
          listenMode: stt.ListenMode.confirmation,
          cancelOnError: true,
          partialResults: true,
        ),
        onResult: (result) {
          setState(() {
            _transcript = result.recognizedWords;
          });
          // Si la reconnaissance est terminée, arrêter automatiquement
          if (result.finalResult) {
            _stopListening();
          }
        },
      );
    } catch (e) {
      debugPrint('Erreur lors du démarrage de l\'écoute: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            duration: const Duration(seconds: 3),
          ),
        );
        setState(() {
          _isListening = false;
        });
      }
    }
  }

  Future<void> _stopListening() async {
    try {
      await _speech.stop();
      setState(() {
        _isListening = false;
      });
      if (_transcript.isNotEmpty) {
        await _askAssistant(_transcript);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Aucun texte détecté. Veuillez réessayer.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      debugPrint('Erreur lors de l\'arrêt de l\'écoute: $e');
      if (mounted) {
        setState(() {
          _isListening = false;
        });
      }
    }
  }

  Future<void> _askAssistant(String prompt) async {
    setState(() {
      _isLoading = true;
      _assistantReply = '';
    });
    try {
      final reply = await _assistantService.ask(prompt);
      if (!mounted) return;
      setState(() {
        _assistantReply = reply;
      });
      await _tts.stop();
      await _tts.speak(reply);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur assistant: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Assistant vocal',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Icon(
                  _isListening ? Icons.mic : Icons.mic_none,
                  color: _isListening
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              _transcript.isEmpty
                  ? 'Appuyez et parlez pour poser votre question sur les fruits.'
                  : 'Vous : $_transcript',
              style: const TextStyle(fontSize: 15),
            ),
            const SizedBox(height: 12),
            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_assistantReply.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Assistant :',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _assistantReply,
                    style: const TextStyle(fontSize: 15),
                  ),
                ],
              ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isListening ? _stopListening : _startListening,
                    icon: Icon(_isListening ? Icons.stop : Icons.mic),
                    label: Text(_isListening ? 'Arrêter' : 'Parler'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                IconButton(
                  tooltip: 'Répéter la réponse',
                  icon: const Icon(Icons.volume_up),
                  onPressed: _assistantReply.isEmpty
                      ? null
                      : () async {
                          await _tts.stop();
                          await _tts.speak(_assistantReply);
                        },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aide & À propos'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 32),
            // Logo et Version
            Icon(
              Icons.shopping_bag,
              size: 80,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            const Text(
              'Smart Fruit App',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Version 1.0.0',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 32),
            
            // Section Aide / FAQ
            _buildSectionHeader(context, 'Questions Fréquentes'),
            const ExpansionTile(
              leading: Icon(Icons.help_outline),
              title: Text('Comment utiliser la détection ?'),
              children: [
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Allez sur la page "Détection de Fruits", prenez une photo ou choisissez-en une dans votre galerie. L\'intelligence artificielle analysera l\'image pour identifier le fruit.',
                  ),
                ),
              ],
            ),
            const ExpansionTile(
              leading: Icon(Icons.mic),
              title: Text('Comment utiliser l\'assistant vocal ?'),
              children: [
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Sur l\'écran d\'accueil, appuyez sur le bouton "Parler" dans la section Assistant Vocal. Posez votre question sur les fruits, et l\'assistant vous répondra.',
                  ),
                ),
              ],
            ),
             const ExpansionTile(
              leading: Icon(Icons.person),
              title: Text('Comment modifier mon profil ?'),
              children: [
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Ouvrez le menu latéral et cliquez sur "Profil". Vous pourrez y modifier votre nom, prénom, slogan et photo.',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),
            _buildSectionHeader(context, 'Contact'),
            ListTile(
              leading: const Icon(Icons.email),
              title: const Text('Nous contacter'),
              subtitle: const Text('support@smartfruit.app'),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Ouverture client mail...')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.web),
              title: const Text('Site Web'),
              subtitle: const Text('www.smartfruit.app'),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Ouverture navigateurs...')),
                );
              },
            ),
            
            const SizedBox(height: 32),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                '© 2025 Smart Fruit Inc. Tous droits réservés.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Container(
      width: double.infinity,
      color: Colors.grey[100],
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
          fontSize: 13,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

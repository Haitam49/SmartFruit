import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;
  String _selectedLanguage = 'Français';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paramètres'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView(
        children: [
          const SizedBox(height: 16),
          _buildSectionHeader('Général'),
          SwitchListTile(
            title: const Text('Notifications'),
            subtitle: const Text('Recevoir des alertes de l\'assistant'),
            secondary: const Icon(Icons.notifications),
            value: _notificationsEnabled,
            onChanged: (bool value) {
              setState(() {
                _notificationsEnabled = value;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    value ? 'Notifications activées' : 'Notifications désactivées',
                  ),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
          ),
          SwitchListTile(
            title: const Text('Mode sombre'),
            subtitle: const Text('Thème sombre pour l\'application'),
            secondary: const Icon(Icons.dark_mode),
            value: _darkModeEnabled,
            onChanged: (bool value) {
              setState(() {
                _darkModeEnabled = value;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Le changement de thème sera implémenté prochainement'),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('Langue'),
            subtitle: Text(_selectedLanguage),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // Simulation changement de langue
              showDialog(
                context: context,
                builder: (context) => SimpleDialog(
                  title: const Text('Choisir la langue'),
                  children: [
                    SimpleDialogOption(
                      onPressed: () {
                        setState(() => _selectedLanguage = 'Français');
                        Navigator.pop(context);
                      },
                      child: const Text('Français'),
                    ),
                    SimpleDialogOption(
                      onPressed: () {
                        setState(() => _selectedLanguage = 'English');
                        Navigator.pop(context);
                      },
                      child: const Text('English'),
                    ),
                  ],
                ),
              );
            },
          ),
          const Divider(),
          _buildSectionHeader('Compte'),
          ListTile(
            leading: const Icon(Icons.security),
            title: const Text('Confidentialité'),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Politique de confidentialité')),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: const Text(
              'Supprimer mon compte',
              style: TextStyle(color: Colors.red),
            ),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Supprimer le compte ?'),
                  content: const Text(
                    'Cette action est irréversible. Toutes vos données seront effacées.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Annuler'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Compte supprimé (simulation)')),
                        );
                      },
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                      child: const Text('Supprimer'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}

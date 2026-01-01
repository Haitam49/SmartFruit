import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class User {
  final String email;
  final String firstName;
  final String lastName;
  final String? photoUrl;
  final String? slogan;

  String get name => '$firstName $lastName'.trim();

  User({
    required this.email,
    required this.firstName,
    required this.lastName,
    this.photoUrl,
    this.slogan,
  });
}

class AuthService extends ChangeNotifier {
  User? _currentUser;
  bool _isAuthenticated = false;

  User? get currentUser => _currentUser;
  bool get isAuthenticated => _isAuthenticated;

  AuthService() {
    _clearSession();
  }

  Future<void> _clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_email');
    await prefs.remove('user_firstName');
    await prefs.remove('user_lastName');
    await prefs.remove('user_photoUrl');
    await prefs.remove('user_slogan');
    
    _currentUser = null;
    _isAuthenticated = false;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString('registered_email_$email');
    final savedPassword = prefs.getString('registered_password_$email');
    
    if (savedEmail == email && savedPassword == password) {
      final firstName = prefs.getString('registered_firstName_$email') ?? 'Utilisateur';
      final lastName = prefs.getString('registered_lastName_$email') ?? '';
      final photoUrl = prefs.getString('registered_photoUrl_$email');
      final slogan = prefs.getString('registered_slogan_$email');

      _currentUser = User(
        email: email,
        firstName: firstName,
        lastName: lastName,
        photoUrl: photoUrl,
        slogan: slogan,
      );
      _isAuthenticated = true;
      
      await _saveSession(email, firstName, lastName, photoUrl, slogan);
      
      notifyListeners();
      return true;
    }
    
    return false;
  }

  Future<bool> register(String email, String password, String name) async {
    await Future.delayed(const Duration(seconds: 1));
    
    final prefs = await SharedPreferences.getInstance();
    
    final existingEmail = prefs.getString('registered_email_$email');
    if (existingEmail != null) {
      return false;
    }
    
    // Pour la rétrocompatibilité ou la simplicité, on utilise "name" comme prénom par défaut
    // et on laisse le nom de famille vide lors de l'inscription simple
    final firstName = name;
    final lastName = '';

    await prefs.setString('registered_email_$email', email);
    await prefs.setString('registered_password_$email', password);
    await prefs.setString('registered_firstName_$email', firstName);
    await prefs.setString('registered_lastName_$email', lastName);
    
    _currentUser = User(
      email: email,
      firstName: firstName,
      lastName: lastName,
    );
    _isAuthenticated = true;
    
    await _saveSession(email, firstName, lastName, null, null);
    
    notifyListeners();
    return true;
  }

  Future<void> updateUserProfile({
    String? firstName,
    String? lastName,
    String? photoUrl,
    String? slogan,
  }) async {
    if (_currentUser == null) return;
    
    final newFirstName = firstName ?? _currentUser!.firstName;
    final newLastName = lastName ?? _currentUser!.lastName;
    final newPhotoUrl = photoUrl ?? _currentUser!.photoUrl;
    final newSlogan = slogan ?? _currentUser!.slogan;
    final email = _currentUser!.email;

    _currentUser = User(
      email: email,
      firstName: newFirstName,
      lastName: newLastName,
      photoUrl: newPhotoUrl,
      slogan: newSlogan,
    );

    final prefs = await SharedPreferences.getInstance();
    // Sauvegarder dans le registre permanent
    await prefs.setString('registered_firstName_$email', newFirstName);
    await prefs.setString('registered_lastName_$email', newLastName);
    if (newPhotoUrl != null) await prefs.setString('registered_photoUrl_$email', newPhotoUrl);
    if (newSlogan != null) await prefs.setString('registered_slogan_$email', newSlogan);

    // Mettre à jour la session active
    await _saveSession(email, newFirstName, newLastName, newPhotoUrl, newSlogan);

    notifyListeners();
  }

  Future<void> _saveSession(String email, String firstName, String lastName, String? photoUrl, String? slogan) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_email', email);
    await prefs.setString('user_firstName', firstName);
    await prefs.setString('user_lastName', lastName);
    if (photoUrl != null) {
      await prefs.setString('user_photoUrl', photoUrl);
    } else {
      await prefs.remove('user_photoUrl');
    }
    if (slogan != null) {
      await prefs.setString('user_slogan', slogan);
    } else {
      await prefs.remove('user_slogan');
    }
  }

  Future<void> logout() async {
    await _clearSession();
  }
}




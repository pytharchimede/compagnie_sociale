import 'package:flutter/foundation.dart';
import '../services/auth_service.dart';
import '../models/user.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  bool _isLoggedIn = false;
  bool _isLoading = false;
  User? _currentUser;
  String? _lastErrorMessage;

  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;
  User? get currentUser => _currentUser;
  String? get lastErrorMessage => _lastErrorMessage;

  // Initialiser l'état d'authentification
  Future<void> initializeAuth() async {
    _setLoading(true);

    try {
      _isLoggedIn = await _authService.isLoggedIn();

      if (_isLoggedIn) {
        final userData = await _authService.getCurrentUser();
        if (userData != null) {
          _currentUser = User.fromJson(userData);
        } else {
          // Données utilisateur corrompues, déconnecter
          await logout();
        }
      }
    } catch (e) {
      print('DEBUG - Erreur initialisation auth: $e');
      _isLoggedIn = false;
      _currentUser = null;
    }

    _setLoading(false);
  }

  // Inscription
  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phone,
  }) async {
    _setLoading(true);
    _lastErrorMessage = null;

    try {
      final result = await _authService.register(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        phone: phone,
      );

      if (result['success'] == true) {
        _isLoggedIn = true;
        _currentUser = User.fromJson(result['user']);
        _setLoading(false);
        return result;
      } else {
        _lastErrorMessage = result['message'];
        _setLoading(false);
        return result;
      }
    } catch (e) {
      _lastErrorMessage = 'Erreur technique: $e';
      _setLoading(false);
      return {
        'success': false,
        'message': _lastErrorMessage,
      };
    }
  }

  // Connexion
  Future<Map<String, dynamic>> login(String email, String password) async {
    _setLoading(true);
    _lastErrorMessage = null;

    try {
      final result = await _authService.login(email, password);

      if (result['success'] == true) {
        _isLoggedIn = true;
        _currentUser = User.fromJson(result['user']);
        _setLoading(false);
        return result;
      } else {
        _lastErrorMessage = result['message'];
        _setLoading(false);
        return result;
      }
    } catch (e) {
      _lastErrorMessage = 'Erreur technique: $e';
      _setLoading(false);
      return {
        'success': false,
        'message': _lastErrorMessage,
      };
    }
  }

  // Test de connexion (pour debug)
  Future<Map<String, dynamic>> testConnection(
      String email, String password) async {
    return await _authService.testLoginConnection(email, password);
  }

  // Déconnexion
  Future<void> logout() async {
    await _authService.logout();
    _isLoggedIn = false;
    _currentUser = null;
    _lastErrorMessage = null;
    notifyListeners();
  }

  // Méthode utilitaire pour définir l'état de chargement
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  @override
  void dispose() {
    // Plus de timer à nettoyer
    super.dispose();
  }
}

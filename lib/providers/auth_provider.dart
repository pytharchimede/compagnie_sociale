import 'package:flutter/foundation.dart';
import 'dart:async';
import '../models/user.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  Timer? _syncTimer;

  User? _currentUser;
  bool _isLoading = false;
  bool _isLoggedIn = false;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _isLoggedIn;

  AuthProvider() {
    _initializeAuth();
    _startAutoSync();
  }

  @override
  void dispose() {
    _syncTimer?.cancel();
    _authService.dispose();
    super.dispose();
  }

  // Synchronisation automatique toutes les 5 minutes
  void _startAutoSync() {
    _syncTimer = Timer.periodic(const Duration(minutes: 5), (timer) async {
      try {
        await _authService.performAutoSync();
      } catch (e) {
        // Ignorer les erreurs de sync automatique
      }
    });
  }

  // Méthode publique pour réinitialiser l'authentification
  Future<void> initializeAuth() async {
    await _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    _setLoading(true);

    try {
      _isLoggedIn = await _authService.isLoggedIn();
      if (_isLoggedIn) {
        final userData = await _authService.getCurrentUser();
        if (userData != null) {
          _currentUser = User.fromJson(userData);
        }
      }
    } catch (e) {
      // Ignorer les erreurs d'initialisation en production
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> login(String email, String password) async {
    _setLoading(true);

    try {
      final result = await _authService.login(email, password);

      if (result['success'] == true) {
        final userData = result['user'];
        if (userData != null) {
          _currentUser = User.fromJson(userData);
          _isLoggedIn = true;
          notifyListeners();
          return true;
        }
      }

      return false;
    } catch (e) {
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? phone,
  }) async {
    _setLoading(true);

    try {
      final result = await _authService.register(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        phone: phone ?? '',
      );

      if (result['success'] == true) {
        // Auto-login après inscription réussie
        return await login(email, password);
      }

      return false;
    } catch (e) {
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    _setLoading(true);

    try {
      await _authService.logout();
      _currentUser = null;
      _isLoggedIn = false;
      notifyListeners();
    } catch (e) {
      // Ignorer les erreurs de déconnexion
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }

  // Méthodes simplifiées pour la compatibilité
  String? get error => null; // Pas d'erreur persistante en production

  bool get hasError => false; // Pas d'erreur persistante en production

  void clearError() {
    // Méthode vide pour la compatibilité
  }
}

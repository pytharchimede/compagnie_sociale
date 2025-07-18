import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  User? _currentUser;
  bool _isLoading = false;
  bool _isLoggedIn = false;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _isLoggedIn;

  AuthProvider() {
    _initializeAuth();
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
        _currentUser = await _authService.getCurrentUser();
      }
    } catch (e) {
      print('Erreur lors de l\'initialisation de l\'authentification: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> login(String email, String password) async {
    _setLoading(true);

    try {
      final result = await _authService.login(email: email, password: password);

      if (result.isSuccess && result.user != null) {
        _currentUser = result.user;
        _isLoggedIn = true;
        notifyListeners();

        // Synchroniser les données en arrière-plan
        _syncData();

        return true;
      }

      return false;
    } catch (e) {
      print('Erreur lors de la connexion: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> register({
    required String email,
    required String password,
    required String fullName,
    String? phone,
  }) async {
    _setLoading(true);

    try {
      final result = await _authService.register(
        email: email,
        password: password,
        fullName: fullName,
        phone: phone,
      );

      if (result.isSuccess && result.user != null) {
        _currentUser = result.user;
        _isLoggedIn = true;
        notifyListeners();

        // Synchroniser les données en arrière-plan
        _syncData();

        return true;
      }

      return false;
    } catch (e) {
      print('Erreur lors de l\'inscription: $e');
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
      print('Erreur lors de la déconnexion: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateProfile(User updatedUser) async {
    _setLoading(true);

    try {
      final result = await _authService.updateProfile(updatedUser);

      if (result.isSuccess && result.user != null) {
        _currentUser = result.user;
        notifyListeners();
        return true;
      }

      return false;
    } catch (e) {
      print('Erreur lors de la mise à jour du profil: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    _setLoading(true);

    try {
      final result = await _authService.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );

      if (result.isSuccess && result.user != null) {
        _currentUser = result.user;
        notifyListeners();
        return true;
      }

      return false;
    } catch (e) {
      print('Erreur lors du changement de mot de passe: $e');
      return false;
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

  Future<void> _syncData() async {
    try {
      await _authService.syncPendingData();
    } catch (e) {
      print('Erreur lors de la synchronisation: $e');
    }
  }

  // Méthode pour forcer la synchronisation
  Future<void> forcSync() async {
    await _syncData();
  }
}

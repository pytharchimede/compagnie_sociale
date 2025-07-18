import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

class UserProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  User? _currentUser;
  bool _isLoading = false;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;

  UserProvider() {
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    _setLoading(true);

    try {
      final userData = await _authService.getCurrentUser();
      if (userData != null) {
        _currentUser = User.fromJson(userData);
        notifyListeners();
      }
    } catch (e) {
      // Ignorer les erreurs en production
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateProfile({
    String? fullName,
    String? phone,
    String? dateOfBirth,
    String? gender,
    String? location,
    String? bio,
  }) async {
    if (_currentUser == null) return false;

    _setLoading(true);

    try {
      // Mettre à jour l'utilisateur localement
      _currentUser = _currentUser!.copyWith(
        fullName: fullName ?? _currentUser!.fullName,
        phone: phone ?? _currentUser!.phone,
        dateOfBirth: dateOfBirth ?? _currentUser!.dateOfBirth,
        gender: gender ?? _currentUser!.gender,
        location: location ?? _currentUser!.location,
        bio: bio ?? _currentUser!.bio,
        updatedAt: DateTime.now(),
      );

      notifyListeners();
      return true;
    } catch (e) {
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> refreshUser() async {
    await _loadCurrentUser();
  }

  // Méthode pour initialiser l'utilisateur (alias de refreshUser)
  Future<void> initializeUser() async {
    await refreshUser();
  }

  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }

  // Méthodes pour la compatibilité
  String? get error => null;
  bool get hasError => false;
  void clearError() {}
}

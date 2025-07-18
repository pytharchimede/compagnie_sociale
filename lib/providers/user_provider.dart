import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

class UserProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  User? _currentUser;
  bool _isLoading = false;
  bool _isAuthenticated = false;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;

  UserProvider() {
    _initializeFromAuth();
  }

  Future<void> _initializeFromAuth() async {
    _isLoading = true;
    notifyListeners();

    try {
      _isAuthenticated = await _authService.isLoggedIn();
      if (_isAuthenticated) {
        _currentUser = await _authService.getCurrentUser();
      }
    } catch (e) {
      print('Erreur lors de l\'initialisation: $e');
      _isAuthenticated = false;
    }

    _isLoading = false;
    notifyListeners();
  }

  void initializeUser() {
    _isLoading = true;
    notifyListeners();

    // Simulation d'un utilisateur connecté avec le nouveau modèle
    _currentUser = User(
      id: 'user_1',
      email: 'jb.kouassi@email.com',
      password:
          'hashed_password', // En réalité, on ne stockerait pas le mot de passe en clair
      fullName: 'Jean-Baptiste Kouassi',
      phone: '+225 07 12 34 56',
      avatarUrl:
          'https://images.pexels.com/photos/1681010/pexels-photo-1681010.jpeg',
      location: 'Cocody, Abidjan',
      bio: 'Utilisateur premium de Compagnie Sociale CI',
      isVerified: true,
      createdAt: DateTime(2024, 1, 15),
      updatedAt: DateTime.now(),
      lastLoginAt: DateTime.now(),
      isPremium: true,
      totalBookings: 12,
      averageRating: 4.7,
      totalSavings: 45000,
      preferences: [
        'Guides Touristiques',
        'Événements Sociaux',
        'Services VIP'
      ],
    );

    _isAuthenticated = true;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateProfile({
    String? fullName,
    String? email,
    String? phone,
    String? avatarUrl,
    String? location,
    String? bio,
    List<String>? preferences,
  }) async {
    if (_currentUser == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      // Simulation de mise à jour
      await Future.delayed(const Duration(seconds: 1));

      _currentUser = _currentUser!.copyWith(
        fullName: fullName,
        email: email,
        phone: phone,
        avatarUrl: avatarUrl,
        location: location,
        bio: bio,
        preferences: preferences,
        updatedAt: DateTime.now(),
      );

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('Erreur lors de la mise à jour du profil: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> upgradeToPremium() async {
    if (_currentUser == null) return;

    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 2));

    _currentUser = _currentUser!.copyWith(isPremium: true);

    _isLoading = false;
    notifyListeners();
  }

  void incrementBookingCount() {
    if (_currentUser == null) return;

    _currentUser = _currentUser!.copyWith(
      totalBookings: _currentUser!.totalBookings + 1,
    );
    notifyListeners();
  }

  void addSavings(double amount) {
    if (_currentUser == null) return;

    _currentUser = _currentUser!.copyWith(
      totalSavings: _currentUser!.totalSavings + amount,
    );
    notifyListeners();
  }

  void updateRating(double newRating) {
    if (_currentUser == null) return;

    // Simple average calculation (in real app, you'd have more sophisticated logic)
    final currentTotal =
        _currentUser!.averageRating * _currentUser!.totalBookings;
    final newTotal = currentTotal + newRating;
    final newAverage = newTotal / (_currentUser!.totalBookings + 1);

    _currentUser = _currentUser!.copyWith(
      averageRating: newAverage,
    );
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _authService.login(email: email, password: password);

      if (result.isSuccess && result.user != null) {
        _currentUser = result.user;
        _isAuthenticated = true;
      } else {
        throw Exception(result.error ?? 'Erreur de connexion');
      }
    } catch (e) {
      print('Erreur lors de la connexion: $e');
      // Fallback vers initializeUser pour la simulation
      initializeUser();
      return;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.logout();
    } catch (e) {
      print('Erreur lors de la déconnexion: $e');
    }

    _currentUser = null;
    _isAuthenticated = false;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    required String location,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Utiliser le service d'authentification pour l'inscription
      final result = await _authService.register(
        email: email,
        password: password,
        fullName: fullName,
        phone: phone,
      );

      if (result.isSuccess && result.user != null) {
        _currentUser = result.user!.copyWith(
          location: location,
          updatedAt: DateTime.now(),
        );
        _isAuthenticated = true;
      } else {
        throw Exception(result.error ?? 'Erreur lors de l\'inscription');
      }
    } catch (e) {
      print('Erreur lors de l\'inscription: $e');
      // En cas d'erreur, on peut créer un utilisateur local
      _currentUser = User(
        id: 'user_${DateTime.now().millisecondsSinceEpoch}',
        email: email,
        password:
            password, // En production, ne jamais stocker le mot de passe en clair
        fullName: fullName,
        phone: phone,
        location: location,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      _isAuthenticated = true;
    }

    _isLoading = false;
    notifyListeners();
  }
}

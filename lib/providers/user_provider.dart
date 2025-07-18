import 'package:flutter/foundation.dart';
import '../models/user.dart';

class UserProvider with ChangeNotifier {
  User? _currentUser;
  bool _isLoading = false;
  bool _isAuthenticated = false;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;

  void initializeUser() {
    _isLoading = true;
    notifyListeners();

    // Simulation d'un utilisateur connecté
    _currentUser = User(
      id: 'user_1',
      name: 'Jean-Baptiste Kouassi',
      email: 'jb.kouassi@email.com',
      phone: '+225 07 12 34 56',
      profileImage: 'https://images.pexels.com/photos/1681010/pexels-photo-1681010.jpeg',
      location: 'Cocody, Abidjan',
      isPremium: true,
      totalBookings: 12,
      averageRating: 4.7,
      totalSavings: 45000,
      joinedDate: DateTime(2024, 1, 15),
      preferences: ['Guides Touristiques', 'Événements Sociaux', 'Services VIP'],
    );

    _isAuthenticated = true;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateProfile({
    String? name,
    String? email,
    String? phone,
    String? profileImage,
    String? location,
    List<String>? preferences,
  }) async {
    if (_currentUser == null) return;

    _isLoading = true;
    notifyListeners();

    // Simulation de mise à jour
    await Future.delayed(const Duration(seconds: 1));

    _currentUser = _currentUser!.copyWith(
      name: name,
      email: email,
      phone: phone,
      profileImage: profileImage,
      location: location,
      preferences: preferences,
    );

    _isLoading = false;
    notifyListeners();
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
    final currentTotal = _currentUser!.averageRating * _currentUser!.totalBookings;
    final newTotal = currentTotal + newRating;
    final newAverage = newTotal / (_currentUser!.totalBookings + 1);

    _currentUser = _currentUser!.copyWith(
      averageRating: newAverage,
    );
    notifyListeners();
  }

  void logout() {
    _currentUser = null;
    _isAuthenticated = false;
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    // Simulation de connexion
    await Future.delayed(const Duration(seconds: 2));

    initializeUser();
  }

  Future<void> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String location,
  }) async {
    _isLoading = true;
    notifyListeners();

    // Simulation d'inscription
    await Future.delayed(const Duration(seconds: 2));

    _currentUser = User(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      email: email,
      phone: phone,
      location: location,
      joinedDate: DateTime.now(),
    );

    _isAuthenticated = true;
    _isLoading = false;
    notifyListeners();
  }
}

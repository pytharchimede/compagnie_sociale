import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../database/database_helper.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  static const String _tokenKey = 'auth_token';
  static const String _userIdKey = 'user_id';
  static const String _isLoggedInKey = 'is_logged_in';

  AuthService._internal();

  factory AuthService() => _instance;

  final DatabaseHelper _dbHelper = DatabaseHelper();
  final ApiService _apiService = ApiService();
  final Uuid _uuid = const Uuid();

  // Vérifier si l'utilisateur est connecté
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  // Obtenir l'utilisateur actuel
  Future<User?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString(_userIdKey);

    if (userId != null) {
      return await _dbHelper.getUserById(userId);
    }
    return null;
  }

  // Inscription
  Future<AuthResult> register({
    required String email,
    required String password,
    required String fullName,
    String? phone,
  }) async {
    try {
      // Vérifier si l'utilisateur existe déjà localement
      final existingUser = await _dbHelper.getUserByEmail(email);
      if (existingUser != null) {
        return AuthResult.error('Un compte avec cet email existe déjà');
      }

      // Créer un nouvel utilisateur
      final user = User(
        id: _uuid.v4(),
        email: email,
        password: _hashPassword(password),
        fullName: fullName,
        phone: phone,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Sauvegarder localement
      await _dbHelper.insertUser(user);

      // Tenter de synchroniser avec l'API
      try {
        await _apiService.registerUser(user);
      } catch (e) {
        // Si l'API échoue, ajouter à la queue de synchronisation
        await _dbHelper.addToSyncQueue(
            'users', user.id, 'INSERT', user.toJson());
      }

      // Connecter l'utilisateur
      await _saveAuthData(user.id, 'local_token_${user.id}');

      return AuthResult.success(user);
    } catch (e) {
      return AuthResult.error('Erreur lors de l\'inscription: $e');
    }
  }

  // Connexion
  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    try {
      final hashedPassword = _hashPassword(password);

      // D'abord, essayer avec l'API
      try {
        final apiResponse = await _apiService.loginUser(email, password);
        if (apiResponse.isSuccess && apiResponse.user != null) {
          // Mettre à jour l'utilisateur local
          await _dbHelper.updateUser(apiResponse.user!);
          await _saveAuthData(apiResponse.user!.id, apiResponse.token!);
          return AuthResult.success(apiResponse.user!);
        }
      } catch (e) {
        print('Connexion API échouée, tentative hors ligne: $e');
      }

      // Ensuite, essayer hors ligne
      final user = await _dbHelper.getUserByEmail(email);
      if (user != null && user.password == hashedPassword) {
        // Mettre à jour la dernière connexion
        final updatedUser = user.copyWith(lastLoginAt: DateTime.now());
        await _dbHelper.updateUser(updatedUser);

        await _saveAuthData(user.id, 'local_token_${user.id}');
        return AuthResult.success(updatedUser);
      }

      return AuthResult.error('Email ou mot de passe incorrect');
    } catch (e) {
      return AuthResult.error('Erreur lors de la connexion: $e');
    }
  }

  // Déconnexion
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userIdKey);
    await prefs.setBool(_isLoggedInKey, false);
  }

  // Mise à jour du profil
  Future<AuthResult> updateProfile(User updatedUser) async {
    try {
      // Mettre à jour localement
      await _dbHelper.updateUser(updatedUser);

      // Tenter de synchroniser avec l'API
      try {
        await _apiService.updateUser(updatedUser);
      } catch (e) {
        // Si l'API échoue, ajouter à la queue de synchronisation
        await _dbHelper.addToSyncQueue(
            'users', updatedUser.id, 'UPDATE', updatedUser.toJson());
      }

      return AuthResult.success(updatedUser);
    } catch (e) {
      return AuthResult.error('Erreur lors de la mise à jour: $e');
    }
  }

  // Changer le mot de passe
  Future<AuthResult> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final user = await getCurrentUser();
      if (user == null) {
        return AuthResult.error('Utilisateur non connecté');
      }

      // Vérifier le mot de passe actuel
      if (user.password != _hashPassword(currentPassword)) {
        return AuthResult.error('Mot de passe actuel incorrect');
      }

      // Mettre à jour le mot de passe
      final updatedUser = user.copyWith(
        password: _hashPassword(newPassword),
        updatedAt: DateTime.now(),
      );

      return await updateProfile(updatedUser);
    } catch (e) {
      return AuthResult.error('Erreur lors du changement de mot de passe: $e');
    }
  }

  // Synchronisation avec l'API
  Future<void> syncPendingData() async {
    try {
      final pendingItems = await _dbHelper.getPendingSyncItems();

      for (final item in pendingItems) {
        try {
          switch (item['tableName']) {
            case 'users':
              if (item['action'] == 'INSERT') {
                final userData = json.decode(item['data']);
                final user = User.fromJson(userData);
                await _apiService.registerUser(user);
              } else if (item['action'] == 'UPDATE') {
                final userData = json.decode(item['data']);
                final user = User.fromJson(userData);
                await _apiService.updateUser(user);
              }
              break;
            // Ajouter d'autres cas pour companions, bookings, etc.
          }

          // Marquer comme synchronisé
          await _dbHelper.markAsSynced(item['id']);
        } catch (e) {
          print('Erreur de synchronisation pour ${item['tableName']}: $e');
        }
      }
    } catch (e) {
      print('Erreur lors de la synchronisation: $e');
    }
  }

  // Méthodes privées
  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<void> _saveAuthData(String userId, String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userIdKey, userId);
    await prefs.setString(_tokenKey, token);
    await prefs.setBool(_isLoggedInKey, true);
  }
}

// Classe pour les résultats d'authentification
class AuthResult {
  final bool isSuccess;
  final String? error;
  final User? user;
  final String? token;

  AuthResult._({
    required this.isSuccess,
    this.error,
    this.user,
    this.token,
  });

  factory AuthResult.success(User user, [String? token]) {
    return AuthResult._(
      isSuccess: true,
      user: user,
      token: token,
    );
  }

  factory AuthResult.error(String error) {
    return AuthResult._(
      isSuccess: false,
      error: error,
    );
  }
}

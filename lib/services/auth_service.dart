import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  static const String baseUrl = 'https://fidest.ci/rencontre/backend-api/api';
  static const String loginEndpoint = '$baseUrl/login.php';
  static const String registerEndpoint = '$baseUrl/register.php';

  // Vérification de la connectivité réseau
  Future<bool> checkConnectivity() async {
    try {
      // Test direct avec notre API
      final response = await http.get(
        Uri.parse('$baseUrl/status.php'), // ou un endpoint simple de votre API
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 8));

      return response.statusCode < 500;
    } catch (e) {
      debugPrint('DEBUG - Erreur connectivité: $e');
      return false;
    }
  }

  // Connexion utilisateur

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      debugPrint('DEBUG - Tentative de connexion à: $loginEndpoint');
      debugPrint('DEBUG - Email: $email');

      final response = await http
          .post(
            Uri.parse(loginEndpoint),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'email': email,
              'password': password,
            }),
          )
          .timeout(const Duration(seconds: 30));

      debugPrint('DEBUG - Response status: ${response.statusCode}');
      debugPrint('DEBUG - Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['success'] == true) {
          // Sauvegarder les données de session
          await _saveUserSession(data['user']);

          return {
            'success': true,
            'message': data['message'] ?? 'Connexion réussie',
            'user': data['user']
          };
        } else {
          return {
            'success': false,
            'message': data['message'] ?? 'Email ou mot de passe incorrect',
            'error_type': 'auth'
          };
        }
      } else {
        return {
          'success': false,
          'message':
              'Erreur serveur (${response.statusCode}). Réessayez plus tard.',
          'error_type': 'server'
        };
      }
    } catch (e) {
      debugPrint('DEBUG - Erreur login: $e');

      if (e.toString().contains('TimeoutException')) {
        return {
          'success': false,
          'message': 'Connexion trop lente. Vérifiez votre réseau.',
          'error_type': 'timeout'
        };
      }

      if (e.toString().contains('Failed to fetch') ||
          e.toString().contains('ClientException')) {
        return {
          'success': false,
          'message': 'Pas de connexion internet. Vérifiez votre réseau.',
          'error_type': 'network'
        };
      }

      return {
        'success': false,
        'message': 'Erreur de connexion: ${e.toString()}',
        'error_type': 'network'
      };
    }
  }

  // Inscription utilisateur
  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phone,
  }) async {
    try {
      debugPrint('DEBUG - Tentative d\'inscription à: $registerEndpoint');
      debugPrint('DEBUG - Email: $email');

      final response = await http
          .post(
            Uri.parse(registerEndpoint),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'email': email,
              'password': password,
              'firstName': firstName,
              'lastName': lastName,
              'phone': phone,
            }),
          )
          .timeout(const Duration(seconds: 30));

      debugPrint('DEBUG - Register response status: ${response.statusCode}');
      debugPrint('DEBUG - Register response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['success'] == true) {
          // Sauvegarder les données de session
          await _saveUserSession(data['user']);

          return {
            'success': true,
            'message': data['message'] ?? 'Inscription réussie',
            'user': data['user']
          };
        } else {
          return {
            'success': false,
            'message': data['message'] ?? 'Erreur lors de l\'inscription',
            'error_type': 'validation'
          };
        }
      } else {
        return {
          'success': false,
          'message':
              'Erreur serveur (${response.statusCode}). Réessayez plus tard.',
          'error_type': 'server'
        };
      }
    } catch (e) {
      debugPrint('DEBUG - Erreur register: $e');

      if (e.toString().contains('TimeoutException')) {
        return {
          'success': false,
          'message': 'Connexion trop lente. Vérifiez votre réseau.',
          'error_type': 'timeout'
        };
      }

      if (e.toString().contains('Failed to fetch') ||
          e.toString().contains('ClientException')) {
        return {
          'success': false,
          'message': 'Pas de connexion internet. Vérifiez votre réseau.',
          'error_type': 'network'
        };
      }

      return {
        'success': false,
        'message': 'Erreur de connexion: ${e.toString()}',
        'error_type': 'network'
      };
    }
  }

  // Test de connexion (pour debug)
  Future<Map<String, dynamic>> testLoginConnection(
      String email, String password) async {
    debugPrint('DEBUG - Test de connexion pour: $email');

    try {
      final result = await login(email, password);

      return {
        'connectivity': await checkConnectivity(),
        'login_result': result,
        'timestamp': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      return {
        'connectivity': false,
        'error': e.toString(),
        'timestamp': DateTime.now().toIso8601String(),
      };
    }
  }

  // Sauvegarder la session utilisateur
  Future<void> _saveUserSession(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_data', jsonEncode(userData));
    await prefs.setBool('is_logged_in', true);
    await prefs.setString('login_timestamp', DateTime.now().toIso8601String());
  }

  // Vérifier si l'utilisateur est connecté
  Future<bool> isLoggedIn() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool('is_logged_in') ?? false;
    } catch (e) {
      debugPrint('DEBUG - Erreur isLoggedIn: $e');
      return false;
    }
  }

  // Récupérer les données de l'utilisateur actuel
  Future<Map<String, dynamic>?> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userDataString = prefs.getString('user_data');

      if (userDataString != null) {
        return jsonDecode(userDataString);
      }
      return null;
    } catch (e) {
      debugPrint('DEBUG - Erreur getCurrentUser: $e');
      return null;
    }
  }

  // Déconnexion
  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_data');
      await prefs.remove('is_logged_in');
      await prefs.remove('login_timestamp');
    } catch (e) {
      debugPrint('DEBUG - Erreur logout: $e');
    }
  }
}

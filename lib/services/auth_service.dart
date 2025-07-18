import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';

class AuthService {
  static const String _baseUrl = 'https://fidest.ci/rencontre/backend-api/api';
  static Database? _database;

  // Vérifier la connectivité réseau avec timeout court
  Future<bool> checkConnectivity() async {
    try {
      // Test direct avec notre API pour éviter les problèmes de certificats
      final result = await http.get(
        Uri.parse('$_baseUrl/login.php'),
        headers: {
          'Content-Type': 'application/json',
          'User-Agent': 'CompagnieSociale/1.0',
        },
      ).timeout(const Duration(seconds: 8));
      return result.statusCode >= 200 && result.statusCode < 500;
    } catch (e) {
      // Si notre API échoue, essayer un test simple
      try {
        final result = await http.get(
          Uri.parse('https://httpbin.org/status/200'),
          headers: {'User-Agent': 'CompagnieSociale/1.0'},
        ).timeout(const Duration(seconds: 5));
        return result.statusCode == 200;
      } catch (e2) {
        return false;
      }
    }
  }

  // Initialiser la base de données locale
  Future<Database> _initDatabase() async {
    if (_database != null) return _database!;

    // Configuration pour Windows
    if (Platform.isWindows || Platform.isLinux) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'compagnie_sociale.db');

    _database = await openDatabase(
      path,
      version: 2,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            email TEXT UNIQUE NOT NULL,
            password TEXT NOT NULL,
            firstName TEXT,
            lastName TEXT,
            phone TEXT,
            profileImageUrl TEXT,
            isPremium INTEGER DEFAULT 0,
            createdAt TEXT,
            needsSync INTEGER DEFAULT 0
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute(
              'ALTER TABLE users ADD COLUMN isPremium INTEGER DEFAULT 0');
        }
      },
    );

    return _database!;
  }

  // Inscription - essaie directement, le test de connectivité se fait via l'API
  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phone,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/register.php'),
            headers: {
              'Content-Type': 'application/json',
              'User-Agent': 'CompagnieSociale/1.0',
              'Accept': 'application/json',
            },
            body: jsonEncode({
              'email': email,
              'password': password,
              'firstName': firstName,
              'lastName': lastName,
              'phone': phone,
            }),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['success'] == true) {
          // Sauvegarder localement
          final db = await _initDatabase();
          await db.insert('users', {
            'email': email,
            'password': password,
            'firstName': firstName,
            'lastName': lastName,
            'phone': phone,
            'isPremium': 0,
            'createdAt': DateTime.now().toIso8601String(),
            'needsSync': 0,
          });

          // Sauvegarder l'état de connexion
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('isLoggedIn', true);
          await prefs.setString('userEmail', email);
        }

        return data;
      } else {
        return {
          'success': false,
          'message':
              'Erreur serveur (${response.statusCode}). Vérifiez votre connexion.'
        };
      }
    } catch (e) {
      // Inscription hors ligne temporaire pour les tests
      try {
        final db = await _initDatabase();
        await db.insert('users', {
          'email': email,
          'password': password,
          'firstName': firstName,
          'lastName': lastName,
          'phone': phone,
          'isPremium': 0,
          'createdAt': DateTime.now().toIso8601String(),
          'needsSync': 1, // Marquer pour synchronisation ultérieure
        });

        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('userEmail', email);

        return {
          'success': true,
          'message':
              'Compte créé en mode hors ligne. Sera synchronisé dès la connexion.'
        };
      } catch (dbError) {
        return {
          'success': false,
          'message': 'Erreur: Vérifiez votre connexion Internet et réessayez.'
        };
      }
    }
  }

  // Connexion - avec fallback local automatique
  Future<Map<String, dynamic>> login(String email, String password) async {
    final hasConnection = await checkConnectivity();

    if (hasConnection) {
      try {
        final response = await http.post(
          Uri.parse('$_baseUrl/login.php'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'email': email,
            'password': password,
          }),
        );

        final data = jsonDecode(response.body);

        if (data['success']) {
          // Mettre à jour/sauvegarder localement
          final db = await _initDatabase();
          final existingUser = await db.query(
            'users',
            where: 'email = ?',
            whereArgs: [email],
          );

          if (existingUser.isNotEmpty) {
            await db.update(
              'users',
              {
                'password': password,
                'firstName': data['user']['firstName'],
                'lastName': data['user']['lastName'],
                'phone': data['user']['phone'],
                'isPremium': data['user']['isPremium'] ?? 0,
                'needsSync': 0,
              },
              where: 'email = ?',
              whereArgs: [email],
            );
          } else {
            await db.insert('users', {
              'email': email,
              'password': password,
              'firstName': data['user']['firstName'],
              'lastName': data['user']['lastName'],
              'phone': data['user']['phone'],
              'isPremium': data['user']['isPremium'] ?? 0,
              'createdAt': DateTime.now().toIso8601String(),
              'needsSync': 0,
            });
          }

          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('isLoggedIn', true);
          await prefs.setString('userEmail', email);

          return data;
        }

        return data;
      } catch (e) {
        // En cas d'erreur réseau, essayer la connexion locale
      }
    }

    // Connexion locale (fallback automatique)
    try {
      final db = await _initDatabase();
      final users = await db.query(
        'users',
        where: 'email = ? AND password = ?',
        whereArgs: [email, password],
      );

      if (users.isNotEmpty) {
        final user = users.first;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('userEmail', email);

        return {
          'success': true,
          'message': 'Connexion réussie (mode hors ligne)',
          'user': {
            'id': user['id'],
            'email': user['email'],
            'firstName': user['firstName'],
            'lastName': user['lastName'],
            'phone': user['phone'],
            'isPremium': user['isPremium'],
          }
        };
      }

      return {'success': false, 'message': 'Email ou mot de passe incorrect'};
    } catch (e) {
      return {'success': false, 'message': 'Erreur de base de données locale'};
    }
  }

  // Synchronisation en arrière-plan (non-bloquante)
  Future<void> _syncPendingDataInBackground() async {
    final hasConnection = await checkConnectivity();
    if (!hasConnection) return;

    try {
      final db = await _initDatabase();
      final pendingUsers = await db.query(
        'users',
        where: 'needsSync = ?',
        whereArgs: [1],
      );

      for (final user in pendingUsers) {
        try {
          await http.post(
            Uri.parse('$_baseUrl/sync_user.php'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(user),
          );

          await db.update(
            'users',
            {'needsSync': 0},
            where: 'id = ?',
            whereArgs: [user['id']],
          );
        } catch (e) {
          // Continuer avec les autres utilisateurs
        }
      }
    } catch (e) {
      // Synchronisation échouée, réessayer plus tard
    }
  }

  // Synchronisation automatique (appelée par le Timer)
  Future<void> performAutoSync() async {
    await _syncPendingDataInBackground();
  }

  // Déconnexion
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('isLoggedIn');
    await prefs.remove('userEmail');
  }

  // Vérifier si l'utilisateur est connecté
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false;
  }

  // Obtenir l'utilisateur actuel
  Future<Map<String, dynamic>?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('userEmail');

    if (email == null) return null;

    try {
      final db = await _initDatabase();
      final users = await db.query(
        'users',
        where: 'email = ?',
        whereArgs: [email],
      );

      if (users.isNotEmpty) {
        final user = users.first;
        return {
          'id': user['id'],
          'email': user['email'],
          'firstName': user['firstName'],
          'lastName': user['lastName'],
          'phone': user['phone'],
          'isPremium': user['isPremium'],
        };
      }
    } catch (e) {
      // Erreur de base de données
    }

    return null;
  }

  // Nettoyer les ressources
  Future<void> dispose() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}

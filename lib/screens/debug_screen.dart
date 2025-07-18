import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import '../database/database_helper.dart';
import '../models/user.dart';
import '../utils/app_colors.dart';

class DebugScreen extends StatefulWidget {
  const DebugScreen({super.key});

  @override
  State<DebugScreen> createState() => _DebugScreenState();
}

class _DebugScreenState extends State<DebugScreen> {
  String _debugInfo = "Chargement...";
  String _apiStatus = "Test en cours...";
  String _dbStatus = "Vérification en cours...";

  @override
  void initState() {
    super.initState();
    _runDiagnostic();
  }

  Future<void> _runDiagnostic() async {
    final authProvider = context.read<AuthProvider>();
    final dbHelper = DatabaseHelper();

    // 1. Vérifier l'état de l'AuthProvider
    String authInfo = """
📱 ÉTAT AUTHPROVIDER:
- isLoggedIn: ${authProvider.isLoggedIn}
- currentUser: ${authProvider.currentUser?.email ?? 'null'}
- isLoading: ${authProvider.isLoading}
""";

    // 2. Vérifier la base de données locale
    String dbInfo = "";
    try {
      final db = await dbHelper.database;
      final users = await db.query('users', orderBy: 'created_at DESC');
      dbInfo = """
💾 BASE DE DONNÉES LOCALE:
- Nombre d'utilisateurs: ${users.length}
- Utilisateurs: ${users.map((u) => u['email']).join(', ')}
""";
    } catch (e) {
      dbInfo = "❌ Erreur BD locale: $e";
    }

    // 3. Tester la connectivité API
    String apiInfo = "";
    try {
      // Test simple de ping vers l'API
      final response = await _testApiConnection();
      apiInfo = """
🌐 API STATUS:
- URL: ${ApiService.baseUrl}
- Statut: ${response ? '✅ Accessible' : '❌ Inaccessible'}
""";
    } catch (e) {
      apiInfo = """
🌐 API STATUS:
- URL: ${ApiService.baseUrl}
- Erreur: ❌ $e
""";
    }

    setState(() {
      _debugInfo = authInfo + dbInfo + apiInfo;
    });
  }

  Future<void> _testApiRegistration() async {
    setState(() {
      _apiStatus = "Test d'inscription API...";
    });

    try {
      final apiService = ApiService();
      final testUser = User(
        id: 'test-${DateTime.now().millisecondsSinceEpoch}',
        email: 'test-api-${DateTime.now().millisecondsSinceEpoch}@example.com',
        password: 'password123',
        fullName: 'Test API User',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final result = await apiService.registerUser(testUser);

      setState(() {
        _apiStatus = result.isSuccess
            ? "✅ API inscription réussie !"
            : "❌ API inscription échouée: ${result.error}";
      });
    } catch (e) {
      setState(() {
        _apiStatus = "❌ Erreur API: $e";
      });
    }
  }

  Future<void> _checkLocalDatabase() async {
    setState(() {
      _dbStatus = "Vérification base locale...";
    });

    try {
      final dbHelper = DatabaseHelper();
      final db = await dbHelper.database;
      final users = await db.query('users', orderBy: 'created_at DESC');

      setState(() {
        _dbStatus = """
💾 BASE LOCALE DÉTAILLÉE:
- Utilisateurs: ${users.length}
- Détails utilisateurs:
${users.map((u) => '  • ${u['email']} (${u['id']})').join('\n')}
""";
      });
    } catch (e) {
      setState(() {
        _dbStatus = "❌ Erreur: $e";
      });
    }
  }

  Future<bool> _testApiConnection() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/health'),
        headers: const {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      return response.statusCode < 500;
    } catch (e) {
      return false;
    }
  }

  Future<void> _forceSyncData() async {
    final authProvider = context.read<AuthProvider>();
    await authProvider.forcSync();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Synchronisation forcée')),
    );

    // Recharger le diagnostic
    _runDiagnostic();
  }

  Future<void> _fixAuthProvider() async {
    final authProvider = context.read<AuthProvider>();
    final dbHelper = DatabaseHelper();

    try {
      // 1. Vérifier s'il y a un utilisateur en base de données
      final db = await dbHelper.database;
      final users =
          await db.query('users', orderBy: 'created_at DESC', limit: 1);

      if (users.isNotEmpty) {
        final lastUser = users.first;

        // 2. Corriger le problème de type isPremium (int -> bool)
        final correctedUser = User(
          id: lastUser['id'] as String,
          email: lastUser['email'] as String,
          password: lastUser['password'] as String,
          fullName: lastUser['full_name'] as String,
          phone: lastUser['phone'] as String?,
          avatarUrl: lastUser['avatar_url'] as String?,
          dateOfBirth: lastUser['date_of_birth'] as String?,
          gender: lastUser['gender'] as String?,
          location: lastUser['location'] as String?,
          bio: lastUser['bio'] as String?,
          isVerified: (lastUser['is_verified'] as int?) == 1,
          createdAt: DateTime.parse(lastUser['created_at'] as String),
          updatedAt: DateTime.parse(lastUser['updated_at'] as String),
          lastLoginAt: lastUser['last_login_at'] != null
              ? DateTime.parse(lastUser['last_login_at'] as String)
              : null,
          isPremium:
              (lastUser['is_premium'] as int?) == 1, // Correction du type
          totalBookings: lastUser['total_bookings'] as int? ?? 0,
          averageRating:
              (lastUser['average_rating'] as num?)?.toDouble() ?? 0.0,
          totalSavings: (lastUser['total_savings'] as num?)?.toDouble() ?? 0.0,
          preferences: lastUser['preferences'] != null
              ? (lastUser['preferences'] as String).split(',')
              : <String>[],
        );

        // 3. Forcer la synchronisation avec AuthProvider
        await authProvider.forcSync();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Correction appliquée pour ${correctedUser.email}'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Aucun utilisateur trouvé en base de données'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la correction: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }

    // Recharger le diagnostic
    _runDiagnostic();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('🔍 Debug Inscription'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '📋 DIAGNOSTIC COMPLET',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(_debugInfo),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '🧪 TEST API',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(_apiStatus),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _testApiRegistration,
                      child: const Text('Tester inscription API'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '💾 BASE LOCALE',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(_dbStatus),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _checkLocalDatabase,
                      child: const Text('Vérifier base locale'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '🔄 ACTIONS',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _forceSyncData,
                            child: const Text('Forcer sync'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _runDiagnostic,
                            child: const Text('Rafraîchir'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _fixAuthProvider,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('🔧 Corriger AuthProvider'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

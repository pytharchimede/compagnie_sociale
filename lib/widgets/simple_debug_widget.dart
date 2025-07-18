import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import '../database/database_helper.dart';
import '../providers/auth_provider.dart';
import 'package:provider/provider.dart';

class SimpleDebugWidget extends StatefulWidget {
  const SimpleDebugWidget({super.key});

  @override
  State<SimpleDebugWidget> createState() => _SimpleDebugWidgetState();
}

class _SimpleDebugWidgetState extends State<SimpleDebugWidget> {
  String debugResult = "Appuyez sur Diagnostiquer";

  Future<void> runSimpleDiagnostic() async {
    String result = "🔍 DIAGNOSTIC SIMPLE:\n\n";

    try {
      // 1. Vérifier l'AuthProvider
      final authProvider = context.read<AuthProvider>();
      result += "📱 AuthProvider:\n";
      result += "- isLoggedIn: ${authProvider.isLoggedIn}\n";
      result += "- currentUser: ${authProvider.currentUser?.email ?? 'null'}\n";
      result += "- isLoading: ${authProvider.isLoading}\n\n";

      // 2. Vérifier l'AuthService directement
      final authService = AuthService();
      result += "🔐 AuthService:\n";

      final serviceLoggedIn = await authService.isLoggedIn();
      result += "- isLoggedIn: $serviceLoggedIn\n";

      final serviceUser = await authService.getCurrentUser();
      result += "- currentUser: ${serviceUser?.email ?? 'null'}\n";

      if (serviceUser != null) {
        result += "- userId: ${serviceUser.id}\n";
        result += "- fullName: ${serviceUser.fullName}\n";
      }
      result += "\n";

      // 3. Vérifier la base de données
      final dbHelper = DatabaseHelper();
      result += "💾 Base de données locale:\n";

      final db = await dbHelper.database;
      final users =
          await db.query('users', orderBy: 'created_at DESC', limit: 5);

      result += "- Nombre d'utilisateurs: ${users.length}\n";

      if (users.isNotEmpty) {
        result += "- Dernier utilisateur:\n";
        final lastUser = users.first;
        result += "  • Email: ${lastUser['email']}\n";
        result += "  • ID: ${lastUser['id']}\n";
        result += "  • Créé: ${lastUser['created_at']}\n";
      }
      result += "\n";

      // 4. Vérifier les SharedPreferences
      result += "💿 Préférences stockées:\n";
      final prefs = await SharedPreferences.getInstance();
      final storedUserId = prefs.getString('user_id');
      final storedToken = prefs.getString('auth_token');
      final storedLoggedIn = prefs.getBool('is_logged_in');

      result += "- user_id: ${storedUserId ?? 'null'}\n";
      result += "- auth_token: ${storedToken != null ? 'présent' : 'null'}\n";
      result += "- is_logged_in: ${storedLoggedIn ?? 'null'}\n\n";

      // 5. Diagnostic du problème
      result += "🎯 DIAGNOSTIC:\n";

      if (users.isNotEmpty && !authProvider.isLoggedIn) {
        result += "❗ PROBLÈME IDENTIFIÉ:\n";
        result += "- Utilisateur en base locale: OUI\n";
        result += "- AuthProvider connecté: NON\n";
        result += "- Solution: Réinitialiser l'auth\n";
      } else if (users.isEmpty) {
        result += "❗ PROBLÈME:\n";
        result += "- Aucun utilisateur en base locale\n";
        result += "- L'inscription a échoué\n";
      } else if (authProvider.isLoggedIn && authProvider.currentUser != null) {
        result += "✅ Tout semble normal\n";
      }
    } catch (e) {
      result += "❌ Erreur: $e\n";
    }

    setState(() {
      debugResult = result;
    });

    // Afficher aussi dans la console
    print("=== DIAGNOSTIC DEBUG ===");
    print(result);
  }

  Future<void> fixAuthState() async {
    try {
      final authProvider = context.read<AuthProvider>();
      await authProvider.initializeAuth();

      setState(() {
        debugResult =
            "🔄 Authentification réinitialisée.\nRefaites un diagnostic.";
      });

      print("Authentification réinitialisée");
    } catch (e) {
      setState(() {
        debugResult = "❌ Erreur lors de la correction: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🔍 Debug Simple'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: runSimpleDiagnostic,
                    child: const Text('🔍 Diagnostiquer'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: fixAuthState,
                    child: const Text('🔄 Corriger'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    debugResult,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

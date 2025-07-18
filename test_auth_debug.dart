import 'dart:io';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'lib/database/database_helper.dart';

/// Script de test simple pour diagnostiquer le problème d'authentification
/// Exécutez ce script avec: dart run test_auth_debug.dart
void main() async {
  print("🔍 === DIAGNOSTIC AUTHENTIFICATION === 🔍");

  // Initialiser sqflite pour les tests
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  try {
    // 1. Tester la base de données
    print("\n💾 TEST BASE DE DONNÉES:");
    final dbHelper = DatabaseHelper();
    final db = await dbHelper.database;

    final users = await db.query('users', orderBy: 'created_at DESC');
    print("- Nombre d'utilisateurs en base: ${users.length}");

    if (users.isNotEmpty) {
      final lastUser = users.first;
      print("- Dernier utilisateur:");
      print("  • Email: ${lastUser['email']}");
      print("  • ID: ${lastUser['id']}");
      print("  • Créé: ${lastUser['created_at']}");
      print("  • Is Premium: ${lastUser['is_premium']}");
    }

    // 2. Tester AuthService (simulation)
    print("\n🔐 TEST AUTHSERVICE:");

    // Note: AuthService utilise SharedPreferences qui nécessite Flutter,
    // donc nous simulons ici
    print("- AuthService nécessite Flutter pour les SharedPreferences");
    print("- Test impossible en mode script Dart pur");

    // 3. Suggestions
    print("\n🎯 DIAGNOSTIC:");
    if (users.isNotEmpty) {
      print("✅ Base de données locale: OK");
      print("❗ Problème probable: AuthProvider non synchronisé");
      print("💡 Solution: Utiliser le bouton debug dans Flutter");
    } else {
      print("❌ Base de données locale: VIDE");
      print("❗ Problème: Inscription a échoué ou base corrompue");
    }

    print("\n🚀 PROCHAINES ÉTAPES:");
    print("1. Lancez l'application Flutter");
    print("2. Cliquez sur le bouton rouge 🐛 en bas à droite");
    print("3. Appuyez sur 'Diagnostiquer' dans l'écran qui s'ouvre");
    print("4. Si un utilisateur existe, appuyez sur 'Corriger'");
  } catch (e) {
    print("❌ Erreur lors du diagnostic: $e");
  }
}

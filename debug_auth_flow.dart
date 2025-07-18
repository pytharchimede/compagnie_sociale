import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'lib/database/database_helper.dart';
import 'lib/services/auth_service.dart';

/// Script de diagnostic approfondi du flux d'authentification
/// Exécutez avec: dart run debug_auth_flow.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  print("🔍 === DIAGNOSTIC FLUX AUTHENTIFICATION === 🔍");

  // Initialiser sqflite pour les tests
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  try {
    // 1. Vérifier l'état initial
    print("\n📊 === ÉTAT INITIAL === 📊");
    await _checkInitialState();

    // 2. Simuler une inscription
    print("\n🔐 === SIMULATION INSCRIPTION === 🔐");
    await _simulateRegistration();

    // 3. Vérifier l'état après inscription
    print("\n📈 === ÉTAT APRÈS INSCRIPTION === 📈");
    await _checkStateAfterRegistration();

    // 4. Diagnostiquer la synchronisation
    print("\n🔄 === DIAGNOSTIC SYNCHRONISATION === 🔄");
    await _checkSyncState();
  } catch (e) {
    print("❌ Erreur fatale: $e");
    print("Stack trace: ${StackTrace.current}");
  }
}

Future<void> _checkInitialState() async {
  final authService = AuthService();
  final dbHelper = DatabaseHelper();

  // État AuthService
  final isLoggedIn = await authService.isLoggedIn();
  final currentUser = await authService.getCurrentUser();

  print("🔍 AuthService:");
  print("  - isLoggedIn: $isLoggedIn");
  print("  - currentUser: ${currentUser?.email ?? 'null'}");

  // État base de données
  final db = await dbHelper.database;
  final users = await db.query('users', orderBy: 'created_at DESC');

  print("💾 Base de données:");
  print("  - Nombre d'utilisateurs: ${users.length}");
  if (users.isNotEmpty) {
    print("  - Dernier utilisateur: ${users.first['email']}");
  }

  // État SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  final savedUserId = prefs.getString('user_id');
  final savedIsLoggedIn = prefs.getBool('is_logged_in');

  print("💿 SharedPreferences:");
  print("  - user_id: $savedUserId");
  print("  - is_logged_in: $savedIsLoggedIn");
}

Future<void> _simulateRegistration() async {
  final authService = AuthService();

  print("📝 Tentative d'inscription...");

  final result = await authService.register(
    email: 'test-flow-${DateTime.now().millisecondsSinceEpoch}@example.com',
    password: 'password123',
    fullName: 'Test Flow User',
    phone: '+225 01 02 03 04 05',
  );

  if (result.isSuccess) {
    print("✅ Inscription réussie !");
    print("  - Utilisateur: ${result.user?.email}");
    print("  - ID: ${result.user?.id}");
  } else {
    print("❌ Inscription échouée: ${result.error}");
  }
}

Future<void> _checkStateAfterRegistration() async {
  final authService = AuthService();
  final dbHelper = DatabaseHelper();

  // Re-vérifier l'état
  final isLoggedIn = await authService.isLoggedIn();
  final currentUser = await authService.getCurrentUser();

  print("🔍 AuthService après inscription:");
  print("  - isLoggedIn: $isLoggedIn");
  print("  - currentUser: ${currentUser?.email ?? 'null'}");

  // État base de données
  final db = await dbHelper.database;
  final users = await db.query('users', orderBy: 'created_at DESC');

  print("💾 Base de données après inscription:");
  print("  - Nombre d'utilisateurs: ${users.length}");
  if (users.isNotEmpty) {
    final lastUser = users.first;
    print("  - Dernier utilisateur: ${lastUser['email']}");
    print("  - ID: ${lastUser['id']}");
    print("  - isPremium type: ${lastUser['is_premium'].runtimeType}");
    print("  - isPremium value: ${lastUser['is_premium']}");
  }

  // État SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  final savedUserId = prefs.getString('user_id');
  final savedIsLoggedIn = prefs.getBool('is_logged_in');

  print("💿 SharedPreferences après inscription:");
  print("  - user_id: $savedUserId");
  print("  - is_logged_in: $savedIsLoggedIn");
}

Future<void> _checkSyncState() async {
  final dbHelper = DatabaseHelper();

  try {
    final pendingItems = await dbHelper.getPendingSyncItems();

    print("🔄 Queue de synchronisation:");
    print("  - Éléments en attente: ${pendingItems.length}");

    for (final item in pendingItems) {
      print(
          "  - ${item['tableName']} | ${item['action']} | ${item['recordId']}");
    }

    if (pendingItems.isEmpty) {
      print("  ✅ Aucun élément en attente de synchronisation");
    }
  } catch (e) {
    print("❌ Erreur lors de la vérification de la sync: $e");
  }
}

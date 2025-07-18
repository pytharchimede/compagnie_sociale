import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/user.dart';

class DatabaseTestScreen extends StatefulWidget {
  const DatabaseTestScreen({super.key});

  @override
  State<DatabaseTestScreen> createState() => _DatabaseTestScreenState();
}

class _DatabaseTestScreenState extends State<DatabaseTestScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  String _testResult = 'Aucun test effectué';
  bool _isLoading = false;

  Future<void> _testDatabase() async {
    setState(() {
      _isLoading = true;
      _testResult = 'Test en cours...';
    });

    try {
      // Test 1: Initialiser la base de données
      await _dbHelper.database;
      _appendResult('✅ Base de données initialisée');

      // Test 2: Créer un utilisateur de test
      final testUser = User(
        id: 'test-${DateTime.now().millisecondsSinceEpoch}',
        email: 'test@example.com',
        password: 'password123',
        fullName: 'Test User',
        phone: '+225 01 02 03 04 05',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isPremium: true, // Test de la colonne isPremium
        totalBookings: 5,
        averageRating: 4.5,
        totalSavings: 1000.0,
        preferences: ['test', 'preferences'],
      );

      // Test 3: Insérer l'utilisateur
      await _dbHelper.insertUser(testUser);
      _appendResult(
          '✅ Utilisateur inséré avec isPremium: ${testUser.isPremium}');

      // Test 4: Récupérer l'utilisateur
      final retrievedUser = await _dbHelper.getUserByEmail(testUser.email);
      if (retrievedUser != null) {
        _appendResult('✅ Utilisateur récupéré');
        _appendResult('   - ID: ${retrievedUser.id}');
        _appendResult('   - Email: ${retrievedUser.email}');
        _appendResult('   - isPremium: ${retrievedUser.isPremium}');
        _appendResult('   - totalBookings: ${retrievedUser.totalBookings}');
        _appendResult('   - averageRating: ${retrievedUser.averageRating}');
        _appendResult('   - totalSavings: ${retrievedUser.totalSavings}');
        _appendResult('   - preferences: ${retrievedUser.preferences}');
      } else {
        _appendResult('❌ Utilisateur non trouvé');
      }

      // Test 5: Mettre à jour l'utilisateur
      final updatedUser = User(
        id: testUser.id,
        email: testUser.email,
        password: testUser.password,
        fullName: 'Test User Updated',
        phone: testUser.phone,
        createdAt: testUser.createdAt,
        updatedAt: DateTime.now(),
        isPremium: false, // Changer isPremium
        totalBookings: 10,
        averageRating: 4.8,
        totalSavings: 2000.0,
        preferences: ['updated', 'preferences'],
      );

      await _dbHelper.updateUser(updatedUser);
      _appendResult('✅ Utilisateur mis à jour');

      // Test 6: Vérifier la mise à jour
      final finalUser = await _dbHelper.getUserByEmail(testUser.email);
      if (finalUser != null) {
        _appendResult('✅ Mise à jour vérifiée');
        _appendResult('   - fullName: ${finalUser.fullName}');
        _appendResult('   - isPremium: ${finalUser.isPremium}');
        _appendResult('   - totalBookings: ${finalUser.totalBookings}');
      }

      // Test 7: Supprimer l'utilisateur de test
      await _dbHelper.deleteUser(testUser.id);
      _appendResult('✅ Utilisateur de test supprimé');

      _appendResult('\n🎉 TOUS LES TESTS RÉUSSIS !');
      _appendResult('La base de données SQLite est correctement configurée.');
    } catch (e, stackTrace) {
      _appendResult('❌ ERREUR: $e');
      _appendResult('Stack trace: $stackTrace');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _appendResult(String message) {
    setState(() {
      _testResult += '\n$message';
    });
  }

  void _clearResults() {
    setState(() {
      _testResult = 'Aucun test effectué';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Base de Données'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: _isLoading ? null : _testDatabase,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      'Lancer le Test de Base de Données',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _clearResults,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text(
                'Effacer les Résultats',
                style: TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey[50],
                ),
                child: SingleChildScrollView(
                  child: Text(
                    _testResult,
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

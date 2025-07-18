import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/app_colors.dart';
import 'database_test_screen.dart';
import '../widgets/gradient_button.dart';
import 'login_screen.dart';
import '../database/database_helper.dart';
import '../services/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _debugInfo = "";

  Future<void> _runQuickDiagnosis() async {
    final authProvider = context.read<AuthProvider?>();
    final authService = AuthService();
    final dbHelper = DatabaseHelper();

    String info = "🔍 DIAGNOSTIC RAPIDE:\n\n";

    // AuthProvider state
    info += "📱 AuthProvider:\n";
    if (authProvider != null) {
      info += "- isLoggedIn: ${authProvider.isLoggedIn}\n";
      info += "- currentUser: ${authProvider.currentUser?.email ?? 'null'}\n";
      info += "- isLoading: ${authProvider.isLoading}\n\n";
    } else {
      info += "- AuthProvider not found\n\n";
    }

    // AuthService state
    info += "🔐 AuthService:\n";
    try {
      final isLoggedIn = await authService.isLoggedIn();
      final currentUser = await authService.getCurrentUser();
      info += "- isLoggedIn: $isLoggedIn\n";
      info += "- currentUser: ${currentUser?['email'] ?? 'null'}\n\n";
    } catch (e) {
      info += "- Erreur: $e\n\n";
    }

    // Database check
    info += "💾 Base de données:\n";
    try {
      // Récupérer le dernier utilisateur créé
      final db = await dbHelper.database;
      final result = await db.query(
        'users',
        orderBy: 'created_at DESC',
        limit: 1,
      );

      if (result.isNotEmpty) {
        final lastUser = result.first;
        info += "- Dernier utilisateur: ${lastUser['email']}\n";
        info += "- ID: ${lastUser['id']}\n";
        info += "- Créé: ${lastUser['created_at']}\n";
      } else {
        info += "- Aucun utilisateur en base locale\n";
      }
    } catch (e) {
      info += "- Erreur BD: $e\n";
    }

    setState(() {
      _debugInfo = info;
    });

    // Afficher dans un dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🔍 Diagnostic'),
        content: SingleChildScrollView(
          child: Text(_debugInfo),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fermer'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _fixAuthState();
            },
            child: const Text('Corriger'),
          ),
        ],
      ),
    );
  }

  Future<void> _fixAuthState() async {
    final authProvider = context.read<AuthProvider?>();

    try {
      // Réinitialiser l'authentification
      if (authProvider != null) {
        await authProvider.initializeAuth();
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('État d\'authentification réinitialisé'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _logout() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Déconnexion'),
        content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Déconnexion'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await authProvider.logout();
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Profil'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Consumer<AuthProvider?>(
        builder: (context, authProvider, child) {
          final user = authProvider?.currentUser;

          if (user == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Aucun utilisateur connecté',
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: _runQuickDiagnosis,
                    icon: const Icon(Icons.bug_report),
                    label: const Text('🔍 Diagnostic'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: _fixAuthState,
                    icon: const Icon(Icons.refresh),
                    label: const Text('🔄 Corriger'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                // Photo de profil et informations de base
                Center(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: AppColors.primary.withOpacity(0.1),
                        backgroundImage: user.avatarUrl != null
                            ? NetworkImage(user.avatarUrl!)
                            : null,
                        child: user.avatarUrl == null
                            ? Icon(
                                Icons.person,
                                size: 60,
                                color: AppColors.primary,
                              )
                            : null,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        user.fullName,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.email,
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (user.phone != null)
                        Text(
                          user.phone!,
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Statistiques
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem(
                        'Réservations',
                        user.totalBookings.toString(),
                        Icons.book_online,
                      ),
                      _buildStatItem(
                        'Note moyenne',
                        user.averageRating.toStringAsFixed(1),
                        Icons.star,
                      ),
                      _buildStatItem(
                        'Économies',
                        '${user.totalSavings.toStringAsFixed(0)} FCFA',
                        Icons.savings,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Actions
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Fonction à venir'),
                          ),
                        );
                      },
                      icon: Icon(Icons.edit, color: AppColors.primary),
                      label: Text(
                        'Modifier le profil',
                        style: TextStyle(color: AppColors.primary),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(color: AppColors.primary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Fonction à venir'),
                          ),
                        );
                      },
                      icon: Icon(Icons.lock, color: AppColors.primary),
                      label: Text(
                        'Changer le mot de passe',
                        style: TextStyle(color: AppColors.primary),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(color: AppColors.primary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const DatabaseTestScreen(),
                          ),
                        );
                      },
                      icon: Icon(Icons.storage, color: AppColors.primary),
                      label: Text(
                        'Test Base de Données',
                        style: TextStyle(color: AppColors.primary),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(color: AppColors.primary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    GradientButton(
                      text: 'Se déconnecter',
                      onPressed: _logout,
                      icon: Icons.logout,
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          color: AppColors.primary,
          size: 28,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

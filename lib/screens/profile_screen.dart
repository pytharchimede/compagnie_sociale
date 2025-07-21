import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/app_colors.dart';
import '../widgets/gradient_button.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  
  Future<void> _logout() async {
    final authProvider = context.read<AuthProvider>();
    await authProvider.logout();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Profil'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          final user = authProvider.currentUser;
          
          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Photo de profil et informations utilisateur
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        // Avatar
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: AppColors.primary.withOpacity(0.1),
                          child: Icon(
                            Icons.person,
                            size: 50,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Nom complet
                        if (user != null) ...[
                          Text(
                            user.fullName,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          
                          // Email
                          Text(
                            user.email,
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          
                          // Téléphone
                          if (user.phone?.isNotEmpty == true)
                            Text(
                              user.phone!,
                              style: TextStyle(
                                fontSize: 16,
                                color: AppColors.textSecondary,
                              ),
                            ),
                        ] else ...[
                          const Text(
                            'Utilisateur non connecté',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                
                // Options du profil
                Expanded(
                  child: ListView(
                    children: [
                      ListTile(
                        leading: Icon(Icons.person_outline, color: AppColors.primary),
                        title: const Text('Modifier le profil'),
                        trailing: Icon(Icons.arrow_forward_ios, color: AppColors.textSecondary),
                        onTap: () {
                          // TODO: Implémenter la modification du profil
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Fonctionnalité en cours de développement'),
                            ),
                          );
                        },
                      ),
                      const Divider(),
                      
                      ListTile(
                        leading: Icon(Icons.notifications, color: AppColors.primary),
                        title: const Text('Notifications'),
                        trailing: Icon(Icons.arrow_forward_ios, color: AppColors.textSecondary),
                        onTap: () {
                          // TODO: Implémenter les paramètres de notifications
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Fonctionnalité en cours de développement'),
                            ),
                          );
                        },
                      ),
                      const Divider(),
                      
                      ListTile(
                        leading: Icon(Icons.privacy_tip, color: AppColors.primary),
                        title: const Text('Confidentialité'),
                        trailing: Icon(Icons.arrow_forward_ios, color: AppColors.textSecondary),
                        onTap: () {
                          // TODO: Implémenter les paramètres de confidentialité
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Fonctionnalité en cours de développement'),
                            ),
                          );
                        },
                      ),
                      const Divider(),
                      
                      ListTile(
                        leading: Icon(Icons.help_outline, color: AppColors.primary),
                        title: const Text('Aide & Support'),
                        trailing: Icon(Icons.arrow_forward_ios, color: AppColors.textSecondary),
                        onTap: () {
                          // TODO: Implémenter l'aide et le support
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Fonctionnalité en cours de développement'),
                            ),
                          );
                        },
                      ),
                      const Divider(),
                      
                      ListTile(
                        leading: Icon(Icons.info_outline, color: AppColors.primary),
                        title: const Text('À propos'),
                        trailing: Icon(Icons.arrow_forward_ios, color: AppColors.textSecondary),
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('À propos'),
                              content: const Text(
                                'Compagnie Sociale CI\n'
                                'Version 1.0.0\n\n'
                                'Application de services de compagnie sociale pour la Côte d\'Ivoire.',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: const Text('Fermer'),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Bouton de déconnexion
                GradientButton(
                  text: 'Se déconnecter',
                  onPressed: _logout,
                  icon: Icons.logout,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/app_colors.dart';
import '../providers/user_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          final user = userProvider.currentUser;
          
          if (user == null) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.orange,
              ),
            );
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                _buildHeader(context, user),
                const SizedBox(height: 24),
                _buildUserStats(context, user),
                const SizedBox(height: 24),
                _buildPremiumCard(context, user),
                const SizedBox(height: 24),
                _buildMenuSections(context),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, user) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.primaryGradient,
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Mon Profil',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.settings,
                      color: AppColors.white,
                    ),
                    onPressed: () {
                      // Open settings
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Profile photo and info
              Row(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: AppColors.white,
                        backgroundImage: user.profileImage != null
                            ? NetworkImage(user.profileImage!)
                            : null,
                        child: user.profileImage == null
                            ? const Icon(
                                Icons.person,
                                size: 40,
                                color: AppColors.mediumGray,
                              )
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          decoration: const BoxDecoration(
                            color: AppColors.white,
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.camera_alt,
                              color: AppColors.orange,
                              size: 16,
                            ),
                            onPressed: () {
                              // Change profile photo
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 20),
                  
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                user.name,
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  color: AppColors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            if (user.isPremium)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.gold,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.star,
                                      color: AppColors.white,
                                      size: 12,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Premium',
                                      style: TextStyle(
                                        color: AppColors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user.email,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.white.withOpacity(0.9),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              color: AppColors.white,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              user.location,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.white.withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserStats(BuildContext context, user) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.darkGray.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            _buildStatItem(
              context,
              user.totalBookings.toString(),
              'Réservations',
              Icons.calendar_today,
              AppColors.orange,
            ),
            _buildStatDivider(),
            _buildStatItem(
              context,
              user.averageRating.toStringAsFixed(1),
              'Note Moyenne',
              Icons.star,
              AppColors.gold,
            ),
            _buildStatDivider(),
            _buildStatItem(
              context,
              '${(user.totalSavings / 1000).toStringAsFixed(0)}K',
              'Économies FCFA',
              Icons.savings,
              AppColors.green,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String value,
    String label,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.mediumGray,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStatDivider() {
    return Container(
      height: 40,
      width: 1,
      color: AppColors.mediumGray.withOpacity(0.3),
      margin: const EdgeInsets.symmetric(horizontal: 12),
    );
  }

  Widget _buildPremiumCard(BuildContext context, user) {
    if (user.isPremium) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.gold, AppColors.orange],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Icon(
                Icons.star,
                color: AppColors.white,
                size: 32,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Membre Premium',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Réductions exclusives • Support prioritaire',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: AppColors.accentGradient,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.workspace_premium,
                  color: AppColors.white,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Passer au Premium',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '• Réductions exclusives jusqu\'à 20%\n• Support client prioritaire\n• Accès aux événements VIP',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.white.withOpacity(0.9),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                context.read<UserProvider>().upgradeToPremium();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.white,
                foregroundColor: AppColors.royalBlue,
              ),
              child: const Text('Découvrir Premium'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuSections(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMenuSection(
            context,
            'Compte',
            [
              _buildMenuItem(
                context,
                'Modifier le profil',
                Icons.edit,
                () {},
              ),
              _buildMenuItem(
                context,
                'Moyens de paiement',
                Icons.payment,
                () {},
              ),
              _buildMenuItem(
                context,
                'Sécurité',
                Icons.security,
                () {},
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildMenuSection(
            context,
            'Préférences',
            [
              _buildMenuItem(
                context,
                'Notifications',
                Icons.notifications,
                () {},
              ),
              _buildMenuItem(
                context,
                'Localisation',
                Icons.location_on,
                () {},
              ),
              _buildMenuItem(
                context,
                'Paramètres',
                Icons.settings,
                () {},
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildMenuSection(
            context,
            'Support',
            [
              _buildMenuItem(
                context,
                'Centre d\'aide',
                Icons.help,
                () {},
              ),
              _buildMenuItem(
                context,
                'Nous contacter',
                Icons.contact_support,
                () {},
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildMenuItem(
            context,
            'Se déconnecter',
            Icons.logout,
            () {
              _showLogoutDialog(context);
            },
            isDestructive: true,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection(
    BuildContext context,
    String title,
    List<Widget> items,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.mediumGray,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.darkGray.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(children: items),
        ),
      ],
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: !isDestructive ? [
          BoxShadow(
            color: AppColors.darkGray.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ] : null,
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isDestructive ? AppColors.error : AppColors.darkGray,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isDestructive ? AppColors.error : AppColors.darkGray,
            fontWeight: isDestructive ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: isDestructive ? AppColors.error : AppColors.mediumGray,
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Se déconnecter'),
          content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                context.read<UserProvider>().logout();
                Navigator.of(context).pop();
                // Navigate to login screen
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
              ),
              child: const Text('Se déconnecter'),
            ),
          ],
        );
      },
    );
  }
}

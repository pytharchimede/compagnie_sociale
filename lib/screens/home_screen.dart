import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/app_colors.dart';
import '../providers/companion_provider.dart';
import '../providers/user_provider.dart';
import '../widgets/gradient_button.dart';
import '../widgets/companion_card.dart';
import '../widgets/service_card.dart';
import '../widgets/stats_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _headerAnimationController;
  late AnimationController _cardAnimationController;
  late Animation<double> _headerAnimation;
  late Animation<double> _cardAnimation;

  @override
  void initState() {
    super.initState();

    _headerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _cardAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _headerAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _headerAnimationController,
      curve: Curves.easeOutBack,
    ));

    _cardAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _cardAnimationController,
      curve: Curves.elasticOut,
    ));

    // Démarrer les animations
    _headerAnimationController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _cardAnimationController.forward();
    });

    // Initialiser les données
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CompanionProvider>().initializeCompanions();
      context.read<UserProvider>().initializeUser();
    });
  }

  @override
  void dispose() {
    _headerAnimationController.dispose();
    _cardAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              _buildServicesGrid(),
              const SizedBox(height: 32),
              _buildStatsSection(),
              const SizedBox(height: 32),
              _buildFeaturedCompanions(),
              const SizedBox(height: 24),
              _buildCallToAction(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return AnimatedBuilder(
      animation: _headerAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _headerAnimation.value,
          child: Container(
            height: 200,
            decoration: const BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Stack(
              children: [
                // Background pattern
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                      ),
                      gradient: LinearGradient(
                        colors: [
                          AppColors.white.withOpacity(0.1),
                          AppColors.white.withOpacity(0.05),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                ),

                // Content
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top bar
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Consumer<UserProvider>(
                            builder: (context, userProvider, child) {
                              final user = userProvider.currentUser;
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Akwaba ! 👋',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineMedium
                                        ?.copyWith(
                                          color: AppColors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                  Text(
                                    user?.name ?? 'Cher utilisateur',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.copyWith(
                                          color:
                                              AppColors.white.withOpacity(0.9),
                                        ),
                                  ),
                                ],
                              );
                            },
                          ),

                          // Notification icon
                          Container(
                            decoration: BoxDecoration(
                              color: AppColors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: IconButton(
                              icon: const Icon(
                                Icons.notifications_outlined,
                                color: AppColors.white,
                              ),
                              onPressed: () {},
                            ),
                          ),
                        ],
                      ),

                      const Spacer(),

                      // Location
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            color: AppColors.white,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '📍 Abidjan, Côte d\'Ivoire',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: AppColors.white.withOpacity(0.9),
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildServicesGrid() {
    final services = [
      {
        'title': 'Guides\nTouristiques',
        'icon': Icons.location_on,
        'color': AppColors.green,
      },
      {
        'title': 'Événements\nSociaux',
        'icon': Icons.celebration,
        'color': AppColors.gold,
      },
      {
        'title': 'Sécurité &\nEscort',
        'icon': Icons.security,
        'color': AppColors.redOrange,
      },
      {
        'title': 'Services\nVIP',
        'icon': Icons.star,
        'color': AppColors.royalBlue,
      },
    ];

    return AnimatedBuilder(
      animation: _cardAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - _cardAnimation.value)),
          child: Opacity(
            opacity: _cardAnimation.value,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Nos Services',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.2,
                    ),
                    itemCount: services.length,
                    itemBuilder: (context, index) {
                      final service = services[index];
                      return ServiceCard(
                        title: service['title'] as String,
                        icon: service['icon'] as IconData,
                        color: service['color'] as Color,
                        onTap: () {
                          // Navigate to specific service
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatsSection() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: StatsWidget(),
    );
  }

  Widget _buildFeaturedCompanions() {
    return Consumer<CompanionProvider>(
      builder: (context, companionProvider, child) {
        if (companionProvider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(
              color: AppColors.orange,
            ),
          );
        }

        final featuredCompanions = companionProvider.featuredCompanions;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Professionnels en Vedette',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  TextButton(
                    onPressed: () {
                      // Navigate to search screen
                    },
                    child: const Text('Voir tout'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 280,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: featuredCompanions.length,
                itemBuilder: (context, index) {
                  final companion = featuredCompanions[index];
                  return Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: SizedBox(
                      width: 200,
                      child: CompanionCard(
                        companion: companion,
                        onTap: () {
                          // Navigate to companion details
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCallToAction() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: AppColors.accentGradient,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Devenir Prestataire',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Rejoignez notre communauté de professionnels vérifiés et développez votre activité.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.white.withOpacity(0.9),
                  ),
            ),
            const SizedBox(height: 16),
            GradientButton(
              text: 'S\'inscrire maintenant',
              onPressed: () {
                // Navigate to provider registration
              },
              gradient: LinearGradient(
                colors: [
                  AppColors.white.withOpacity(0.2),
                  AppColors.white.withOpacity(0.1),
                ],
              ),
              textColor: AppColors.white,
            ),
          ],
        ),
      ),
    );
  }
}

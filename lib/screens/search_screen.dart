import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/app_colors.dart';
import '../providers/companion_provider.dart';
import '../widgets/companion_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recherche'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildCategoryFilters(),
          Expanded(
            child: _buildSearchResults(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.lightGray,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.darkGray.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (value) {
            context.read<CompanionProvider>().setSearchQuery(value);
          },
          decoration: InputDecoration(
            hintText: 'Rechercher un professionnel...',
            prefixIcon: const Icon(
              Icons.search,
              color: AppColors.mediumGray,
            ),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(
                      Icons.clear,
                      color: AppColors.mediumGray,
                    ),
                    onPressed: () {
                      _searchController.clear();
                      context.read<CompanionProvider>().setSearchQuery('');
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryFilters() {
    return Consumer<CompanionProvider>(
      builder: (context, companionProvider, child) {
        return Container(
          height: 50,
          margin: const EdgeInsets.only(bottom: 20),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: companionProvider.categories.length,
            itemBuilder: (context, index) {
              final category = companionProvider.categories[index];
              final isSelected = category == companionProvider.selectedCategory;
              
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: FilterChip(
                  label: Text(category),
                  selected: isSelected,
                  onSelected: (selected) {
                    companionProvider.setCategory(category);
                  },
                  backgroundColor: AppColors.lightGray,
                  selectedColor: AppColors.orange,
                  labelStyle: TextStyle(
                    color: isSelected ? AppColors.white : AppColors.darkGray,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildSearchResults() {
    return Consumer<CompanionProvider>(
      builder: (context, companionProvider, child) {
        if (companionProvider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(
              color: AppColors.orange,
            ),
          );
        }

        final companions = companionProvider.filteredCompanions;

        if (companions.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.search_off,
                  size: 64,
                  color: AppColors.mediumGray.withOpacity(0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  'Aucun professionnel trouvé',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppColors.mediumGray,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Essayez de modifier vos critères de recherche',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.mediumGray,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: companions.length,
          itemBuilder: (context, index) {
            final companion = companions[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildCompanionListItem(companion),
            );
          },
        );
      },
    );
  }

  Widget _buildCompanionListItem(companion) {
    return Container(
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                companion.image,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 80,
                    height: 80,
                    color: AppColors.lightGray,
                    child: const Icon(
                      Icons.person,
                      color: AppColors.mediumGray,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 16),
            
            // Informations
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          companion.name,
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (companion.verified)
                        const Icon(
                          Icons.verified,
                          color: AppColors.royalBlue,
                          size: 16,
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    companion.specialty,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.mediumGray,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.star,
                        color: AppColors.gold,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${companion.rating} (${companion.reviews} avis)',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${companion.price.toInt()} FCFA/h',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: AppColors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: companion.available 
                              ? AppColors.success.withOpacity(0.1)
                              : AppColors.error.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          companion.available ? 'Disponible' : 'Occupé',
                          style: TextStyle(
                            color: companion.available 
                                ? AppColors.success
                                : AppColors.error,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Bouton contact
            IconButton(
              onPressed: () {
                // Navigate to chat or contact
              },
              icon: const Icon(
                Icons.chat_bubble_outline,
                color: AppColors.orange,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/companion.dart';
import '../utils/app_colors.dart';

class CompanionCard extends StatelessWidget {
  final Companion companion;
  final VoidCallback onTap;
  final bool showFullDetails;

  const CompanionCard({
    super.key,
    required this.companion,
    required this.onTap,
    this.showFullDetails = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image avec badges
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  child: CachedNetworkImage(
                    imageUrl: companion.image,
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      height: 120,
                      color: AppColors.lightGray,
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.orange,
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      height: 120,
                      color: AppColors.lightGray,
                      child: const Icon(
                        Icons.person,
                        size: 40,
                        color: AppColors.mediumGray,
                      ),
                    ),
                  ),
                ),
                
                // Badge disponibilité
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: companion.available ? AppColors.success : AppColors.error,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      companion.available ? 'Disponible' : 'Occupé',
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                
                // Badge vérification
                if (companion.verified)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppColors.royalBlue,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.verified,
                        color: AppColors.white,
                        size: 12,
                      ),
                    ),
                  ),
              ],
            ),
            
            // Informations
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nom et rating
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            companion.name,
                            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              color: AppColors.gold,
                              size: 14,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              companion.rating.toString(),
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 4),
                    
                    // Spécialité
                    Text(
                      companion.specialty,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.mediumGray,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    const SizedBox(height: 4),
                    
                    // Localisation
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          color: AppColors.mediumGray,
                          size: 12,
                        ),
                        const SizedBox(width: 2),
                        Expanded(
                          child: Text(
                            companion.location,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.mediumGray,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    
                    if (showFullDetails) ...[
                      const SizedBox(height: 8),
                      
                      // Langues
                      Wrap(
                        spacing: 4,
                        children: companion.languages.take(2).map((language) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.lightGray,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              language,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontSize: 9,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      
                      const Spacer(),
                      
                      // Prix et bouton
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${companion.price.toInt()} FCFA',
                                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                  color: AppColors.orange,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'par heure',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.mediumGray,
                                  fontSize: 9,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.orange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.chat,
                              color: AppColors.orange,
                              size: 16,
                            ),
                          ),
                        ],
                      ),
                    ],
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

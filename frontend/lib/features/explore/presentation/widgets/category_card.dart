import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:tortutip/config/theme/app_colors.dart';
import 'package:tortutip/config/theme/app_spacing.dart';
import 'package:tortutip/config/theme/app_typography.dart';
import 'package:tortutip/features/categories/domain/entities/category_entity.dart';
import 'package:tortutip/shared/widgets/tortutip_skeleton.dart';

class CategoryCard extends StatelessWidget {
  final CategoryEntity category;
  final VoidCallback onTap;

  const CategoryCard({
    super.key,
    required this.category,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final style = _getCategoryStyle(category.name);

    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        child: SizedBox(
          height: AppSpacing.categoryCardHeight,
          child: Stack(
            fit: StackFit.expand,
            children: [
              CachedNetworkImage(
                imageUrl: category.iconUrl,
                fit: BoxFit.cover,
                placeholder: (_, _) => const TortuSkeletonImage(),
                errorWidget: (context, url, error) => Container(
                  color: AppColors.surface,
                ),
              ),
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [AppColors.transparent, AppColors.overlayDark],
                    stops: [0.3, 1.0],
                  ),
                ),
              ),
              Positioned(
                bottom: AppSpacing.md,
                left: AppSpacing.md,
                right: AppSpacing.md,
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: style.$1,
                      child: Icon(style.$2, color: AppColors.white, size: 16),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        category.name,
                        style: AppTypography.bodyLg.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Category-specific styles map content categories to brand colors and icons.
  // Colors are intentional overrides — they represent category identities, not UI states.
  (Color, IconData) _getCategoryStyle(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('food') || lower.contains('nutrition') || lower.contains('comida') || lower.contains('nutrición') || lower.contains('healthy')) {
      return (const Color(0xFFF5C842), Icons.restaurant);
    }
    if (lower.contains('fitness') || lower.contains('movement') || lower.contains('ejercicio') || lower.contains('sport') || lower.contains('deporte')) {
      return (const Color(0xFF5B8A3C), Icons.fitness_center);
    }
    if (lower.contains('meditation') || lower.contains('mindfulness') || lower.contains('meditación') || lower.contains('zen')) {
      return (const Color(0xFF5B7FD4), Icons.self_improvement);
    }
    if (lower.contains('mental') || lower.contains('sleep') || lower.contains('sueño') || lower.contains('mente') || lower.contains('psicología')) {
      return (const Color(0xFFE87844), Icons.psychology);
    }
    if (lower.contains('habit') || lower.contains('hábito') || lower.contains('routine') || lower.contains('rutina') || lower.contains('productiv')) {
      return (const Color(0xFF7E57C2), Icons.task_alt);
    }
    if (lower.contains('stress') || lower.contains('estrés') || lower.contains('anxiety') || lower.contains('ansiedad') || lower.contains('calm') || lower.contains('relax')) {
      return (const Color(0xFF26A69A), Icons.spa);
    }
    if (lower.contains('relation') || lower.contains('relación') || lower.contains('social') || lower.contains('comunidad') || lower.contains('community')) {
      return (const Color(0xFFEF5350), Icons.favorite);
    }
    if (lower.contains('finance') || lower.contains('finanza') || lower.contains('money') || lower.contains('dinero') || lower.contains('economic')) {
      return (const Color(0xFF66BB6A), Icons.savings);
    }
    if (lower.contains('learn') || lower.contains('aprender') || lower.contains('educación') || lower.contains('knowledge') || lower.contains('conocimiento')) {
      return (const Color(0xFF42A5F5), Icons.menu_book);
    }
    if (lower.contains('nature') || lower.contains('naturaleza') || lower.contains('environment') || lower.contains('eco') || lower.contains('outdoor')) {
      return (const Color(0xFF4CAF50), Icons.eco);
    }
    if (lower.contains('breath') || lower.contains('respiración') || lower.contains('oxygen') || lower.contains('air')) {
      return (const Color(0xFF80DEEA), Icons.air);
    }
    if (lower.contains('water') || lower.contains('agua') || lower.contains('hydrat')) {
      return (const Color(0xFF29B6F6), Icons.water_drop);
    }
    // Deterministic fallback based on name hash — ensures same category always gets same icon
    final icons = [Icons.auto_awesome, Icons.lightbulb, Icons.explore, Icons.star, Icons.bolt, Icons.local_fire_department];
    final colors = [const Color(0xFF8D6E63), const Color(0xFFAB47BC), const Color(0xFF26C6DA), const Color(0xFFFF7043), const Color(0xFF78909C), const Color(0xFFFFCA28)];
    final idx = name.codeUnits.fold(0, (a, b) => a + b) % icons.length;
    return (colors[idx], icons[idx]);
  }
}

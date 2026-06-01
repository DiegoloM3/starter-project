import 'package:flutter/material.dart';
import '../../config/theme/app_colors.dart';
import '../../config/theme/app_spacing.dart';
import '../../config/theme/app_typography.dart';

class TortuCategoryChip extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color textColor;

  const TortuCategoryChip({
    super.key,
    required this.label,
    required this.backgroundColor,
    required this.textColor,
  });

  factory TortuCategoryChip.healthyFood() => const TortuCategoryChip(
        label: 'Healthy Food',
        backgroundColor: AppColors.categoryHealthyFood,
        textColor: AppColors.textOnYellow,
      );

  factory TortuCategoryChip.fitness() => const TortuCategoryChip(
        label: 'Fitness',
        backgroundColor: AppColors.categoryFitness,
        textColor: AppColors.textOnGreen,
      );

  factory TortuCategoryChip.mentalHealth() => const TortuCategoryChip(
        label: 'Mental Health',
        backgroundColor: AppColors.categoryMentalHealth,
        textColor: AppColors.textOnPurple,
      );

  factory TortuCategoryChip.fromName(String name) {
    final colors = chipColorForCategoryName(name);
    return TortuCategoryChip(
      label: name,
      backgroundColor: colors.$1,
      textColor: colors.$2,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
      ),
      child: Text(
        label.toUpperCase(),
        style: AppTypography.labelSm.copyWith(color: textColor),
      ),
    );
  }
}

class TortuOutlineChip extends StatelessWidget {
  final String label;

  const TortuOutlineChip({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        border: Border.all(color: AppColors.borderStrong, width: 1),
      ),
      child: Text(
        label.toUpperCase(),
        style: AppTypography.labelSm.copyWith(color: AppColors.textPrimary),
      ),
    );
  }
}

(Color, Color) chipColorForCategoryName(String name) {
  final lower = name.toLowerCase();
  if (lower.contains('food') || lower.contains('comida') ||
      lower.contains('aliment') || lower.contains('nutrici') ||
      lower.contains('healthy') || lower.contains('saludable')) {
    return (AppColors.categoryHealthyFood, AppColors.textOnYellow);
  }
  if (lower.contains('fitness') || lower.contains('ejercicio') ||
      lower.contains('deporte') || lower.contains('entren') ||
      lower.contains('activ') || lower.contains('gym')) {
    return (AppColors.categoryFitness, AppColors.textOnGreen);
  }
  if (lower.contains('mental') || lower.contains('salud') ||
      lower.contains('health') || lower.contains('mente') ||
      lower.contains('bienestar') || lower.contains('wellbeing')) {
    return (AppColors.categoryMentalHealth, AppColors.textOnPurple);
  }
  if (lower.contains('sueño') || lower.contains('sleep') ||
      lower.contains('descanso') || lower.contains('rest')) {
    return (AppColors.categorySueno, AppColors.textOnBlue);
  }
  // Fallback: color determinista basado en el nombre para que siempre haya color
  final palette = [
    (AppColors.categoryHealthyFood, AppColors.textOnYellow),
    (AppColors.categoryFitness, AppColors.textOnGreen),
    (AppColors.categoryMentalHealth, AppColors.textOnPurple),
    (AppColors.categorySueno, AppColors.textOnBlue),
  ];
  final index = name.codeUnits.fold(0, (a, b) => a + b) % palette.length;
  return palette[index];
}

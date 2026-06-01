import 'package:flutter/material.dart';
import 'package:tortutip/config/theme/app_colors.dart';
import 'package:tortutip/config/theme/app_spacing.dart';

class ArticleActionBar extends StatelessWidget {
  final bool isSaved;
  final VoidCallback onToggleSave;

  const ArticleActionBar({
    super.key,
    required this.isSaved,
    required this.onToggleSave,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Row(
        children: [
          IconButton(
            onPressed: onToggleSave,
            icon: Icon(
              isSaved ? Icons.bookmark : Icons.bookmark_outline,
              color: isSaved ? AppColors.primary : AppColors.textSecondary,
              size: AppSpacing.iconMd,
            ),
            tooltip: isSaved ? 'Guardado' : 'Guardar',
          ),
        ],
      ),
    );
  }
}

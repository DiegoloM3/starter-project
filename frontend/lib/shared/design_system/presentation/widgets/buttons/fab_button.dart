import 'package:flutter/material.dart';
import 'package:news_app_clean_architecture/config/theme/app_colors.dart';
import 'package:news_app_clean_architecture/config/theme/app_dimensions.dart';
import 'package:news_app_clean_architecture/config/theme/app_shadows.dart';

class FabButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;

  const FabButton({
    super.key,
    this.icon = Icons.add,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: AppDimensions.fabSize,
        height: AppDimensions.fabSize,
        decoration: const BoxDecoration(
          color: AppColors.accentGreen,
          shape: BoxShape.circle,
          boxShadow: AppShadows.ctaGreen,
        ),
        child: Center(
          child: Icon(icon, size: AppDimensions.iconXl, color: AppColors.white),
        ),
      ),
    );
  }
}

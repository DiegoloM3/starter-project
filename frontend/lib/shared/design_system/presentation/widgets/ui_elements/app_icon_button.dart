import 'package:flutter/material.dart';
import 'package:news_app_clean_architecture/config/theme/app_dimensions.dart';
import 'package:news_app_clean_architecture/config/theme/app_shadows.dart';
import 'package:news_app_clean_architecture/config/theme/theme_extensions.dart';

class AppIconButton extends StatelessWidget {
  final IconData icon;
  final double size;
  final double iconSize;
  final Color? iconColor;
  final Color? backgroundColor;
  final bool circular;
  final List<BoxShadow>? boxShadow;
  final VoidCallback? onPressed;

  const AppIconButton({
    super.key,
    required this.icon,
    this.size = AppDimensions.backButtonSize,
    this.iconSize = AppDimensions.iconLg,
    this.iconColor,
    this.backgroundColor,
    this.circular = true,
    this.boxShadow,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: backgroundColor ?? colors.bgCard,
          shape: circular ? BoxShape.circle : BoxShape.rectangle,
          borderRadius: circular ? null : BorderRadius.circular(AppDimensions.radiusXl),
          border: circular ? null : Border.all(color: colors.borderSubtle),
          boxShadow: boxShadow ?? (circular ? AppShadows.elevated : null),
        ),
        child: Center(
          child: Icon(icon, size: iconSize, color: iconColor ?? colors.textPrimary),
        ),
      ),
    );
  }
}

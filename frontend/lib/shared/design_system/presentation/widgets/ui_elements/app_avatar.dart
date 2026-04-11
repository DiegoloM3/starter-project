import 'package:flutter/material.dart';
import 'package:news_app_clean_architecture/config/theme/app_colors.dart';
import 'package:news_app_clean_architecture/config/theme/app_dimensions.dart';

class AppAvatar extends StatelessWidget {
  final double size;
  final String? imageUrl;
  final IconData icon;
  final Color? backgroundColor;

  const AppAvatar({
    super.key,
    this.size = AppDimensions.avatarDefault,
    this.imageUrl,
    this.icon = Icons.person_outline,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: size / 2,
      backgroundColor: backgroundColor ?? AppColors.accentGreen,
      backgroundImage: imageUrl != null ? NetworkImage(imageUrl!) : null,
      child: imageUrl == null
          ? Icon(icon,
              size: size * AppDimensions.avatarIconRatio,
              color: AppColors.white)
          : null,
    );
  }
}

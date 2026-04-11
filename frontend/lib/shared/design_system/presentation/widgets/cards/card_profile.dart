import 'package:flutter/material.dart';
import 'package:news_app_clean_architecture/config/theme/app_dimensions.dart';
import 'package:news_app_clean_architecture/config/theme/app_shadows.dart';
import 'package:news_app_clean_architecture/config/theme/app_typography.dart';
import 'package:news_app_clean_architecture/config/theme/theme_extensions.dart';
import 'package:news_app_clean_architecture/shared/design_system/presentation/widgets/ui_elements/app_avatar.dart';

class CardProfile extends StatelessWidget {
  final String name;
  final String? subtitle;
  final String? avatarUrl;
  final IconData avatarIcon;
  final VoidCallback? onSettingsTap;

  const CardProfile({
    super.key,
    required this.name,
    this.subtitle,
    this.avatarUrl,
    this.avatarIcon = Icons.person_outline,
    this.onSettingsTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacing20),
      decoration: BoxDecoration(
        color: colors.bgCard,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
        boxShadow: AppShadows.cardStandard,
      ),
      child: Row(
        children: [
          AppAvatar(
              size: AppDimensions.avatarLg,
              imageUrl: avatarUrl,
              icon: avatarIcon),
          const SizedBox(width: AppDimensions.spacing16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  name,
                  style: AppTypography.userName
                      .copyWith(color: colors.textPrimary),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: AppDimensions.spacing4),
                  Text(
                    subtitle!,
                    style: AppTypography.subtitle
                        .copyWith(color: colors.textSecondary),
                  ),
                ],
              ],
            ),
          ),
          GestureDetector(
            onTap: onSettingsTap,
            child: Icon(Icons.settings_outlined,
                size: AppDimensions.iconLg, color: colors.textPlaceholder),
          ),
        ],
      ),
    );
  }
}

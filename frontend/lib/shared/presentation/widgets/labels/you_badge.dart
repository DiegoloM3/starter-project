import 'package:flutter/material.dart';
import 'package:news_app_clean_architecture/config/theme/app_palette.dart';
import 'package:news_app_clean_architecture/config/theme/app_typography.dart';

/// Small ink block reading "YOU": marks an article written by the signed-in
/// user wherever articles are listed.
class YouBadge extends StatelessWidget {
  const YouBadge({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      color: palette.accent,
      child: Text(
        'YOU',
        style: AppTypography.navLabel.copyWith(color: palette.onAccent, fontSize: 9, letterSpacing: 9 * 0.12),
      ),
    );
  }
}

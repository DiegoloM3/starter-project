import 'package:flutter/material.dart';
import 'package:news_app_clean_architecture/config/theme/theme.dart';

/// Displays a formatted view count (e.g. 1.2K, 15K) with an eye icon.
class ViewCountBadge extends StatelessWidget {
  final int count;

  const ViewCountBadge({Key? key, required this.count}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.visibility_outlined, size: 14, color: AppColors.textMuted),
        const SizedBox(width: AppSpacing.xs),
        Text(_format(count), style: AppTextStyles.caption),
      ],
    );
  }

  static String _format(int value) {
    if (value >= 1000000) return '${(value / 1000000).toStringAsFixed(1)}M';
    if (value >= 1000) return '${(value / 1000).toStringAsFixed(1)}K';
    return '$value';
  }
}

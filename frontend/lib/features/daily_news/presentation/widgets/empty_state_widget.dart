import 'package:flutter/material.dart';

import '../../../../config/theme/app_themes.dart';

class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyStateWidget({
    Key? key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 44, color: AppColors.t3),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTypography.serif(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.t1,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: AppTypography.sans(
                fontSize: 12.5,
                color: AppColors.t2,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 22),
            // Decorative red rule
            Container(
              width: 22,
              height: 3,
              decoration: BoxDecoration(
                color: AppColors.red,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 22),
              ElevatedButton(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.red,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  actionLabel!,
                  style: AppTypography.sans(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

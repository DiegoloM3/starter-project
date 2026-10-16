import 'package:flutter/material.dart';

import '../../../../config/theme/app_design_tokens.dart';

/// Shown instead of the feed when the articles could not be loaded.
class FeedErrorMessage extends StatelessWidget {
  final VoidCallback onRetryPressed;

  const FeedErrorMessage({Key? key, required this.onRetryPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_outlined, size: 48, color: AppColors.darkText),
            const SizedBox(height: 16),
            const Text(
              "We couldn't load the news. Check your connection and try again.",
              textAlign: TextAlign.center,
              style: TextStyle(fontFamily: AppFonts.inter, fontSize: 16, color: AppColors.darkText),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetryPressed,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry', style: TextStyle(fontFamily: AppFonts.inter, fontSize: 16)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.lilac,
                foregroundColor: AppColors.darkText,
                shape: const RoundedRectangleBorder(borderRadius: AppRadius.standard),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import 'package:news_app_clean_architecture/config/theme/design_tokens.dart';

enum AlertTone { error, success, info }

/// What the app says when something needs the person's attention.
///
/// It replaces the bare red sentence that used to sit under a form. Three
/// things make it work where loose text did not: a tinted panel that is
/// visibly *a message* rather than stray copy, an icon so the meaning does
/// not rest on colour alone — which is exactly what somebody who cannot
/// separate red from grey needs — and a live region, so a screen reader
/// announces it instead of leaving it for the reader to discover.
class AlertBanner extends StatelessWidget {
  final String message;
  final AlertTone tone;

  const AlertBanner(
    this.message, {
    super.key,
    this.tone = AlertTone.error,
  });

  @override
  Widget build(BuildContext context) {
    final color = _colorOf(tone);

    return Semantics(
      liveRegion: true,
      container: true,
      child: TweenAnimationBuilder<double>(
        // Arrives rather than appears: a message that blinks into place is
        // easy to miss, especially the second time it says the same thing.
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        builder: (context, progress, child) => Opacity(
          opacity: progress,
          child: Transform.translate(
            offset: Offset(0, 8 * (1 - progress)),
            child: child,
          ),
        ),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: AppRadius.cardRadius,
            border: Border.all(color: color.withValues(alpha: 0.45)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(_iconOf(tone), size: 20, color: color),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  message,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: color,
                        height: 1.4,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Color _colorOf(AlertTone tone) {
    switch (tone) {
      case AlertTone.error:
        return AppColors.danger;
      case AlertTone.success:
        return AppColors.success;
      case AlertTone.info:
        return AppColors.info;
    }
  }

  static IconData _iconOf(AlertTone tone) {
    switch (tone) {
      case AlertTone.error:
        return Icons.error_outline;
      case AlertTone.success:
        return Icons.check_circle_outline;
      case AlertTone.info:
        return Icons.info_outline;
    }
  }
}

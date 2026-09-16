import 'package:flutter/material.dart';
import 'package:news_app_clean_architecture/config/theme/app_palette.dart';
import 'package:news_app_clean_architecture/config/theme/app_spacing.dart';
import 'package:news_app_clean_architecture/config/theme/app_typography.dart';
import 'package:news_app_clean_architecture/features/auth/domain/params/credentials.dart';

/// Four square segments that fill as the password gets harder to guess,
/// with the matching sentence underneath. Guidance only: it never blocks
/// the form.
class PasswordStrengthMeter extends StatelessWidget {
  final PasswordStrength strength;

  const PasswordStrengthMeter({super.key, required this.strength});

  static final int segmentCount = PasswordStrength.values.length;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final fillColor = strength == PasswordStrength.weak ? palette.primary : palette.ink;

    return Semantics(
      label: '${strength.title} ${strength.hint}',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              for (var index = 0; index < segmentCount; index++) ...[
                if (index > 0) const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Container(
                    height: 6,
                    decoration: BoxDecoration(color: index < strength.filledSegments ? fillColor : palette.outline),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text.rich(
            TextSpan(
              text: '${strength.title.toUpperCase()} ',
              style: AppTypography.caption.copyWith(color: palette.ink, fontWeight: FontWeight.w800),
              children: [
                TextSpan(
                  text: strength.hint,
                  style: AppTypography.captionSmall.copyWith(color: palette.inkSecondary, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

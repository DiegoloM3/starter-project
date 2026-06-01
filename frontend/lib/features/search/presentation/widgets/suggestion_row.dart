import 'package:flutter/material.dart';
import 'package:tortutip/config/theme/app_colors.dart';
import 'package:tortutip/config/theme/app_spacing.dart';
import 'package:tortutip/config/theme/app_typography.dart';

class SuggestionRow extends StatelessWidget {
  final String suggestion;
  final String query;
  final ValueChanged<String> onTap;

  const SuggestionRow({
    super.key,
    required this.suggestion,
    required this.query,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onTap(suggestion),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          children: [
            const Icon(
              Icons.search,
              color: AppColors.textSecondary,
              size: AppSpacing.iconMd,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _buildHighlightedText(suggestion, query),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHighlightedText(String text, String queryText) {
    final lowerText = text.toLowerCase();
    final lowerQuery = queryText.toLowerCase();
    final idx = lowerText.indexOf(lowerQuery);

    if (idx < 0) {
      return Text(text, style: AppTypography.body);
    }

    final before = text.substring(0, idx);
    final match = text.substring(idx, idx + queryText.length);
    final after = text.substring(idx + queryText.length);

    return RichText(
      text: TextSpan(
        style: AppTypography.body,
        children: [
          TextSpan(text: before),
          TextSpan(
            text: match,
            style: AppTypography.body
                .copyWith(fontWeight: FontWeight.bold),
          ),
          TextSpan(text: after),
        ],
      ),
    );
  }
}

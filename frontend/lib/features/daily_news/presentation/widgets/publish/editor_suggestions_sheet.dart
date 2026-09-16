import 'package:flutter/material.dart';
import 'package:news_app_clean_architecture/config/theme/app_palette.dart';
import 'package:news_app_clean_architecture/config/theme/app_spacing.dart';
import 'package:news_app_clean_architecture/config/theme/app_typography.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/editor_suggestions.dart';
import 'package:news_app_clean_architecture/shared/presentation/widgets/skeleton/skeleton_box.dart';

/// Bottom sheet with the desk editor's proposals, one per ruled row. Every
/// proposal has its own "Use this"; nothing is applied on the journalist's
/// behalf.
class EditorSuggestionsSheet extends StatelessWidget {
  final EditorSuggestions? suggestions;
  final bool isLoading;
  final String? errorMessage;
  final ValueChanged<String> onUseHeadline;
  final ValueChanged<String> onUseSummary;

  const EditorSuggestionsSheet({
    super.key,
    required this.suggestions,
    required this.isLoading,
    required this.errorMessage,
    required this.onUseHeadline,
    required this.onUseSummary,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(AppSpacing.screenMargin, AppSpacing.md, AppSpacing.screenMargin, AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.auto_awesome_rounded, color: palette.primary, size: 16),
                const SizedBox(width: AppSpacing.sm),
                Text('FROM THE EDITOR', style: AppTypography.overline.copyWith(color: palette.primaryDeep)),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Suggestions written by AI from your draft. Use what helps, ignore the rest.',
              style: AppTypography.bodySmall.copyWith(color: palette.inkSecondary),
            ),
            const SizedBox(height: AppSpacing.lg),
            if (isLoading)
              const SkeletonArea(
                child: Column(
                  children: [
                    SkeletonBox(height: 20),
                    SizedBox(height: AppSpacing.md),
                    SkeletonBox(height: 20),
                    SizedBox(height: AppSpacing.md),
                    SkeletonBox(width: 200, height: 20),
                  ],
                ),
              )
            else if (errorMessage != null)
              Text(errorMessage!, style: AppTypography.bodySmall.copyWith(color: palette.error))
            else if (suggestions case final s?) ...[
              _SectionLabel('Headlines'),
              for (final headline in s.headlines)
                _Proposal(
                  child: Text(headline, style: AppTypography.cardTitle.copyWith(color: palette.ink)),
                  onUse: () => onUseHeadline(headline),
                ),
              if (s.hasSummary) ...[
                const SizedBox(height: AppSpacing.lg),
                _SectionLabel('Short description'),
                _Proposal(
                  child: Text(s.summary, style: AppTypography.bodySmall.copyWith(color: palette.inkBody)),
                  onUse: () => onUseSummary(s.summary),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;

  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: palette.ink, width: AppRules.strong)),
      ),
      child: Text(text.toUpperCase(), style: AppTypography.sectionOverline.copyWith(color: palette.ink)),
    );
  }
}

class _Proposal extends StatelessWidget {
  final Widget child;
  final VoidCallback onUse;

  const _Proposal({required this.child, required this.onUse});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: palette.outline, width: AppRules.strong)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(child: child),
          const SizedBox(width: AppSpacing.md),
          TextButton(onPressed: onUse, child: const Text('Use this')),
        ],
      ),
    );
  }
}

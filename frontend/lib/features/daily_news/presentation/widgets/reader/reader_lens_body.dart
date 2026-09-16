import 'package:flutter/material.dart';
import 'package:news_app_clean_architecture/config/theme/app_motion.dart';
import 'package:news_app_clean_architecture/config/theme/app_palette.dart';
import 'package:news_app_clean_architecture/config/theme/app_spacing.dart';
import 'package:news_app_clean_architecture/config/theme/app_typography.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article_lens.dart';
import 'package:news_app_clean_architecture/shared/presentation/widgets/skeleton/skeleton_box.dart';

/// The article body as the active lens shows it: the original text opened
/// by a red initial, a loading skeleton, three bullets between rules, or a
/// rewritten text, crossfading between them.
class ReaderLensBody extends StatelessWidget {
  final String original;
  final ArticleLensResult? result;
  final bool isLoading;

  const ReaderLensBody({super.key, required this.original, required this.result, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: AppMotion.durationFor(context, AppMotion.medium),
      child: KeyedSubtree(
        key: ValueKey(isLoading ? 'loading' : (result?.lens.name ?? 'original')),
        child: isLoading
            ? const _Skeleton()
            : result == null
                ? _Body(original, initial: true)
                : _LensView(result: result!),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  final String text;

  /// Sets the first letter large and red, the way a lead paragraph opens.
  final bool initial;

  const _Body(this.text, {this.initial = false});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final style = AppTypography.body.copyWith(color: palette.inkBody);
    final trimmed = text.trimLeft();
    if (!initial || trimmed.isEmpty) return Text(text, style: style);
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: trimmed.characters.first,
            style: AppTypography.glyph(style.fontSize! * 2.4, weight: FontWeight.w900).copyWith(
              color: palette.primary,
              height: 0.8,
            ),
          ),
          TextSpan(text: trimmed.characters.skip(1).toString()),
        ],
      ),
      style: style,
    );
  }
}

class _LensView extends StatelessWidget {
  final ArticleLensResult result;

  const _LensView({required this.result});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (result.bullets.isNotEmpty)
          Container(
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: palette.ink, width: AppRules.strong)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final bullet in result.bullets)
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(color: palette.outline, width: AppRules.strong)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 9),
                          child: Container(width: 7, height: 7, color: palette.primary),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Text(
                            bullet,
                            style: AppTypography.body.copyWith(color: palette.ink, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          )
        else
          _Body(result.text),
        const SizedBox(height: AppSpacing.lg),
        Row(
          children: [
            Icon(Icons.auto_awesome_rounded, size: 14, color: palette.primary),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                'Written by AI from the original · tap ${result.lens.label} again to go back'.toUpperCase(),
                style: AppTypography.captionSmall.copyWith(color: palette.inkSecondary),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _Skeleton extends StatelessWidget {
  const _Skeleton();

  @override
  Widget build(BuildContext context) {
    return const SkeletonArea(
      child: Column(
        children: [
          SkeletonBox(height: 18),
          SizedBox(height: AppSpacing.md),
          SkeletonBox(height: 18),
          SizedBox(height: AppSpacing.md),
          SkeletonBox(width: 220, height: 18),
        ],
      ),
    );
  }
}

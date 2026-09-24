import 'package:flutter/material.dart';
import 'package:news_app_clean_architecture/config/theme/design_tokens.dart';
import 'package:news_app_clean_architecture/l10n/app_localizations.dart';

/// Placeholder cards shaped like the articles that are coming.
///
/// A skeleton instead of a spinner: it tells the reader what is about to
/// appear and keeps the layout from jumping when it does.
class FeedLoadingList extends StatelessWidget {
  final int itemCount;

  const FeedLoadingList({super.key, this.itemCount = 4});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.lg),
      itemCount: itemCount,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (context, index) => _SkeletonCard(isLead: index == 0),
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  final bool isLead;

  const _SkeletonCard({required this.isLead});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: AppRadius.cardRadius,
        boxShadow: AppShadows.card,
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isLead) ...[
            _bar(context, height: 180, widthFactor: 1),
            const SizedBox(height: AppSpacing.md),
          ],
          _bar(context, height: 16, widthFactor: 0.9),
          const SizedBox(height: AppSpacing.sm),
          _bar(context, height: 16, widthFactor: 0.6),
          const SizedBox(height: AppSpacing.md),
          _bar(context, height: 12, widthFactor: 0.3),
        ],
      ),
    );
  }

  Widget _bar(
    BuildContext context, {
    required double height,
    required double widthFactor,
  }) {
    return FractionallySizedBox(
      alignment: Alignment.centerLeft,
      widthFactor: widthFactor,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(AppSpacing.sm),
        ),
      ),
    );
  }
}

/// Shown when a list has nothing in it *and* that is not a problem.
///
/// It says why the screen is empty and what would fill it, rather than
/// leaving the reader looking at nothing wondering if it broke.
class FeedEmptyMessage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final Widget? action;

  const FeedEmptyMessage({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 32, color: AppColors.accent),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(title, style: theme.textTheme.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            Text(
              message,
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            if (action != null) ...[
              const SizedBox(height: AppSpacing.xl),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

/// Shown when something went wrong.
///
/// It says what to do next instead of what broke internally, and always
/// offers the one action that usually fixes it.
class FeedErrorMessage extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const FeedErrorMessage({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                color: AppColors.danger.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.cloud_off_outlined,
                size: 32,
                color: AppColors.danger,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(message, style: theme.textTheme.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            Text(
              AppLocalizations.of(context).checkConnection,
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            SizedBox(
              width: 200,
              child: FilledButton(
                onPressed: onRetry,
                child: Text(AppLocalizations.of(context).tryAgain),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

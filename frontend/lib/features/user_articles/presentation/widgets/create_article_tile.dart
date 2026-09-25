import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:news_app_clean_architecture/l10n/l10n.dart';

import '../../../../config/theme/app_colors.dart';

/// The "write an article" entry point, styled as one more card in the feed
/// instead of a floating action button -- same row layout, padding and
/// corner radius as UserArticleTile (a 96x96 "thumbnail" slot + title +
/// subtitle), just with a "+" instead of a photo where the image would go.
class CreateArticleTile extends StatelessWidget {
  final VoidCallback onTap;

  const CreateArticleTile({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    // Same background/icon pairing as the FAB elsewhere in the app (light:
    // lightFabTint + primaryContainer icon; dark: secondaryContainer +
    // onSecondaryContainer icon) -- kept identical on purpose so "the place
    // you tap to create an article" reads as one consistent accent color
    // across the app, not a third, unrelated combination.
    final placeholderColor = colorScheme.brightness == Brightness.light
        ? AppColors.lightFabTint
        : colorScheme.secondaryContainer;
    final iconColor = colorScheme.brightness == Brightness.light
        ? colorScheme.primaryContainer
        : colorScheme.onSecondaryContainer;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: placeholderColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.add_rounded, size: 36, color: iconColor),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(context.l10n.newArticle, style: theme.textTheme.titleMedium),
                  const SizedBox(height: 6),
                  Text(context.l10n.tapToWriteYourOwn,
                      style: theme.textTheme.bodyMedium),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 300.ms, curve: Curves.easeOut);
  }
}

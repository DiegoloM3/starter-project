import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';

import 'package:news_app_clean_architecture/config/theme/design_tokens.dart';

/// An article's body, written in Markdown and rendered in the app's own
/// typography.
///
/// The style sheet is built from the theme rather than left at the package's
/// defaults: headings are the same serif the rest of the app uses for
/// headlines, and body text is the same size a reader sees everywhere else.
/// A body that rendered in somebody else's typography would read as pasted in.
class ArticleMarkdown extends StatelessWidget {
  final String data;

  const ArticleMarkdown(this.data, {super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final text = theme.textTheme;

    return MarkdownBody(
      data: data,
      selectable: true,
      styleSheet: MarkdownStyleSheet(
        p: text.bodyLarge,
        h1: text.displayLarge?.copyWith(fontSize: 28),
        h2: text.headlineMedium,
        h3: text.headlineSmall,
        strong: text.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
        em: text.bodyLarge?.copyWith(fontStyle: FontStyle.italic),
        listBullet: text.bodyLarge,
        a: text.bodyLarge?.copyWith(
          color: AppColors.accent,
          decoration: TextDecoration.underline,
        ),
        blockquote: text.bodyLarge?.copyWith(
          color: text.bodyMedium?.color,
          fontStyle: FontStyle.italic,
        ),
        blockquoteDecoration: BoxDecoration(
          border: Border(
            left: BorderSide(color: AppColors.accent, width: 3),
          ),
        ),
        blockquotePadding: const EdgeInsets.only(left: AppSpacing.lg),
        code: text.bodyMedium?.copyWith(
          fontFamily: 'monospace',
          backgroundColor: theme.dividerColor.withValues(alpha: 0.4),
        ),
        h1Padding: const EdgeInsets.only(top: AppSpacing.lg),
        h2Padding: const EdgeInsets.only(top: AppSpacing.lg),
        h3Padding: const EdgeInsets.only(top: AppSpacing.md),
        pPadding: const EdgeInsets.only(bottom: AppSpacing.sm),
        horizontalRuleDecoration: BoxDecoration(
          border: Border(top: BorderSide(color: theme.dividerColor)),
        ),
      ),
    );
  }
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:news_app_clean_architecture/config/theme/design_tokens.dart';
import 'package:news_app_clean_architecture/shared/ui/presentation/widgets/article_markdown.dart';
import 'package:news_app_clean_architecture/l10n/app_localizations.dart';

/// Shows what a formatting button actually does, by doing it.
///
/// It cycles between what the journalist types and what the reader sees. This
/// is the part of the guide that carries the meaning: telling somebody that
/// `**` makes text bold is a sentence they have to decode, while watching
/// `**bold**` turn into **bold** needs no explaining at all.
class MarkdownDemo extends StatefulWidget {
  /// Markdown examples, shown one after another.
  final List<String> samples;

  const MarkdownDemo({super.key, required this.samples});

  @override
  State<MarkdownDemo> createState() => _MarkdownDemoState();
}

class _MarkdownDemoState extends State<MarkdownDemo> {
  static const Duration _beat = Duration(milliseconds: 1600);

  Timer? _timer;
  int _sample = 0;
  bool _rendered = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(_beat, (_) => _advance());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  /// Types, renders, then moves to the next example.
  void _advance() {
    if (!mounted) {
      return;
    }

    setState(() {
      if (_rendered) {
        _rendered = false;
        _sample = (_sample + 1) % widget.samples.length;
      } else {
        _rendered = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sample = widget.samples[_sample];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: AppRadius.cardRadius,
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _rendered
                    ? Icons.visibility_outlined
                    : Icons.keyboard_alt_outlined,
                size: 14,
                color: AppColors.accent,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                _rendered
                    ? AppLocalizations.of(context).whatReadersSee
                    : AppLocalizations.of(context).whatYouType,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: AppColors.accent,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 280),
            child: SizedBox(
              // A fixed height so the guide card does not jump as the example
              // changes shape.
              key: ValueKey('$_sample-$_rendered'),
              height: 56,
              width: double.infinity,
              child: _rendered
                  ? ArticleMarkdown(sample)
                  : Text(
                      sample,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontFamily: 'monospace',
                        color: theme.textTheme.bodyMedium?.color,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

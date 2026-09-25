import 'package:flutter/material.dart';
import 'package:news_app_clean_architecture/core/presentation/formatting/utf16_length_limit.dart';
import 'package:news_app_clean_architecture/l10n/l10n.dart';

import 'article_body_editing_controller.dart';
import 'article_body_markup.dart';
import 'article_body_text.dart';

class ArticleContentField extends StatelessWidget {
  static const maxLength = 5000;

  final ArticleBodyEditingController controller;
  final bool isPreviewing;
  final ValueChanged<bool> onPreviewingChanged;

  const ArticleContentField({
    super.key,
    required this.controller,
    required this.isPreviewing,
    required this.onPreviewingChanged,
  });

  void _applyFormatting(
    TextEditingValue Function(TextEditingValue value) format,
  ) {
    final formatted = format(controller.value);
    // Programmatic edits skip maxLength's input formatter.
    if (formatted.text.length > maxLength) return;
    controller.value = formatted;
  }

  Widget _buildToolbar(BuildContext context) {
    // Wraps onto two lines on narrow phones instead of overflowing.
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      runSpacing: 8,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ToolbarButton(
              icon: Icons.format_bold,
              tooltip: context.l10n.bold,
              onPressed: isPreviewing ? null : () => _applyFormatting(toggleBold),
            ),
            _ToolbarButton(
              icon: Icons.title,
              tooltip: context.l10n.subheading,
              onPressed:
                  isPreviewing ? null : () => _applyFormatting(toggleSubheading),
            ),
            _ToolbarButton(
              icon: Icons.format_list_bulleted,
              tooltip: context.l10n.bulletList,
              onPressed:
                  isPreviewing ? null : () => _applyFormatting(toggleBulletList),
            ),
            _ToolbarButton(
              icon: Icons.format_list_numbered,
              tooltip: context.l10n.numberedList,
              onPressed: isPreviewing
                  ? null
                  : () => _applyFormatting(toggleNumberedList),
            ),
            _ToolbarButton(
              icon: Icons.format_quote,
              tooltip: context.l10n.quote,
              onPressed: isPreviewing ? null : () => _applyFormatting(toggleQuote),
            ),
          ],
        ),
        SegmentedButton<bool>(
          segments: [
            ButtonSegment(value: false, label: Text(context.l10n.write)),
            ButtonSegment(value: true, label: Text(context.l10n.preview)),
          ],
          selected: {isPreviewing},
          showSelectedIcon: false,
          onSelectionChanged: (selection) =>
              onPreviewingChanged(selection.first),
        ),
      ],
    );
  }

  int _wordCount() {
    final trimmed = controller.text.trim();
    return trimmed.isEmpty ? 0 : trimmed.split(RegExp(r'\s+')).length;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildToolbar(context),
        const SizedBox(height: 8),
        // Hidden rather than removed while previewing, so the Form still
        // validates it when Publish is tapped from the preview.
        Visibility(
          visible: !isPreviewing,
          maintainState: true,
          child: TextFormField(
            controller: controller,
            decoration: InputDecoration(
              labelText: context.l10n.fullContentLabel,
              alignLabelWithHint: true,
            ),
            maxLines: 10,
            // ~800 words: a normal news piece. Words are what a writer
            // thinks in; characters are what the limit is actually
            // enforced in, so both are shown -- counted in the same unit
            // firestore.rules counts content in (see
            // Utf16LengthLimitingTextInputFormatter).
            inputFormatters: const [
              Utf16LengthLimitingTextInputFormatter(maxLength),
            ],
            buildCounter: (
              context, {
              required currentLength,
              required maxLength,
              required isFocused,
            }) =>
                _Counter(
              words: _wordCount(),
              characters: controller.text.length,
              maxCharacters: ArticleContentField.maxLength,
            ),
            validator: (value) => (value == null || value.trim().length < 50)
                ? context.l10n.minimumCharacters(50)
                : null,
          ),
        ),
        if (isPreviewing) _ContentPreview(content: controller.text),
      ],
    );
  }
}

/// "120 words · 650/5000", the character count turning red over the last
/// 5% so running into the limit isn't a surprise.
class _Counter extends StatelessWidget {
  final int words;
  final int characters;
  final int maxCharacters;

  const _Counter({
    required this.words,
    required this.characters,
    required this.maxCharacters,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final nearLimit = characters >= maxCharacters * 0.95;
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: '${context.l10n.wordCount(words)}  ·  '),
          TextSpan(
            text: '$characters/$maxCharacters',
            style: nearLimit
                ? TextStyle(
                    color: theme.colorScheme.error,
                    fontWeight: FontWeight.w700,
                  )
                : null,
          ),
        ],
      ),
      style: theme.textTheme.labelSmall,
    );
  }
}

class _ToolbarButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  const _ToolbarButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon),
      tooltip: tooltip,
      onPressed: onPressed,
      visualDensity: VisualDensity.compact,
    );
  }
}

class _ContentPreview extends StatelessWidget {
  final String content;

  const _ContentPreview({required this.content});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      constraints: const BoxConstraints(minHeight: 160),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: content.trim().isEmpty
          ? Text(
              context.l10n.nothingToPreview,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            )
          : ArticleBodyText(content: content),
    );
  }
}

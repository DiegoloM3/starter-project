import 'package:flutter/material.dart';
import 'package:news_app_clean_architecture/config/theme/design_tokens.dart';
import 'package:news_app_clean_architecture/shared/ui/presentation/markdown_editing.dart';
import 'package:news_app_clean_architecture/l10n/app_localizations.dart';

/// The formatting a journalist gets, without having to know Markdown.
///
/// Deliberately five buttons and no more. Markdown can do far more than this,
/// but an article needs headings, emphasis, lists and quotes — and a toolbar
/// that offers everything is a toolbar nobody reads. Anyone who does know the
/// syntax can still type it: this writes the same characters they would.
class MarkdownToolbar extends StatelessWidget {
  final TextEditingController controller;

  /// Called with the new text so the cubit hears about the edit, exactly as
  /// it would from a keystroke.
  final ValueChanged<String> onChanged;

  const MarkdownToolbar({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _Action(
            icon: Icons.title,
            tooltip: AppLocalizations.of(context).toolbarHeading,
            onPressed: () => _applyLinePrefix('## '),
          ),
          _Action(
            icon: Icons.format_bold,
            tooltip: AppLocalizations.of(context).toolbarBold,
            onPressed: () => _applyWrap('**'),
          ),
          _Action(
            icon: Icons.format_italic,
            tooltip: AppLocalizations.of(context).toolbarItalic,
            onPressed: () => _applyWrap('*'),
          ),
          _Action(
            icon: Icons.format_list_bulleted,
            tooltip: AppLocalizations.of(context).toolbarList,
            onPressed: () => _applyLinePrefix('- '),
          ),
          _Action(
            icon: Icons.format_quote,
            tooltip: AppLocalizations.of(context).toolbarQuote,
            onPressed: () => _applyLinePrefix('> '),
          ),
        ],
      ),
    );
  }

  void _applyWrap(String marker) {
    _apply(
      MarkdownEditing.toggleWrap(
        controller.text,
        controller.selection,
        marker,
      ),
    );
  }

  void _applyLinePrefix(String prefix) {
    _apply(
      MarkdownEditing.toggleLinePrefix(
        controller.text,
        controller.selection,
        prefix,
      ),
    );
  }

  void _apply(MarkdownEdit edit) {
    // Text and selection are set together, so the cursor stays where the
    // journalist expects instead of jumping to the end of what they wrote.
    controller.value = controller.value.copyWith(
      text: edit.text,
      selection: edit.selection,
      composing: TextRange.empty,
    );

    onChanged(edit.text);
  }
}

class _Action extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  const _Action({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.xs),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, size: 20),
        tooltip: tooltip,
        constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
        style: IconButton.styleFrom(
          foregroundColor: Theme.of(context).textTheme.bodyLarge?.color,
        ),
      ),
    );
  }
}

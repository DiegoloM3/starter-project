import 'package:flutter/material.dart';
import 'package:news_app_clean_architecture/config/theme/app_palette.dart';
import 'package:news_app_clean_architecture/config/theme/app_spacing.dart';
import 'package:news_app_clean_architecture/config/theme/app_typography.dart';
import 'package:news_app_clean_architecture/shared/presentation/widgets/motion/bounce_on_change.dart';
import 'package:news_app_clean_architecture/shared/presentation/widgets/surfaces/glass_bar.dart';

/// Glass strip at the foot of the article: Save and Listen as wide cells,
/// then the A− / A+ stepper, all divided by rules. Every control carries a
/// visible word; a saved article prints its cell in red.
class ReaderBottomBar extends StatelessWidget {
  final bool isSaved;
  final bool isListening;
  final VoidCallback onSave;
  final VoidCallback onListen;
  final VoidCallback onSmallerText;
  final VoidCallback onLargerText;

  const ReaderBottomBar({
    super.key,
    required this.isSaved,
    required this.isListening,
    required this.onSave,
    required this.onListen,
    required this.onSmallerText,
    required this.onLargerText,
  });

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    return GlassBar(
      child: SizedBox(
        height: AppSizes.readerBar + bottomInset,
        child: Padding(
          padding: EdgeInsets.only(bottom: bottomInset),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: BounceOnChange(
                  trigger: isSaved,
                  child: _Cell(
                    icon: isSaved ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
                    label: isSaved ? 'Saved' : 'Save',
                    filled: isSaved,
                    onPressed: onSave,
                  ),
                ),
              ),
              Expanded(
                child: _Cell(
                  icon: isListening ? Icons.pause_rounded : Icons.volume_up_outlined,
                  label: isListening ? 'Pause' : 'Listen',
                  filled: false,
                  active: isListening,
                  onPressed: onListen,
                ),
              ),
              _TextSizeButton(label: 'A−', tooltip: 'Smaller text', onPressed: onSmallerText),
              _TextSizeButton(label: 'A+', tooltip: 'Larger text', onPressed: onLargerText, last: true),
            ],
          ),
        ),
      ),
    );
  }
}

class _Cell extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool filled;
  final bool active;
  final VoidCallback onPressed;

  const _Cell({
    required this.icon,
    required this.label,
    required this.filled,
    required this.onPressed,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final foreground = filled
        ? palette.background
        : active
            ? palette.primary
            : palette.ink;
    return InkWell(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        decoration: BoxDecoration(
          color: filled ? palette.primary : Colors.transparent,
          border: Border(right: BorderSide(color: palette.outlineStrong, width: AppRules.strong)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: foreground),
            const SizedBox(width: AppSpacing.sm),
            Flexible(
              child: Text(
                label.toUpperCase(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.buttonSecondary.copyWith(color: foreground, fontSize: 12.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Both steps share one size: the words say which way they go.
class _TextSizeButton extends StatelessWidget {
  final String label;
  final String tooltip;
  final VoidCallback onPressed;
  final bool last;

  const _TextSizeButton({required this.label, required this.tooltip, required this.onPressed, this.last = false});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onPressed,
        child: Container(
          constraints: const BoxConstraints(minWidth: AppSizes.touchTarget + 8),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: last ? null : Border(right: BorderSide(color: palette.outlineStrong, width: AppRules.strong)),
          ),
          child: Text(label, style: AppTypography.sized(17, weight: FontWeight.w800).copyWith(color: palette.ink)),
        ),
      ),
    );
  }
}

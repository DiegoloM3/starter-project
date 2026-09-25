import 'package:flutter/material.dart';
import 'package:news_app_clean_architecture/config/theme/app_colors.dart';
import 'package:news_app_clean_architecture/l10n/l10n.dart';

import '../../domain/entities/article.dart';

/// A dark strip with the most recently published headline, scrolling
/// sideways like a news ticker when it doesn't fit.
class LatestTicker extends StatelessWidget {
  final ArticleEntity article;
  final VoidCallback onTap;

  const LatestTicker({super.key, required this.article, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Material(
      color: AppColors.tickerSurface,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  context.l10n.latest,
                  style: theme.textTheme.labelSmall
                      ?.copyWith(color: colorScheme.onPrimary),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Marquee(
                  text: article.title ?? '',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(color: AppColors.onTickerSurface),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// One line of text that scrolls in a loop when it's wider than its space.
/// Stays still (ellipsized) when it fits, or when the phone asks for less
/// motion (Settings > Accessibility > Remove animations).
class Marquee extends StatefulWidget {
  final String text;
  final TextStyle? style;

  const Marquee({super.key, required this.text, this.style});

  @override
  State<Marquee> createState() => _MarqueeState();
}

class _MarqueeState extends State<Marquee> with SingleTickerProviderStateMixin {
  static const _gap = 48.0;
  static const _pixelsPerSecond = 40.0;

  late final AnimationController _controller = AnimationController(vsync: this);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Size _textSize(BuildContext context) {
    final painter = TextPainter(
      text: TextSpan(text: widget.text, style: widget.style),
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
      maxLines: 1,
    )..layout();
    final size = painter.size;
    painter.dispose();
    return size;
  }

  void _run(double distance) {
    final duration =
        Duration(milliseconds: (distance / _pixelsPerSecond * 1000).round());
    if (_controller.duration == duration && _controller.isAnimating) return;
    _controller
      ..duration = duration
      ..repeat();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final textSize = _textSize(context);
        final textWidth = textSize.width;
        final still = textWidth <= constraints.maxWidth ||
            MediaQuery.disableAnimationsOf(context);
        if (still) {
          _controller.stop();
          return Text(widget.text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: widget.style);
        }
        final distance = textWidth + _gap;
        _run(distance);
        final line = Text(widget.text,
            maxLines: 1, softWrap: false, style: widget.style);
        // A fixed height: OverflowBox takes all the space it's offered, and
        // inside a Column that's infinite -- without this the ticker froze
        // the app trying to lay out an endless box on every frame.
        return SizedBox(
          height: textSize.height,
          child: ClipRect(
            child: AnimatedBuilder(
              animation: _controller,
              // Two copies back to back, so the loop has no visible seam.
              builder: (context, child) => Transform.translate(
                offset: Offset(-distance * _controller.value, 0),
                child: child,
              ),
              child: OverflowBox(
                alignment: Alignment.centerLeft,
                maxWidth: double.infinity,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [line, const SizedBox(width: _gap), line],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

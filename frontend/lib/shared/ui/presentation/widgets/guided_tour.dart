import 'package:flutter/material.dart';
import 'package:news_app_clean_architecture/l10n/app_localizations.dart';

import 'package:news_app_clean_architecture/config/theme/design_tokens.dart';

/// One stop on a guided tour: something on screen, and what it is for.
class GuidedTourStep {
  /// The widget this step is about. It is brought into view and lit up.
  final GlobalKey targetKey;

  final String title;
  final String body;

  /// An optional demonstration — worth far more than a sentence for anything
  /// whose result is visual.
  final Widget? demo;

  const GuidedTourStep({
    required this.targetKey,
    required this.title,
    required this.body,
    this.demo,
  });
}

/// A walk through a screen: everything dims except the one thing being talked
/// about.
///
/// It is opened from a button and never appears uninvited. A tour that starts
/// itself is read once and resented every time after, and this one explains
/// something a journalist may want to come back to.
abstract final class GuidedTour {
  static Future<void> show(
    BuildContext context,
    List<GuidedTourStep> steps,
  ) {
    return Navigator.of(context).push(
      PageRouteBuilder<void>(
        opaque: false,
        barrierDismissible: false,
        // No transition: the tour belongs to the screen underneath, and
        // sliding it in would make it feel like somewhere else.
        transitionDuration: Duration.zero,
        pageBuilder: (_, __, ___) => _GuidedTourOverlay(steps: steps),
      ),
    );
  }
}

class _GuidedTourOverlay extends StatefulWidget {
  final List<GuidedTourStep> steps;

  const _GuidedTourOverlay({required this.steps});

  @override
  State<_GuidedTourOverlay> createState() => _GuidedTourOverlayState();
}

class _GuidedTourOverlayState extends State<_GuidedTourOverlay> {
  int _index = 0;
  Rect? _hole;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _focusOnCurrent());
  }

  /// Brings the step's target into view, then measures where it ended up.
  ///
  /// The scroll matters: half of what this tour points at starts below the
  /// fold, and a spotlight on something off screen lights up nothing.
  Future<void> _focusOnCurrent() async {
    final target = widget.steps[_index].targetKey.currentContext;

    if (target == null) {
      return;
    }

    await Scrollable.ensureVisible(
      target,
      duration: const Duration(milliseconds: 300),
      alignment: 0.3,
    );

    // Both the tour and the thing it points at have to still be on screen:
    // the scroll above is animated, and either can be disposed during it.
    if (!mounted || !target.mounted) {
      return;
    }

    final box = target.findRenderObject() as RenderBox?;

    if (box == null || !box.hasSize) {
      return;
    }

    setState(() {
      _hole = box.localToGlobal(Offset.zero) & box.size;
    });
  }

  void _next() {
    if (_index == widget.steps.length - 1) {
      Navigator.pop(context);
      return;
    }

    setState(() {
      _index++;
      _hole = null;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _focusOnCurrent());
  }

  void _back() {
    if (_index == 0) {
      return;
    }

    setState(() {
      _index--;
      _hole = null;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _focusOnCurrent());
  }

  @override
  Widget build(BuildContext context) {
    final step = widget.steps[_index];
    final screen = MediaQuery.sizeOf(context);
    final hole = _hole;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Tapping the dimmed area moves on, which is what most people try
          // first; the buttons are there for everyone else.
          GestureDetector(
            onTap: _next,
            child: CustomPaint(
              size: screen,
              painter: _SpotlightPainter(hole: hole),
            ),
          ),
          if (hole != null || _index == 0)
            _StepCard(
              step: step,
              index: _index,
              total: widget.steps.length,
              hole: hole,
              screen: screen,
              onNext: _next,
              onBack: _index == 0 ? null : _back,
              onSkip: () => Navigator.pop(context),
            ),
        ],
      ),
    );
  }
}

class _SpotlightPainter extends CustomPainter {
  final Rect? hole;

  const _SpotlightPainter({required this.hole});

  @override
  void paint(Canvas canvas, Size size) {
    final dim = Paint()..color = Colors.black.withValues(alpha: 0.72);
    final screen = Path()..addRect(Offset.zero & size);

    if (hole == null) {
      canvas.drawPath(screen, dim);
      return;
    }

    final cut = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          hole!.inflate(AppSpacing.sm),
          const Radius.circular(AppRadius.card),
        ),
      );

    canvas.drawPath(Path.combine(PathOperation.difference, screen, cut), dim);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        hole!.inflate(AppSpacing.sm),
        const Radius.circular(AppRadius.card),
      ),
      Paint()
        ..color = AppColors.accent
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(_SpotlightPainter oldDelegate) => oldDelegate.hole != hole;
}

class _StepCard extends StatelessWidget {
  final GuidedTourStep step;
  final int index;
  final int total;
  final Rect? hole;
  final Size screen;
  final VoidCallback onNext;
  final VoidCallback? onBack;
  final VoidCallback onSkip;

  const _StepCard({
    required this.step,
    required this.index,
    required this.total,
    required this.hole,
    required this.screen,
    required this.onNext,
    required this.onBack,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // The card sits on the roomier side of whatever is lit up, so it never
    // covers the thing it is explaining.
    final below = hole == null || hole!.center.dy < screen.height / 2;

    return Positioned(
      left: AppSpacing.lg,
      right: AppSpacing.lg,
      top: below && hole != null ? hole!.bottom + AppSpacing.xl : null,
      bottom: below
          ? (hole == null ? AppSpacing.huge : null)
          : screen.height - hole!.top + AppSpacing.xl,
      child: Material(
        color: theme.colorScheme.surface,
        borderRadius: AppRadius.cardRadius,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context).tourStepOf(index + 1, total),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: AppColors.accent,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                step.title,
                style: theme.textTheme.displayLarge?.copyWith(fontSize: 24),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(step.body, style: theme.textTheme.bodyMedium),
              if (step.demo != null) ...[
                const SizedBox(height: AppSpacing.lg),
                step.demo!,
              ],
              const SizedBox(height: AppSpacing.xl),
              Row(
                children: [
                  TextButton(
                    onPressed: onSkip,
                    child: Text(
                      index == total - 1
                          ? AppLocalizations.of(context).close
                          : AppLocalizations.of(context).skip,
                      style: TextStyle(
                        color: theme.textTheme.bodyMedium?.color,
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (onBack != null)
                    TextButton(
                      onPressed: onBack,
                      child: Text(AppLocalizations.of(context).back),
                    ),
                  const SizedBox(width: AppSpacing.sm),
                  FilledButton(
                    onPressed: onNext,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(110, 48),
                    ),
                    child: Text(
                      index == total - 1
                          ? AppLocalizations.of(context).gotIt
                          : AppLocalizations.of(context).next,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

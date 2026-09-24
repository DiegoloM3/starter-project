import 'package:flutter/material.dart';

import 'package:news_app_clean_architecture/config/theme/design_tokens.dart';
import 'package:news_app_clean_architecture/l10n/app_localizations.dart';

/// The app's mark: a headline and the byline under it.
///
/// Two bars, the second shorter and set apart — the shape of a name signed
/// beneath a piece of writing, which is what the app is for and what it is
/// called. It is drawn rather than shipped as an image so it stays sharp at
/// any size and follows the accent colour; `assets/branding/app_icon.svg` is
/// the same drawing, and is what the launcher icon is generated from.
class AppBrandMark extends StatelessWidget {
  final double size;

  const AppBrandMark({super.key, this.size = 56});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: AppLocalizations.of(context).appName,
      child: SizedBox.square(
        dimension: size,
        child: CustomPaint(painter: const _BrandMarkPainter()),
      ),
    );
  }
}

class _BrandMarkPainter extends CustomPainter {
  const _BrandMarkPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final tile = Offset.zero & size;
    final unit = size.shortestSide / 100;

    canvas.drawRRect(
      RRect.fromRectAndRadius(tile, Radius.circular(24 * unit)),
      Paint()..color = AppColors.accent,
    );

    // The headline: full width, solid.
    _bar(canvas, unit, top: 36, left: 24, width: 52, opacity: 1);
    // The byline: shorter, set below and lighter, the way a name sits under
    // the piece it belongs to.
    _bar(canvas, unit, top: 55, left: 24, width: 30, opacity: 0.62);
  }

  void _bar(
    Canvas canvas,
    double unit, {
    required double top,
    required double left,
    required double width,
    required double opacity,
  }) {
    const height = 9.0;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(left * unit, top * unit, width * unit, height * unit),
        Radius.circular(height / 2 * unit),
      ),
      Paint()..color = Colors.white.withValues(alpha: opacity),
    );
  }

  @override
  bool shouldRepaint(_BrandMarkPainter oldDelegate) => false;
}

/// The mark, the name and what the app is for, stacked.
///
/// It sits at the top of the two screens somebody can arrive at without ever
/// having seen the app before. Sign in used to open on a bare "Sign in" bar
/// and two fields, which is a form rather than a front door: nothing on it
/// said what they were signing in to.
class AppBrandHeader extends StatelessWidget {
  /// The line under the name, specific to the screen it introduces.
  final String subtitle;

  /// Drops the tagline and shrinks the mark, for a screen whose form is long
  /// enough that the header would push the button off a short phone. Sign up
  /// asks for four fields; sign in asks for two.
  final bool compact;

  const AppBrandHeader({
    super.key,
    required this.subtitle,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Column(
      // Takes the height it needs and no more: it is a header above a form,
      // not something that should grow to fill whatever it is put in.
      mainAxisSize: MainAxisSize.min,
      children: [
        AppBrandMark(size: compact ? 40 : 56),
        SizedBox(height: compact ? AppSpacing.md : AppSpacing.lg),
        Text(
          l10n.appName,
          style: theme.textTheme.displayLarge?.copyWith(
            fontSize: compact ? 26 : 34,
          ),
          textAlign: TextAlign.center,
        ),
        if (!compact) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            l10n.appTagline,
            style: theme.textTheme.labelLarge?.copyWith(
              color: AppColors.accent,
              letterSpacing: 0.4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
        SizedBox(height: compact ? AppSpacing.sm : AppSpacing.lg),
        Text(
          subtitle,
          style: theme.textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

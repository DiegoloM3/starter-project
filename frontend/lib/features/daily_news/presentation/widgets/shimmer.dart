import 'package:flutter/material.dart';

/// A soft highlight that sweeps across [child] on a loop -- the usual way
/// to say "this is a placeholder, real content is on its way" instead of a
/// static gray box. Built by hand with [ShaderMask], the same technique
/// the popular `shimmer` package uses internally, rather than adding a
/// package for one effect -- this feature already sets that precedent with
/// [Marquee] in latest_ticker.dart, its own hand-rolled animation.
class Shimmer extends StatefulWidget {
  final Widget child;

  const Shimmer({super.key, required this.child});

  @override
  State<Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<Shimmer>
    with SingleTickerProviderStateMixin {
  // Only created the first time build() actually reaches for it, so a
  // reader with Settings > Accessibility > Remove animations on never gets
  // a ticker running in the background for an effect they'll never see.
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1300),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) return widget.child;
    final colorScheme = Theme.of(context).colorScheme;
    final base = colorScheme.onSurface.withValues(alpha: 0.10);
    final highlight = colorScheme.onSurface.withValues(alpha: 0.24);
    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (context, child) => ShaderMask(
        blendMode: BlendMode.srcATop,
        shaderCallback: (bounds) => LinearGradient(
          colors: [base, highlight, base],
          stops: const [0.35, 0.5, 0.65],
          transform: _SlidingGradientTransform(_controller.value),
        ).createShader(bounds),
        child: child,
      ),
    );
  }
}

class _SlidingGradientTransform extends GradientTransform {
  final double slidePercent;

  const _SlidingGradientTransform(this.slidePercent);

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(
        bounds.width * (2 * slidePercent - 1), 0, 0);
  }
}

/// A solid rounded block -- the shape every skeleton piece is built from,
/// standing in for a line of text or a photo while it loads. Pass [width]
/// for a line that shouldn't span the full row (a byline, a short kicker);
/// leave it out to fill whatever width this box is given.
class ShimmerBox extends StatelessWidget {
  final double? width;
  final double height;
  final BorderRadius borderRadius;

  const ShimmerBox({
    super.key,
    this.width,
    required this.height,
    this.borderRadius = const BorderRadius.all(Radius.circular(6)),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.14),
        borderRadius: borderRadius,
      ),
    );
  }
}

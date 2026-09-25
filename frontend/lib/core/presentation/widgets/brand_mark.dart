import 'package:flutter/material.dart';

/// The app's mark: a capital N in the same Newsreader face as the "Daily
/// News" masthead, so it reads as real typography rather than a drawn
/// shape. [progress] reveals it left to right, like it's being written.
///
/// Uses a locally bundled Newsreader weight (`NewsreaderLocal`), not
/// `google_fonts`' runtime-fetched one: this mark is shown constantly
/// (every image placeholder, app-wide), and google_fonts silently falling
/// back to a different font while Newsreader downloads -- or failing to
/// download at all, e.g. mid connectivity testing -- showed up as the N
/// sometimes rendering as a visibly different glyph.
class BrandMark extends StatelessWidget {
  final double progress;
  final double size;

  const BrandMark({super.key, this.progress = 1, this.size = 40});

  @override
  Widget build(BuildContext context) {
    final glyph = Text(
      'N',
      style: TextStyle(
        fontFamily: 'NewsreaderLocal',
        fontSize: size,
        fontWeight: FontWeight.w700,
        height: 1,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
    if (progress >= 1) return glyph;
    if (progress <= 0) return SizedBox(height: size);
    return ClipRect(
      child: Align(
        alignment: Alignment.centerLeft,
        widthFactor: progress,
        child: glyph,
      ),
    );
  }
}

/// The same mark, drawing itself on a loop -- shown while a photo is
/// actually being fetched, so waiting reads as the app doing something
/// rather than a blank tile or a generic spinner.
class AnimatedBrandMark extends StatefulWidget {
  final double size;

  const AnimatedBrandMark({super.key, this.size = 40});

  @override
  State<AnimatedBrandMark> createState() => _AnimatedBrandMarkState();
}

class _AnimatedBrandMarkState extends State<AnimatedBrandMark>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2200),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) {
      return BrandMark(size: widget.size);
    }
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _controller.value;
        // Draws over the first 70% of the loop, holds fully drawn briefly,
        // then fades out in the last 15% -- so it resets to redraw while
        // invisible instead of visibly snapping back to a blank mark.
        final progress = Curves.easeInOut.transform((t / 0.7).clamp(0, 1));
        final opacity =
            t <= 0.85 ? 1.0 : 1.0 - ((t - 0.85) / 0.15).clamp(0.0, 1.0);
        return Opacity(
          opacity: opacity,
          child: BrandMark(progress: progress, size: widget.size),
        );
      },
    );
  }
}

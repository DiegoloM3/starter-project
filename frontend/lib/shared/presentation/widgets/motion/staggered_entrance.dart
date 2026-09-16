import 'package:flutter/material.dart';
import 'package:news_app_clean_architecture/config/theme/app_motion.dart';

/// Fades and lifts a list row into place on first appearance, each row a
/// beat after the previous one (capped so long lists do not drag). Honors
/// reduce-motion by rendering the final state at once.
class StaggeredEntrance extends StatefulWidget {
  final int index;
  final Widget child;

  const StaggeredEntrance({super.key, required this.index, required this.child});

  static const int maxDelayedIndex = 6;
  static const double lift = 24;

  @override
  State<StaggeredEntrance> createState() => _StaggeredEntranceState();
}

class _StaggeredEntranceState extends State<StaggeredEntrance> with SingleTickerProviderStateMixin {
  // The beat is part of the animation itself (an interval at the start), so
  // no timer is left behind when a row is disposed before its turn.
  late final int _steps = widget.index.clamp(0, StaggeredEntrance.maxDelayedIndex);
  late final Duration _delay = AppMotion.feedStaggerStep * _steps;
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: AppMotion.medium + _delay);
  late final Animation<double> _progress = CurvedAnimation(
    parent: _controller,
    curve: Interval(_delay.inMilliseconds / (AppMotion.medium + _delay).inMilliseconds, 1, curve: AppMotion.enter),
  );

  @override
  void initState() {
    super.initState();
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).disableAnimations) return widget.child;
    return AnimatedBuilder(
      animation: _progress,
      builder: (context, child) => Opacity(
        opacity: _progress.value,
        child: Transform.translate(
          offset: Offset(0, StaggeredEntrance.lift * (1 - _progress.value)),
          child: child,
        ),
      ),
      child: widget.child,
    );
  }
}

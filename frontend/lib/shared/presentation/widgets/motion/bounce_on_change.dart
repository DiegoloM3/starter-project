import 'package:flutter/material.dart';
import 'package:news_app_clean_architecture/config/theme/app_motion.dart';

/// Scales its child 1 → 1.25 → 1 whenever [trigger] flips to `true` (the
/// bookmark filling in). Turning off reverses nothing: an unsave should feel
/// quiet.
class BounceOnChange extends StatefulWidget {
  final bool trigger;
  final Widget child;

  const BounceOnChange({super.key, required this.trigger, required this.child});

  @override
  State<BounceOnChange> createState() => _BounceOnChangeState();
}

class _BounceOnChangeState extends State<BounceOnChange> with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: AppMotion.bookmarkScale);
  late final Animation<double> _scale = TweenSequence<double>([
    TweenSequenceItem(tween: Tween<double>(begin: 1, end: 1.25).chain(CurveTween(curve: Curves.easeOut)), weight: 45),
    TweenSequenceItem(tween: Tween<double>(begin: 1.25, end: 1).chain(CurveTween(curve: Curves.easeOutBack)), weight: 55),
  ]).animate(_controller);

  @override
  void didUpdateWidget(BounceOnChange oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.trigger && !oldWidget.trigger && !MediaQuery.of(context).disableAnimations) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(scale: _scale, child: widget.child);
  }
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:news_app_clean_architecture/config/theme/app_motion.dart';

/// The "WRITE" block hides while the feed is moving and comes back once it
/// has been still for a moment, sliding in from below the bar. Never gone for
/// good: writing must stay one tap away.
class ShrinkingWriteFab extends StatefulWidget {
  final VoidCallback onPressed;

  /// Attach this to a [NotificationListener] around the scrolling feed.
  final ValueNotifier<FeedScrollDirection> scrollDirection;

  const ShrinkingWriteFab({super.key, required this.onPressed, required this.scrollDirection});

  @override
  State<ShrinkingWriteFab> createState() => _ShrinkingWriteFabState();
}

enum FeedScrollDirection { idle, down, up }

class _ShrinkingWriteFabState extends State<ShrinkingWriteFab> {
  bool _hidden = false;
  Timer? _settle;

  @override
  void initState() {
    super.initState();
    widget.scrollDirection.addListener(_onScroll);
  }

  void _onScroll() {
    _settle?.cancel();
    final moving = widget.scrollDirection.value != FeedScrollDirection.idle;
    if (moving) {
      if (!_hidden) setState(() => _hidden = true);
      return;
    }
    _settle = Timer(AppMotion.fabReextendIdle, () {
      if (mounted && _hidden) setState(() => _hidden = false);
    });
  }

  @override
  void dispose() {
    _settle?.cancel();
    widget.scrollDirection.removeListener(_onScroll);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final duration = AppMotion.durationFor(context, AppMotion.short);
    return AnimatedSlide(
      offset: _hidden ? const Offset(0, 2.2) : Offset.zero,
      duration: duration,
      curve: Curves.easeOutCubic,
      child: AnimatedOpacity(
        opacity: _hidden ? 0 : 1,
        duration: duration,
        curve: Curves.easeOut,
        child: FloatingActionButton.extended(
          onPressed: widget.onPressed,
          tooltip: 'Write an article',
          icon: const Icon(Icons.edit_rounded, size: 18),
          label: const Text('WRITE'),
        ),
      ),
    );
  }
}

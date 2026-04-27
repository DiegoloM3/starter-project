import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/app_colors.dart';

/// Provides a single [AnimationController] to all [SkeletonLoader]
/// descendants so they share one synchronized shimmer animation.
class ShimmerScope extends StatefulWidget {
  const ShimmerScope({super.key, required this.child});

  final Widget child;

  /// Retrieves the shimmer [Animation] from the nearest ancestor.
  /// Returns `null` if no [ShimmerScope] is in the tree (fallback mode).
  static Animation<double>? of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_ShimmerScopeData>()
        ?.animation;
  }

  @override
  State<ShimmerScope> createState() => _ShimmerScopeState();
}

class _ShimmerScopeState extends State<ShimmerScope>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _animation = Tween<double>(begin: -1.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _ShimmerScopeData(
      animation: _animation,
      child: widget.child,
    );
  }
}

class _ShimmerScopeData extends InheritedWidget {
  const _ShimmerScopeData({
    required this.animation,
    required super.child,
  });

  final Animation<double> animation;

  @override
  bool updateShouldNotify(_ShimmerScopeData oldWidget) =>
      animation != oldWidget.animation;
}

// ─────────────────────────────────────────────────────────────────────────────

/// A shimmer-effect placeholder box.
///
/// When placed inside a [ShimmerScope], it shares the scope's animation.
/// When used standalone, it creates its own [AnimationController].
class SkeletonLoader extends StatefulWidget {
  const SkeletonLoader({
    super.key,
    this.width,
    required this.height,
    this.borderRadius,
  });

  final double? width;
  final double height;
  final double? borderRadius;

  @override
  State<SkeletonLoader> createState() => _SkeletonLoaderState();
}

class _SkeletonLoaderState extends State<SkeletonLoader>
    with SingleTickerProviderStateMixin {
  AnimationController? _ownController;
  Animation<double>? _ownAnimation;

  @override
  void dispose() {
    _ownController?.dispose();
    super.dispose();
  }

  Animation<double> _resolveAnimation(BuildContext context) {
    final scoped = ShimmerScope.of(context);
    if (scoped != null) return scoped;

    // Fallback: create own controller when no ShimmerScope ancestor.
    _ownController ??= AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _ownAnimation ??= Tween<double>(begin: -1.0, end: 1.0).animate(
      CurvedAnimation(parent: _ownController!, curve: Curves.easeInOut),
    );

    return _ownAnimation!;
  }

  @override
  Widget build(BuildContext context) {
    final animation = _resolveAnimation(context);
    final radius = widget.borderRadius ?? 8.r;

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            gradient: LinearGradient(
              begin: Alignment(animation.value - 1, 0),
              end: Alignment(animation.value + 1, 0),
              colors: const [
                AppColors.surface,
                AppColors.border,
                AppColors.surface,
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        );
      },
    );
  }
}

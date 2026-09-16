import 'package:flutter/material.dart';
import 'package:news_app_clean_architecture/config/theme/app_motion.dart';

/// Route transition of the app: the new page rises 24dp while fading in and
/// settling from 98% scale, like a sheet of paper laid on the desk; the page
/// underneath dims slightly. No horizontal slide, no Material zoom.
class EditorialPageTransitionsBuilder extends PageTransitionsBuilder {
  const EditorialPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return EditorialTransition(
      animation: animation,
      secondaryAnimation: secondaryAnimation,
      child: child,
    );
  }
}

class EditorialTransition extends StatelessWidget {
  final Animation<double> animation;
  final Animation<double> secondaryAnimation;
  final Widget child;

  const EditorialTransition({
    super.key,
    required this.animation,
    required this.secondaryAnimation,
    required this.child,
  });

  static const double rise = 24;

  @override
  Widget build(BuildContext context) {
    final enter = CurvedAnimation(parent: animation, curve: AppMotion.enter, reverseCurve: AppMotion.exit);
    final dim = CurvedAnimation(parent: secondaryAnimation, curve: Curves.easeInOut);

    return AnimatedBuilder(
      animation: Listenable.merge([enter, dim]),
      builder: (context, _) {
        final t = enter.value;
        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(0, rise * (1 - t)),
            child: Transform.scale(
              scale: 0.98 + 0.02 * t,
              child: ColorFiltered(
                colorFilter: ColorFilter.mode(
                  Colors.black.withValues(alpha: 0.12 * dim.value),
                  BlendMode.srcATop,
                ),
                child: child,
              ),
            ),
          ),
        );
      },
      child: child,
    );
  }
}

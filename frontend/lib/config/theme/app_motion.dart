import 'package:flutter/material.dart';

/// Durations and curves of the Headline News motion system.
///
/// Every value stays at or below 400 ms except the Brief swipe spring. When
/// the platform asks to reduce motion, use [AppMotion.durationFor] so
/// animations collapse to zero while keeping their end state.
abstract final class AppMotion {
  static const Duration short = Duration(milliseconds: 200);
  static const Duration indicator = Duration(milliseconds: 250);
  static const Duration medium = Duration(milliseconds: 300);
  static const Duration long = Duration(milliseconds: 400);
  static const Duration feedStaggerStep = Duration(milliseconds: 40);
  static const Duration shimmerPeriod = Duration(milliseconds: 1400);
  static const Duration fabReextendIdle = Duration(milliseconds: 250);
  static const Duration bookmarkScale = Duration(milliseconds: 320);

  static const Curve standard = Curves.easeInOutCubicEmphasized;
  static const Curve enter = Curves.easeOutCubic;
  static const Curve exit = Curves.easeInCubic;

  /// Spring used by the Brief card stack.
  static const SpringDescription briefSpring = SpringDescription(
    mass: 1,
    stiffness: 180,
    damping: 22,
  );

  static Duration durationFor(BuildContext context, Duration duration) {
    return MediaQuery.of(context).disableAnimations ? Duration.zero : duration;
  }
}

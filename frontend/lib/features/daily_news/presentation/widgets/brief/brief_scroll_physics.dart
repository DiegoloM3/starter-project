import 'package:flutter/material.dart';
import 'package:news_app_clean_architecture/config/theme/app_motion.dart';

/// Page physics of the Brief stack: a firmer spring than Material's so a
/// card settles in about half a second with a hint of overshoot and never
/// bounces past the first or last story.
class BriefScrollPhysics extends PageScrollPhysics {
  const BriefScrollPhysics({super.parent});

  @override
  BriefScrollPhysics applyTo(ScrollPhysics? ancestor) =>
      BriefScrollPhysics(parent: buildParent(ancestor));

  @override
  SpringDescription get spring => AppMotion.briefSpring;
}

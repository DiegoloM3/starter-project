import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// The Google "G" brand mark.
class GoogleMark extends StatelessWidget {
  final double size;

  const GoogleMark({super.key, this.size = 22});

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/images/google_g.svg',
      width: size,
      height: size,
      semanticsLabel: 'Google',
    );
  }
}

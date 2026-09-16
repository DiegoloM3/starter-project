import 'package:flutter/material.dart';
import 'package:news_app_clean_architecture/shared/presentation/widgets/media/brand_mark.dart';

/// Shown for the instant it takes the identity provider to report whether
/// somebody is signed in. The router leaves as soon as it knows.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: BrandMark(size: 120)),
    );
  }
}

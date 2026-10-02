import 'package:flutter/material.dart';
import 'package:news_app_clean_architecture/config/theme/app_themes.dart';

/// The name of the app in its brand color, above the titles of the welcome and log in screens.
class DailyNewsLabel extends StatelessWidget {
  const DailyNewsLabel({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      'Daily News',
      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, letterSpacing: 0.4, color: context.palette.primary),
    );
  }
}

import 'package:flutter/material.dart';

import 'app_colors.dart';

extension AppThemeExtension on BuildContext {
  AppColorsExtension get colors =>
      Theme.of(this).extension<AppColorsExtension>()!;
}

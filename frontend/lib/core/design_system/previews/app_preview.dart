import 'package:flutter/widget_previews.dart';

import '../../../config/theme/app_themes.dart';

/// Reusable preview annotation that applies the app theme.
final class AppPreview extends Preview {
  const AppPreview({
    super.name,
    super.group,
    super.size,
    super.textScaleFactor,
    super.wrapper,
    super.brightness,
    super.localizations,
  }) : super(theme: _themeBuilder);

  static PreviewThemeData _themeBuilder() => PreviewThemeData(
    materialLight: AppTheme.light,
    materialDark: AppTheme.light,
  );
}

import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

export '../../core/theme/app_colors.dart';
export '../../core/theme/app_metrics.dart';
export '../../core/theme/app_spacing.dart';
export '../../core/theme/app_theme.dart';
export '../../core/theme/app_typography.dart';

/// Delegates to [appTheme] from the design system.
/// Keep calling [theme()] anywhere the old signature was used.
ThemeData theme() => appTheme();

import 'package:flutter/material.dart';

/// Simmetry — Ink & Paper design system.
///
/// Raw color constants. These are the single source of truth for hex values
/// and are referenced ONLY by the theme definition ([appColorScheme],
/// [AppSemanticColors], and the component themes in `app_themes.dart`).
/// Widgets must read colors from `Theme.of(context).colorScheme` or
/// `context.semantic` — never from this class directly.
class AppColors {
  AppColors._();

  // ── Primary (Vermilion) ───────────────────────────────
  static const Color primary = Color(0xFFB91C1C);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFFFECACA);
  static const Color onPrimaryContainer = Color(0xFF7F1D1D);

  // ── Secondary (Warm Stone) ─────────────────────────────
  static const Color secondary = Color(0xFF78716C);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color secondaryContainer = Color(0xFFF5F5F4);
  static const Color onSecondaryContainer = Color(0xFF1C1917);

  // ── Tertiary (Amber — drafts & warnings) ───────────────
  static const Color tertiary = Color(0xFFD97706);
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color tertiaryContainer = Color(0xFFFEF3C7);
  static const Color onTertiaryContainer = Color(0xFF92400E);

  // ── Surface ────────────────────────────────────────────
  static const Color surface = Color(0xFFFAFAF9);
  static const Color onSurface = Color(0xFF1C1917);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF5F5F4);
  static const Color surfaceContainer = Color(0xFFEFEDEB);
  static const Color surfaceContainerHigh = Color(0xFFEAE8E6);
  static const Color surfaceContainerHighest = Color(0xFFE7E5E4);
  static const Color onSurfaceVariant = Color(0xFF78716C);

  // ── Error ──────────────────────────────────────────────
  static const Color error = Color(0xFFDC2626);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color errorContainer = Color(0xFFFEE2E2);
  static const Color onErrorContainer = Color(0xFF991B1B);

  // ── Outline ────────────────────────────────────────────
  static const Color outline = Color(0xFFE7E5E4);
  static const Color outlineVariant = Color(0xFFD6D3D1);

  // ── Inverse (snackbars, tooltips) ──────────────────────
  static const Color inverseSurface = Color(0xFF1C1917);
  static const Color onInverseSurface = Color(0xFFFAFAF9);
  static const Color inversePrimary = Color(0xFFFECACA);

  // ── Misc ───────────────────────────────────────────────
  static const Color shadow = Color(0xFF1C1917);
  static const Color scrim = Color(0xFF1C1917);
  static const Color surfaceTint = Color(0xFFB91C1C);

  // ── Semantic extras (not in M3 ColorScheme → AppSemanticColors) ──
  static const Color success = Color(0xFF15803D);
  static const Color onSuccess = Color(0xFFFFFFFF);
  static const Color successContainer = Color(0xFFF0FDF4);
  static const Color onSuccessContainer = Color(0xFF166534);

  // Spec warning is amber (#D97706 == [tertiary]).
  static const Color warning = Color(0xFFD97706);
  static const Color onWarning = Color(0xFFFFFFFF);
  static const Color warningContainer = Color(0xFFFEF3C7);
  static const Color onWarningContainer = Color(0xFF92400E);

  static const Color info = Color(0xFF1D4ED8);
  static const Color onInfo = Color(0xFFFFFFFF);
  static const Color infoContainer = Color(0xFFEFF6FF);
  static const Color onInfoContainer = Color(0xFF1E3A8A);

  // ── Status badge palettes (draft / published / archived) ──
  static const Color draftBg = Color(0xFFFFFBEB);
  static const Color draftFg = Color(0xFF92400E);
  static const Color draftBorder = Color(0xFFFDE68A);

  static const Color publishedBg = Color(0xFFF0FDF4);
  static const Color publishedFg = Color(0xFF15803D);
  static const Color publishedBorder = Color(0xFF86EFAC);

  static const Color archivedBg = Color(0xFFF1F5F9);
  static const Color archivedFg = Color(0xFF475569);
  static const Color archivedBorder = Color(0xFFCBD5E1);

  // ── Text hierarchy shortcuts (mirror ColorScheme roles) ──
  static const Color textPrimary = Color(0xFF1C1917); // onSurface
  static const Color textSecondary = Color(0xFF78716C); // onSurfaceVariant
  static const Color textDisabled = Color(0xFFD6D3D1); // outlineVariant
  static const Color textPlaceholder = Color(0xFFB8B0A8); // input hints
}

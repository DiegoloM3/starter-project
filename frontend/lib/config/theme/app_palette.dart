import 'package:flutter/material.dart';

/// Design tokens that Material's [ColorScheme] does not model directly.
///
/// The palette is a newspaper's: warm grey paper, near-black ink, one red for
/// everything that acts or must be seen, and 2px rules instead of shadows or
/// rounded cards. Read it with `Theme.of(context).extension<AppPalette>()!`
/// or the [AppPaletteX] shortcut.
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  /// The accent red: primary actions, the active tab, row numbers.
  final Color primary;

  /// Deeper red for kickers, links and small text that must stay legible.
  final Color primaryDeep;
  final Color primaryContainer;
  final Color onPrimaryContainer;

  /// Slightly lighter surface for inputs and previews.
  final Color tint;

  /// Paper.
  final Color background;

  /// Cards and hover: one step darker than the paper.
  final Color surface;
  final Color ink;
  final Color inkBody;
  final Color inkSecondary;

  /// Soft rule between rows of the same list.
  final Color outline;

  /// The 2px rule that structures every screen.
  final Color outlineStrong;
  final Color error;
  final Color errorContainer;
  final Color dangerFill;
  final Color dangerBorder;
  final Color success;
  final Color successContainer;
  final Color onSuccessContainer;
  final Color skeletonBone;
  final Color skeletonHighlight;

  /// Ink block used for badges ("YOU") and strong buttons.
  final Color accent;
  final Color onAccent;

  /// Grey plate standing in for a missing photo, and the hatch drawn on it.
  final Color plate;
  final Color hatch;

  /// Frosted-glass fill for bars floating over content.
  final Color glass;

  const AppPalette({
    required this.primary,
    required this.primaryDeep,
    required this.primaryContainer,
    required this.onPrimaryContainer,
    required this.tint,
    required this.background,
    required this.surface,
    required this.ink,
    required this.inkBody,
    required this.inkSecondary,
    required this.outline,
    required this.outlineStrong,
    required this.error,
    required this.errorContainer,
    required this.dangerFill,
    required this.dangerBorder,
    required this.success,
    required this.successContainer,
    required this.onSuccessContainer,
    required this.skeletonBone,
    required this.skeletonHighlight,
    required this.accent,
    required this.onAccent,
    required this.plate,
    required this.hatch,
    required this.glass,
  });

  static const AppPalette light = AppPalette(
    primary: Color(0xFFEC3013),
    primaryDeep: Color(0xFFAE1800),
    primaryContainer: Color(0xFFFFE0D9),
    onPrimaryContainer: Color(0xFF7C1405),
    tint: Color(0xFFF8F4F4),
    background: Color(0xFFF3F2F2),
    surface: Color(0xFFEAE9E9),
    ink: Color(0xFF201E1D),
    inkBody: Color(0xFF4D4A49),
    inkSecondary: Color(0xFF7B7877),
    outline: Color(0xFFD3D2D1),
    outlineStrong: Color(0xFFA9A7A7),
    error: Color(0xFFAE1800),
    errorContainer: Color(0xFFFFE0D9),
    dangerFill: Color(0xFFFFF2EF),
    dangerBorder: Color(0xFFFF9783),
    success: Color(0xFF1F6B4A),
    successContainer: Color(0xFFDDF0E6),
    onSuccessContainer: Color(0xFF1D5A3F),
    skeletonBone: Color(0xFFDFDCDC),
    skeletonHighlight: Color(0xFFEFEDED),
    accent: Color(0xFF201E1D),
    onAccent: Color(0xFFF3F2F2),
    plate: Color(0xFFC9C5C5),
    hatch: Color(0x80201E1D),
    glass: Color(0xB3F3F2F2),
  );

  static const AppPalette dark = AppPalette(
    primary: Color(0xFFFF563C),
    primaryDeep: Color(0xFFFF9783),
    primaryContainer: Color(0xFF7C1405),
    onPrimaryContainer: Color(0xFFFFC4B8),
    tint: Color(0xFF1C1B1A),
    background: Color(0xFF151413),
    surface: Color(0xFF232120),
    ink: Color(0xFFF3F2F2),
    inkBody: Color(0xFFD0CDCD),
    inkSecondary: Color(0xFF9B9797),
    outline: Color(0xFF363433),
    outlineStrong: Color(0xFF5B5958),
    error: Color(0xFFFF9783),
    errorContainer: Color(0xFF4D170E),
    dangerFill: Color(0xFF2A1512),
    dangerBorder: Color(0xFF7C1405),
    success: Color(0xFF7FCBA5),
    successContainer: Color(0xFF1D5A3F),
    onSuccessContainer: Color(0xFFDDF0E6),
    skeletonBone: Color(0xFF2D2B2B),
    skeletonHighlight: Color(0xFF3A3736),
    accent: Color(0xFFF3F2F2),
    onAccent: Color(0xFF151413),
    plate: Color(0xFF3A3736),
    hatch: Color(0x4DF3F2F2),
    glass: Color(0x99151413),
  );

  @override
  AppPalette copyWith() => this;

  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) {
    if (other is! AppPalette) return this;
    Color mix(Color a, Color b) => Color.lerp(a, b, t)!;
    return AppPalette(
      primary: mix(primary, other.primary),
      primaryDeep: mix(primaryDeep, other.primaryDeep),
      primaryContainer: mix(primaryContainer, other.primaryContainer),
      onPrimaryContainer: mix(onPrimaryContainer, other.onPrimaryContainer),
      tint: mix(tint, other.tint),
      background: mix(background, other.background),
      surface: mix(surface, other.surface),
      ink: mix(ink, other.ink),
      inkBody: mix(inkBody, other.inkBody),
      inkSecondary: mix(inkSecondary, other.inkSecondary),
      outline: mix(outline, other.outline),
      outlineStrong: mix(outlineStrong, other.outlineStrong),
      error: mix(error, other.error),
      errorContainer: mix(errorContainer, other.errorContainer),
      dangerFill: mix(dangerFill, other.dangerFill),
      dangerBorder: mix(dangerBorder, other.dangerBorder),
      success: mix(success, other.success),
      successContainer: mix(successContainer, other.successContainer),
      onSuccessContainer: mix(onSuccessContainer, other.onSuccessContainer),
      skeletonBone: mix(skeletonBone, other.skeletonBone),
      skeletonHighlight: mix(skeletonHighlight, other.skeletonHighlight),
      accent: mix(accent, other.accent),
      onAccent: mix(onAccent, other.onAccent),
      plate: mix(plate, other.plate),
      hatch: mix(hatch, other.hatch),
      glass: mix(glass, other.glass),
    );
  }
}

extension AppPaletteX on BuildContext {
  AppPalette get palette => Theme.of(this).extension<AppPalette>()!;
}

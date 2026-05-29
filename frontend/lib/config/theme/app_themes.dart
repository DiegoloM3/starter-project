import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_color_scheme.dart';
import 'app_colors.dart';
import 'app_radius.dart';
import 'app_semantic_colors.dart';
import 'app_typography.dart';

// Re-export the token modules so existing `import '.../app_themes.dart'`
// statements keep resolving every name.
export 'app_color_scheme.dart';
export 'app_colors.dart';
export 'app_radius.dart';
export 'app_semantic_colors.dart';
export 'app_shadows.dart';
export 'app_spacing.dart';
export 'app_typography.dart';

/// Single entry point — `MaterialApp(theme: theme())`.
ThemeData theme() => buildAppTheme();

/// Builds the full Ink & Paper [ThemeData]: M3 color scheme, type scale,
/// semantic color extension, and every component theme.
ThemeData buildAppTheme() {
  return ThemeData(
    useMaterial3: true,
    colorScheme: appColorScheme,
    textTheme: buildAppTextTheme(),
    extensions: const [AppSemanticColors.light],
    scaffoldBackgroundColor: AppColors.surfaceContainerLow,
    fontFamily: GoogleFonts.mulish().fontFamily,
    dividerColor: AppColors.outline,
    appBarTheme: appBarTheme(),

    // ── FilledButton (primary CTA — Publish, Sign In) ──
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.55),
        disabledForegroundColor: AppColors.onPrimary.withValues(alpha: 0.7),
        minimumSize: const Size(double.infinity, 52),
        padding: const EdgeInsets.symmetric(vertical: 15),
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        textStyle: GoogleFonts.mulish(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
      ),
    ),

    // ── OutlinedButton (secondary — Save Draft, Keep Editing) ──
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        disabledForegroundColor: AppColors.textDisabled,
        minimumSize: const Size(double.infinity, 52),
        padding: const EdgeInsets.symmetric(vertical: 12),
        side: const BorderSide(color: AppColors.primary, width: 1.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        textStyle: GoogleFonts.mulish(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    // ── TextButton (ghost — Discard, Cancel links) ──
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.textSecondary,
        minimumSize: const Size(0, 44),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        textStyle: GoogleFonts.mulish(
          fontSize: 13.5,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),

    // ── InputDecoration ──
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surfaceContainerLowest,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 13, vertical: 13),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: AppColors.outline, width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: AppColors.outline, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: AppColors.primary, width: 2.0),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: AppColors.error, width: 2.0),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: AppColors.error, width: 2.0),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide:
            const BorderSide(color: AppColors.outlineVariant, width: 1.5),
      ),
      labelStyle: GoogleFonts.mulish(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.8,
        color: AppColors.textSecondary,
      ),
      floatingLabelStyle: GoogleFonts.mulish(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.8,
        color: AppColors.primary,
      ),
      hintStyle: GoogleFonts.mulish(
        fontSize: 15,
        color: AppColors.textPlaceholder,
        fontWeight: FontWeight.w400,
      ),
      errorStyle: GoogleFonts.mulish(
        fontSize: 11,
        color: AppColors.error,
        fontWeight: FontWeight.w500,
      ),
      prefixIconColor: WidgetStateColor.resolveWith((states) {
        if (states.contains(WidgetState.focused)) return AppColors.primary;
        if (states.contains(WidgetState.error)) return AppColors.error;
        return AppColors.textSecondary;
      }),
    ),

    // ── Card ──
    cardTheme: CardThemeData(
      color: AppColors.surface,
      elevation: 1,
      shadowColor: const Color(0x141C1917),
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        side: const BorderSide(color: AppColors.outline, width: 1),
      ),
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.zero,
    ),

    // NOTE: navigationBarTheme is intentionally omitted — the app uses a custom
    // `_BottomNav` widget (daily_news.dart), not Material's NavigationBar.

    // ── FloatingActionButton (square-rounded) ──
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.onPrimary,
      elevation: 4,
      focusElevation: 6,
      hoverElevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.xl16),
      ),
      extendedTextStyle: GoogleFonts.mulish(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.3,
      ),
    ),

    // ── BottomSheet (delete confirm, sign out) ──
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      modalElevation: 0,
      dragHandleColor: AppColors.outline,
      dragHandleSize: Size(36, 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      clipBehavior: Clip.antiAlias,
    ),

    // ── SnackBar (undo delete / unsave) ──
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.inverseSurface,
      contentTextStyle: GoogleFonts.mulish(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: AppColors.onInverseSurface,
      ),
      actionTextColor: AppColors.inversePrimary,
      actionBackgroundColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      behavior: SnackBarBehavior.floating,
      elevation: 6,
      insetPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
    ),

    // ── Chip / Badge ──
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.surfaceContainerLow,
      selectedColor: AppColors.primaryContainer,
      labelStyle: GoogleFonts.mulish(
        fontSize: 9.5,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.8,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.xs),
        side: const BorderSide(color: AppColors.outline),
      ),
    ),

    // ── Divider ──
    dividerTheme: const DividerThemeData(
      color: AppColors.outline,
      thickness: 1,
      space: 0,
    ),

    // ── ListTile (profile menu rows) ──
    listTileTheme: ListTileThemeData(
      tileColor: AppColors.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      minLeadingWidth: 0,
      iconColor: AppColors.textSecondary,
      titleTextStyle: GoogleFonts.mulish(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      subtitleTextStyle: GoogleFonts.mulish(
        fontSize: 12,
        color: AppColors.textSecondary,
      ),
    ),

    // ── Dialog ──
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.xl16),
      ),
      titleTextStyle: GoogleFonts.libreBaskerville(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
      contentTextStyle: GoogleFonts.mulish(
        fontSize: 13.5,
        color: AppColors.textSecondary,
        height: 1.55,
      ),
    ),
  );
}

/// AppBar base system: surface background, flat, no M3 scroll tint, serif title.
AppBarTheme appBarTheme() {
  return AppBarTheme(
    backgroundColor: AppColors.surface,
    foregroundColor: AppColors.textPrimary,
    elevation: 0,
    scrolledUnderElevation: 0,
    surfaceTintColor: Colors.transparent,
    shadowColor: AppColors.shadow.withValues(alpha: 0.08),
    centerTitle: false,
    iconTheme: const IconThemeData(color: AppColors.onSurface),
    titleTextStyle: GoogleFonts.libreBaskerville(
      fontSize: 17,
      fontWeight: FontWeight.w700,
      color: AppColors.textPrimary,
      letterSpacing: -0.2,
    ),
    systemOverlayStyle: const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarBrightness: Brightness.light,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: AppColors.surface,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
}

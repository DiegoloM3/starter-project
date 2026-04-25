import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Responsive sizing utility. Requires [ScreenUtilInit] to be initialized
/// before calling any method (wrapping [MaterialApp] with [ScreenUtilInit]
/// using designSize: const Size(375, 812) is sufficient).
class AppMetrics {
  AppMetrics._();

  /// Scales [size] relative to the design width (375px).
  static double w(double size) => size.w;

  /// Scales [size] relative to the design height (812px).
  static double h(double size) => size.h;

  /// Scales font [size] relative to the design width, respecting
  /// the user's font-scale accessibility setting.
  static double sp(double size) => size.sp;

  /// Scales [size] uniformly based on the shorter screen dimension,
  /// suitable for border radii and icon sizes.
  static double r(double size) => size.r;

  /// Returns true for devices narrower than 360dp (e.g. small Android phones).
  static bool get isSmallDevice => ScreenUtil().screenWidth < 360;

  /// Returns true for devices at least 600dp wide (tablets, large foldables).
  static bool get isTablet => ScreenUtil().screenWidth >= 600;
}

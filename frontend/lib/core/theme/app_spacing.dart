import 'app_metrics.dart';

/// Semantic spacing scale based on the 375px design width.
class AppSpacing {
  AppSpacing._();

  static double get xs => AppMetrics.w(4);
  static double get sm => AppMetrics.w(8);
  static double get md => AppMetrics.w(16);
  static double get lg => AppMetrics.w(24);
  static double get xl => AppMetrics.w(32);
  static double get xxl => AppMetrics.w(48);
}

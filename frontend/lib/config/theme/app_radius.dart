/// Border-radius scale.
///
/// NOTE on the spec mapping: the design spec names its 16 dp radius `xl` and its
/// 20 dp radius `xl2`. This project already shipped `AppRadius.xl = 20`, so to
/// avoid silently shrinking existing usages we keep `xl = 20` (== spec `xl2`)
/// and expose the spec's 16 dp value as [xl16].
class AppRadius {
  AppRadius._();

  static const double xs = 2; // category badge, tiny chip
  static const double sm = 4; // status badge, logo mark
  static const double md = 8; // input field, primary button, thumbnail
  static const double lg = 12; // card, snackbar, menu row icon
  static const double xl16 = 16; // spec `xl`: FAB (square), bottom sheet corner
  static const double xl = 20; // spec `xl2`: search/input/tag pill
  static const double full = 9999; // avatar, circular FAB, rounded pill
}

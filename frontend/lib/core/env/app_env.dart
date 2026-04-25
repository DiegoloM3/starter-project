/// Read compile-time environment variables injected via `--dart-define`.
///
/// Run the app with:
///   flutter run --dart-define=NEWS_API_KEY=xxx
///
/// On CI the value comes from the `NEWS_API_KEY` GitHub secret (see
/// [.github/workflows/ci.yml](../../../.github/workflows/ci.yml)).
abstract final class AppEnv {
  static const String newsApiKey = String.fromEnvironment('NEWS_API_KEY');

  /// Whether a NewsAPI key was supplied at build time.
  static bool get hasNewsApiKey => newsApiKey.isNotEmpty;
}

const String newsAPIBaseURL = 'https://newsapi.org/v2';

/// Supplied at build time so the key never sits in the repository:
/// `flutter run --dart-define-from-file=env.json` (see env.example.json).
const String newsAPIKey = String.fromEnvironment('NEWS_API_KEY');

/// The provider requires a country for top headlines; the app is US-only.
const String countryQuery = 'us';

const String newsAPIBaseURL = 'https://newsapi.org/v2';

/// Optional development-only NewsAPI credential.
///
/// Pass `--dart-define=NEWS_API_KEY=...` only for a local development build.
/// Dart embeds this value in the client bundle, so it is exposed to anyone who
/// can inspect that build. The default is intentionally empty: public builds
/// must not call the development-only NewsAPI plan.
const String newsAPIKey = String.fromEnvironment('NEWS_API_KEY');
const String countryQuery = 'us';
const String categoryQuery = 'general';
const String kDefaultImage =
    "https://www.google.com/search?q=default+image&client=firefox-b-d&sxsrf=APq-WBskmtr-ix6NUAqqiHFNpsJX6JSOTg:1650026644151&source=lnms&tbm=isch&sa=X&ved=2ahUKEwjEi_qfjJb3AhXvQd8KHd02BKUQ_AUoAXoECAEQAw#imgrc=A0pMe2lq2NT_jM";

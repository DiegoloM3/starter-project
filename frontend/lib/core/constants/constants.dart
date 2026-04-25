import 'package:news_app_clean_architecture/core/env/app_env.dart';

const String newsAPIBaseURL = 'https://newsapi.org/v2';

/// NewsAPI key, injected at build time via `--dart-define=NEWS_API_KEY=...`.
///
/// Kept as a re-export so existing call sites keep working until F4
/// refactors the NewsAPI data source to read from [AppEnv] directly.
String get newsAPIKey => AppEnv.newsApiKey;

const String countryQuery = 'us';
const String categoryQuery = 'general';
const String kDefaultImage =
    'https://www.google.com/search?q=default+image&client=firefox-b-d&sxsrf=APq-WBskmtr-ix6NUAqqiHFNpsJX6JSOTg:1650026644151&source=lnms&tbm=isch&sa=X&ved=2ahUKEwjEi_qfjJb3AhXvQd8KHd02BKUQ_AUoAXoECAEQAw#imgrc=A0pMe2lq2NT_jM';

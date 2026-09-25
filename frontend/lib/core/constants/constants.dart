import 'package:flutter_dotenv/flutter_dotenv.dart';

const String newsAPIBaseURL = 'https://newsapi.org/v2';

// Not a literal on purpose: a real API key doesn't belong in source, and
// this project's key had been sitting in the very first commit of the
// starter template -- shared with anyone else who ever cloned it, not
// provisioned for this submission. Comes from .env (gitignored) instead,
// loaded once in main() before anything that could need it; see
// .env.template for how to set your own up.
// Guarded: tests never call main()'s dotenv.load(), so dotenv.env would
// throw here rather than just come back empty, same as a genuinely
// missing key does.
String get newsAPIKey {
  try {
    return dotenv.env['NEWS_API_KEY'] ?? '';
  } catch (_) {
    return '';
  }
}

const String countryQuery = 'us';

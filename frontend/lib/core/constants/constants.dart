/// Base URL of the public news API used by the remote data source.
const String newsAPIBaseURL = 'https://newsapi.org/v2';

/// API key for the public news API. Override at build time with
/// `--dart-define=NEWS_API_KEY=...`; the bundled value is a demo fallback.
const String newsAPIKey = String.fromEnvironment(
  'NEWS_API_KEY',
  defaultValue: 'ff957763c54c44d8b00e5e082bc76cb0',
);

/// Country filter for top headlines.
const String countryQuery = 'us';

/// Category filter for top headlines.
const String categoryQuery = 'general';
const String kDefaultImage = "https://www.google.com/search?q=default+image&client=firefox-b-d&sxsrf=APq-WBskmtr-ix6NUAqqiHFNpsJX6JSOTg:1650026644151&source=lnms&tbm=isch&sa=X&ved=2ahUKEwjEi_qfjJb3AhXvQd8KHd02BKUQ_AUoAXoECAEQAw#imgrc=A0pMe2lq2NT_jM";

/// Firestore collection holding public user profiles at `users/{uid}`.
const String kUsersCollection = 'users';

/// Firestore collection holding user-created articles.
const String kArticlesCollection = 'articles';

/// Firestore collection holding article comments.
const String kCommentsCollection = 'comments';

/// Cloud Storage folder for article thumbnail uploads.
const String kArticleThumbnailsFolder = 'media/articles';

/// Cloud Storage folder for user avatar uploads (`<folder>/<uid>/<file>`).
const String kAvatarsFolder = 'media/avatars';

/// Fallback author name when the signed-in user has no display name.
const String kDefaultUserDisplayName = 'Anonymous';

/// How long author profiles stay in the in-memory repository cache.
const Duration kAuthorProfileCacheTtl = Duration(minutes: 10);

/// Host for the Firebase emulators (see `backend/firebase.json`).
const String kEmulatorHost = 'localhost';

/// Emulator ports, mirroring `backend/firebase.json`.
const int kEmulatorAuthPort = 9099;
const int kEmulatorFirestorePort = 8080;
const int kEmulatorStoragePort = 9199;

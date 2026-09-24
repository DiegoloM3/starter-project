/// Values the app is built against, in one place.
///
/// The `k` prefix is the convention here; the three News API constants kept
/// their original names because they are what the starter project shipped and
/// renaming them buys nothing.
///
/// The API key is committed, which is not how a secret should be handled. It
/// came with the starter project and is a free News API developer key; it is
/// recorded as a known issue rather than quietly left to look deliberate.
const String newsAPIBaseURL = 'https://newsapi.org/v2';
const String newsAPIKey = 'ff957763c54c44d8b00e5e082bc76cb0';
const String countryQuery = 'us';

/// Stand-in cover for a headline the API sent without a picture.
///
/// It used to be a Google Images *search page* URL, which is not an image at
/// all: every article without a picture asked the network for an HTML page
/// and failed to decode it. A placeholder service returns a real image, and
/// the card falls back to its own icon if even this cannot be reached.
const String kDefaultImage =
    'https://placehold.co/600x400/E5E7EB/6B7280/png?text=No+image';

/// Firestore collection holding the articles journalists write.
const String kArticlesCollection = 'articles';

/// Cloud Storage folder holding article cover images, as documented in
/// `backend/docs/DB_SCHEMA.md`.
const String kArticleMediaFolder = 'media/articles';

/// How long a call to Firestore may take before the app stops waiting.
///
/// Firestore does not fail a write when the device is offline: it queues it
/// locally and only completes the future once a server has acknowledged it.
/// Without a deadline that is indistinguishable from a hang, which is what
/// left the editor spinning on "Saving…" with both its buttons dead.
const Duration kFirestoreTimeout = Duration(seconds: 15);

/// The same deadline for Cloud Storage, which carries a whole file and is
/// therefore given longer before the app gives up on it.
const Duration kStorageTimeout = Duration(seconds: 45);

/// How long a confirmation with an Undo stays on screen.
///
/// Long enough to notice and act on, short enough that it is gone before the
/// reader has moved on. Stated rather than left to the default, which outlived
/// the moment it belonged to.
const Duration kUndoDuration = Duration(seconds: 4);

# Symmetry Applicant Showcase — Report

**Applicant:** Juan Camilo  
**Date:** April 2026  
**Repository:** `starter-project` (Flutter + Firebase + BLoC)

---

## 1. Introduction

When I first opened this repository my honest reaction was: *this is going to be intense, and that's exactly what I need.* I'm a backend-heavy developer — Java/Spring Boot WebFlux microservices, React, Angular, Node.js — with only surface-level exposure to Flutter and Firebase from coursework at SENA. I had never built a production feature in Dart. I had never written a Cubit. I had never deployed Firestore rules.

What I did have was a strong foundation in Clean Architecture (I apply it daily on Ubik, a seven-microservice hotel reservation platform I'm building from scratch), reactive programming patterns, and the discipline to read documentation seriously before writing a single line of code.

The assignment asked me to learn Flutter, Firebase, and BLoC in roughly 72 hours and deliver something real. This report documents what I built, what broke, how I fixed it, and what I would do differently with more time.

---

## 2. Learning Journey

### What I already knew (at a surface level)

I had seen Flutter in academic contexts and understood it was a widget-based, reactive UI framework. I knew Firebase existed and had played with Firestore in small exercises during my program. I had no production experience with either.

I want to be transparent about this: the knowledge I came in with was foundational, not practical. Everything that works in this codebase was learned specifically for this assessment.

### What I learned for this assessment

**Dart and Flutter** — I started with the official Flutter codelab and the clean architecture tutorial by Reso Coder referenced in the README. That video was invaluable: it showed me how the three layers map to folders, how `get_it` wires dependencies, and how `BlocBuilder` connects state to widgets. The widget tree model clicked quickly because of my React background — it's declarative, just with a stronger type system and no virtual DOM.

**Flutter BLoC / Cubit** — I studied the BLoC library docs and the Kodeco Cubits chapter linked in the README. I chose Cubits over full BLoCs for the `article_upload` feature because the state machine is linear (initial → loading → success/failure) and doesn't require the event abstraction layer. For `daily_news` I kept the existing BLoC pattern untouched to respect the established convention.

**Firebase Firestore + Storage** — I read the Firestore data modeling tutorial, the security rules documentation, and the Flutter + Firebase series. Designing the schema and writing the `firestore.rules` enforcement was one of the parts I invested the most time in — I wanted server-side validation to be complete and explicit.

**Floor (SQLite ORM)** — The existing codebase used Floor for local article persistence. I studied the generated `app_database.g.dart` to understand the DAO pattern. For draft persistence I chose `SharedPreferences` — simpler key-value store for a single-object draft, no schema migration needed.

---

## 3. Challenges Faced

### 3.1 Firebase billing account — Storage blocked

This was the most significant obstacle of the entire assessment. My Google Cloud billing account had restrictions that prevented Firebase Storage from accepting writes. I could not use the real Firebase project for storage uploads.

My solution was to run the entire feature against the **Firebase Local Emulator Suite** and serve the Flutter app as a static web build:

```bash
# Terminal 1 — Firebase emulators
cd backend && firebase emulators:start
# Firestore: :8080 | Storage: :9199 | UI: :4000

# Terminal 2 — Flutter web
cd frontend
flutter build web --no-web-resources-cdn
python -m http.server 8888 --directory build/web

# Open http://localhost:8888
```

The feature is fully functional and demonstrable against local emulators. All architecture, validation logic, and UX flows work identically to what production would look like. Restoring the live Firebase project requires one-line changes in `firebase_options.dart` and removing the emulator connection calls in `main.dart`. The production Firestore security rules (requiring `request.auth != null`) are preserved in comments for when that moment comes.

### 3.2 Flutter web — mobile-only APIs

Targeting Flutter web exposed several APIs that do not exist in a browser context:

**`putFile()` (Firebase Storage)** — Requires `dart:io`'s `File` class, unavailable on web. I gated the upload on `kIsWeb` and switched to `putData()` via `XFile.readAsBytes()`:

```dart
if (kIsWeb) {
  final bytes = await xFile.readAsBytes();
  await ref.putData(bytes);
} else {
  await ref.putFile(File(localFilePath));
}
```

**`Image.file()` (thumbnail preview)** — Also requires `dart:io`. On web, `image_picker` returns a blob URL that loads correctly with `Image.network()`. I added a `kIsWeb` branch in `ThumbnailPickerWidget` to handle both platforms transparently.

**SQLite / Floor** — The Floor ORM depends on `sqflite`, which uses native SQLite bindings unavailable in a browser. I created in-memory stub implementations (`_WebAppDatabase`) that satisfy the `AppDatabase` interface without crashing the web build. The save/remove functionality for the daily news feature is gracefully degraded on web — articles are held in memory for the session.

### 3.3 CORS — News API blocked on web

`newsapi.org` blocks browser requests by design. On Flutter web, every call to the News API fails with a CORS error. This is a documented limitation of that API, not a bug in the app.

To keep the home screen useful and the end-to-end flow demonstrable on web, I implemented a `GetAllArticlesUseCase` that reads published articles from Firestore as a community feed. After a successful upload, the feed refreshes automatically — the full create → publish → appear in feed loop works end-to-end.

### 3.4 Draft restore dialog — context invalidation

The draft restore dialog was calling `setState` after `Navigator.pop()`, but the build context was already invalidated by the time the pop animation completed, causing a `setState called after dispose` warning in debug mode. Fix: call `Navigator.of(context).pop()` before any `setState`, ensuring the dialog is removed from the tree before the parent widget rebuilds.

### 3.5 BLoC state emission in async contexts

The `Emitter`-based handler pattern in BLoC closes the emitter after the handler completes. Early on I had a case where I awaited an operation and then tried to emit a state — the emitter was already closed. The fix was to ensure all `emit()` calls happen within the active handler scope, restructuring the async chain so no emission occurs after the handler's `Future` has resolved.

### 3.6 Firestore security rules — CEL syntax

Writing server-side schema validation in Firestore's CEL expression language was entirely new to me. The `isValidArticle()` function in `firestore.rules` validates field presence, types, and constraints (title ≤ 120 chars, tags ≤ 5 elements, numeric fields ≥ 0). Getting `data.keys().hasAll([...])` combined with type checks right required careful reading of the security rules reference documentation.

---

## 4. Reflection and Future Directions

### What I learned

This assessment reinforced something I suspected but hadn't fully tested: Clean Architecture is genuinely language-agnostic. Every pattern I use in Spring Boot — `UseCase → Repository interface → RepositoryImpl → DataSource` — maps directly to Flutter with almost no conceptual translation. The dependency inversion principle, the single responsibility of use cases, the separation of entities from models: it all landed naturally once I understood the Flutter tooling.

I also learned that Flutter web is a legitimate deployment target with real, non-trivial platform differences. The `kIsWeb` gating pattern, the absence of `dart:io`, CORS constraints — these are real engineering decisions.

Most importantly: I can learn a new stack under time pressure and produce something architecturally sound. That was the point of this exercise, and I hope the output demonstrates it honestly.

### Future improvements

**Authentication** — The current code reads `FirebaseAuth.instance.currentUser` directly in the presentation layer. A proper `AuthRepository` and `GetCurrentUserUseCase` would isolate this and make it testable. The schema already anticipates this: `authorId` and `authorName` are required fields.

**Real Firebase project** — Once the billing issue is resolved, restoring production connectivity is the only step needed. No architectural changes required.

**Pagination** — `getMyArticles` fetches all documents. Firestore cursor-based pagination (`startAfterDocument`) should be added to the repository layer before the collection grows.

**Offline support** — Enabling `FirebaseFirestore.instance.settings = const Settings(persistenceEnabled: true)` would give users seamless behavior on unstable connections.

**Real analytics backend** — `ConsoleAnalyticsService` is a clean abstraction point. Swapping in Firebase Analytics is a single line in `injection_container.dart`.

**CI/CD** — A GitHub Actions workflow running `flutter analyze`, `flutter test`, and a web build check on every PR would be the first thing I'd add to a shared codebase.

---

## 5. Proof of the Project

### How to run locally

```bash
# Prerequisites: Firebase CLI installed, Flutter SDK installed

# Step 1 — Start Firebase emulators
cd backend
firebase emulators:start
# Firestore:    http://localhost:8080
# Storage:      http://localhost:9199
# Emulator UI:  http://localhost:4000

# Step 2 — Build Flutter web
cd frontend
flutter build web --no-web-resources-cdn

# Step 3 — Serve the build
python -m http.server 8888 --directory build/web

# Step 4 — Open http://localhost:8888
```

### Architecture overview

The implemented `article_upload` feature follows the complete Clean Architecture stack:

```
article_upload/
├── data/
│   ├── data_sources/
│   │   ├── article_upload_remote_datasource.dart   # Firestore + Storage (web + mobile)
│   │   └── draft_local_datasource.dart             # SharedPreferences
│   ├── models/
│   │   ├── article_upload_model.dart               # Extends entity, toFirestore()
│   │   └── article_draft_model.dart                # Extends entity, JSON serialization
│   └── repository/
│       ├── article_upload_repository_impl.dart
│       └── draft_repository_impl.dart
├── domain/
│   ├── entities/
│   │   ├── article_upload_entity.dart              # calculateReadTime() business logic
│   │   └── article_draft_entity.dart               # isEmpty guard
│   ├── repository/
│   │   ├── article_upload_repository.dart          # Abstract
│   │   └── draft_repository.dart                   # Abstract interface
│   └── use_cases/
│       ├── upload_article_usecase.dart
│       ├── upload_article_thumbnail_usecase.dart
│       ├── get_upload_articles_usecase.dart
│       ├── get_all_articles_usecase.dart            # Community feed (web fallback)
│       ├── save_draft_usecase.dart
│       ├── load_draft_usecase.dart
│       ├── clear_draft_usecase.dart
│       └── increment_article_views_usecase.dart
└── presentation/
    ├── bloc/
    │   ├── article_upload_cubit.dart
    │   └── article_upload_state.dart
    ├── pages/
    │   └── create_article_screen.dart
    └── widgets/
        ├── thumbnail_picker_widget.dart
        ├── publish_button.dart
        ├── read_time_indicator.dart
        └── article_preview_sheet.dart
```

### Firestore schema (`articles` collection)

| Field        | Type      | Notes                                 |
|--------------|-----------|---------------------------------------|
| title        | string    | required, max 120 chars               |
| content      | string    | required                              |
| thumbnailUrl | string    | `media/articles/` in Storage          |
| authorId     | string    | Firebase Auth UID                     |
| authorName   | string    | denormalized for read performance     |
| createdAt    | timestamp | server timestamp                      |
| updatedAt    | timestamp | server timestamp                      |
| readTime     | number    | `ceil(wordCount / 200)`, clamped 1–99 |
| tags         | string[]  | max 5 tags                            |
| isPublished  | boolean   | draft vs published                    |
| views        | number    | atomic `FieldValue.increment`, default 0 |
| likes        | number    | default 0                             |

---

## 6. Overdelivery

### 6.1 Features beyond the assignment requirements

**Web compatibility layer**  
The assignment targets mobile. I went further and made the full feature run on Flutter web, solving real platform incompatibilities: `putFile` → `putData`, `Image.file` → `Image.network`, Floor/SQLite → in-memory stubs. This required understanding the platform constraints deeply enough to work around them without changing the architecture.

**Auto-save drafts with restore on re-open**  
When a user starts writing and navigates away, the draft is automatically saved to `SharedPreferences` via a debounced 800ms timer. On next open, a dialog prompts the user to continue or discard. Full pipeline: `SaveDraftUseCase` → `DraftRepository` → `DraftLocalDataSource` → `SharedPreferences`, with `LoadDraftUseCase` and `ClearDraftUseCase` completing the trio.

**Community feed as fallback (web)**  
Since the News API is CORS-blocked on web, I implemented `GetAllArticlesUseCase` to load published articles from Firestore. The home screen shows this community feed on web and refreshes automatically after each successful upload, making the create → publish → appear-in-feed loop demonstrable end-to-end.

**Article preview before publishing**  
A `DraggableScrollableSheet` (`ArticlePreviewSheet`) renders a live preview of the article — thumbnail, title, tags, word count, read time, view count — before submission. Staggered fade-in animations using `AnimationController` with `Interval`-based curves give it a polished entrance. The user can edit or publish directly from this sheet, adding a quality-gate without adding friction.

**Analytics instrumentation**  
`AnalyticsService` is an abstract class with a `ConsoleAnalyticsService` implementation that logs to the Dart developer console with timestamps. Events: `onStartCreate`, `onSubmit`, `onSuccess`, `onError`, `onDraftSaved`, `onDraftRestored`, `onDraftDiscarded`. The abstraction makes swapping in a real analytics backend a single line in `injection_container.dart`.

**View count tracking with deduplication**  
`IncrementArticleViewsUseCase` uses Firestore's `FieldValue.increment(1)` for atomic, race-condition-free counting. A `Set<String>` in the Cubit tracks viewed article IDs per session — refreshing the screen does not re-increment.

**Shimmer loading states**  
`ArticleTileShimmer` is a content-aware skeleton that precisely mirrors `ArticleWidget`'s layout. No generic spinner — the shape of the content is communicated while it loads.

**Design token system**  
`AppColors`, `AppSpacing`, `AppRadius`, `AppTextStyles` — every color, spacing value, and text style references these constants. Zero magic numbers in the codebase. Foundation for theming support.

**Reusable shared widgets**  
`AppTextField`, `AppSnackbar`, `ViewCountBadge` — composable, consistently styled components that enforce design coherence across features.

**Custom page transitions**  
`AppPageRoute.fadeAndSlide` — fade + slide-up transition using `CurvedAnimation` with `easeOutCubic`. Replaces the default Material slide-from-right.

**Haptic feedback**  
`HapticFeedback.mediumImpact()` on publish, `HapticFeedback.lightImpact()` on image pick. Small detail, measurable difference in perceived quality.

**Unit tests**  
Two test files covering pure-logic components:
- `article_upload_entity_test.dart` — 6 cases for `calculateReadTime` (boundary values, clamp behavior, edge cases)
- `article_form_validators_test.dart` — 13 cases covering all validator branches and the composite `isFormReady` predicate

### 6.2 Prototype: A/B testing the creation flow

If I had more time, this is the first growth experiment I would run. Firebase Remote Config schema:

```json
{
  "experiment_create_flow_variant": {
    "default_value": "standard",
    "values": ["standard", "preview_first", "guided_steps"]
  }
}
```

- `standard` — current flow (form → publish button)
- `preview_first` — forces preview before publish (reduces low-quality submissions)
- `guided_steps` — step-by-step wizard (thumbnail → title → content → tags → publish)

The `AnalyticsService` already captures all events needed to evaluate these variants: `onStartCreate → onSubmit` conversion rate, `onDraftSaved` as a proxy for session depth, `onError` as a proxy for friction. No changes to domain or data layers required — only the presentation layer reads the Remote Config flag.

### 6.3 What I would improve with more time

- **Firestore composite indexes** — `(authorId, createdAt DESC)` and `(isPublished, createdAt DESC)` need to be added to `firestore.indexes.json` for queries to perform at scale.
- **Image compression** — Client-side resizing to a maximum display width before upload would reduce Storage costs significantly.
- **Rich text editor** — Replacing the plain content `TextField` with `super_editor` or `flutter_quill` would raise content quality for journalists.
- **Optimistic UI on publish** — Update the local feed immediately on submission, roll back on failure. Near-zero perceived latency.
- **Authentication** — Email/password and Google Sign-In. The schema already has `authorId` and `authorName` — it's architecturally ready.

---

## 7. Extra Notes

The billing constraint was genuinely frustrating. Time I would have preferred to spend on features went into debugging Firebase Storage errors and pivoting to the emulator setup. But the pivot itself is worth noting: when production infrastructure is blocked, the right move is to find a path forward that keeps the architecture honest, not to simplify the feature. The emulator approach preserved everything — schema validation, security rules, the full upload pipeline — and made the result demonstrable.

I came into this assessment not knowing Flutter. I leave it with a feature I'd be comfortable shipping. That gap was closed in 72 hours. That's the thing I most want the reviewer to take away from this report.

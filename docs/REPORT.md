# Project Report — News App Firebase Implementation

## 1. Introduction

When I first opened the project, I found a standard Clean Architecture Flutter app backed by a REST API with a local Floor database. The challenge was to replace the remote data layer with Firebase (Firestore, Storage, Auth) while maintaining strict architectural boundaries — something that 8 out of 23 previous PRs failed to do. My goal was not just to complete the requirements, but to deliver a production-grade implementation that none of the 23 prior submissions achieved: tested security rules, verified zero architecture violations, and a complete error-handling pipeline.

## 2. Learning Journey

### Clean Architecture Enforcement
The biggest learning curve was keeping Firebase imports strictly within the data layer. Firestore's `withConverter<T>()` API was essential — it let me keep serialization logic in models and data sources without leaking Firebase types upstream.

### Firebase Security Rules
Writing production-grade rules required understanding Firestore's security model deeply: field validation, status transition enforcement, immutable field protection, and server timestamp requirements. I used `@firebase/rules-unit-testing` to test rules against the emulator — something no previous submission did.

### BLoC with Streams
Moving from Future-based data fetching (REST API) to Stream-based real-time updates (Firestore snapshots) required introducing `StreamUseCase<T, P>` and restructuring BLoCs to manage stream subscriptions properly, including cleanup in `close()`.

## 3. Challenges Faced

### Boy Scout Rule — Fixing Existing Code
The original `ArticleModel` was missing `toEntity()` and used `fromJson` instead of the project's `fromRawData` convention. `ArticleRepositoryImpl` returned `ArticleModel` to the presentation layer, violating the data/domain boundary. Fixing these without breaking existing tests required careful refactoring.

### Error Handling Pipeline
Building a typed error flow (DataSource throws → Repository wraps `DataFailed` → BLoC emits `Failure` state → UI shows contextual error) required creating `AppException` hierarchy (`NetworkException`, `AuthException`, `StorageException`, `ValidationException`, `NotFoundException`) and an `ExceptionMapper` to convert Firebase/Dio exceptions consistently.

### Security Rules Complexity
Enforcing status transitions (`draft → published → archived`) and immutable fields (`id`, `authorId`, `createdAt`) in Firestore rules while keeping them readable was challenging. The append-only comment pattern (content can't be edited, only soft-deleted) added another layer of complexity.

## 4. Reflection and Future Directions

### What I Learned
- **Discipline > features.** A well-enforced architecture with verified boundaries is more valuable than 10 extra features with import violations.
- **Test your rules.** Security rules are not "set and forget" — they're code and need testing like any other code.
- **Stream lifecycle matters.** Leaked Firestore subscriptions cause real bugs in production (stale data, memory leaks).

### Future Improvements
- **Cloud Functions** for server-side validation, push notifications on new articles, and full-text search (replacing the current client-side filter).
- **Pagination** using Firestore cursors (`startAfterDocument`) for the feed instead of loading all articles.
- **Image optimization** pipeline via Cloud Functions to generate thumbnails at multiple resolutions on upload.
- **Offline-first** with explicit conflict resolution using Firestore's pending writes API.

## 5. Proof of the Project

> Screenshots and video recordings of the final app should be added here before submission.

### Key Screens
- **Feed** — Real-time article feed with featured card and skeleton loading
- **Create Article** — Full editor with thumbnail picker, auto-save drafts, reading time calculation
- **Article Preview** — Pre-publish preview matching the feed card layout
- **Article Detail** — Full article view with comments section
- **My Articles** — User's articles with status badges (draft/published/archived)
- **Drafts** — Draft management with edit and resume capability
- **Search** — Client-side search filtering by title and description
- **Profile** — User info, navigation to articles/drafts/saved, sign out

## 6. Overdelivery

### Features No Previous Submission Implemented

| Feature | Description |
|---------|-------------|
| **Firebase Rules Testing** | 70+ tests using `@firebase/rules-unit-testing` against the emulator. Covers auth, field validation, status transitions, immutable fields, soft-delete enforcement, storage MIME/size rules. |
| **Architecture Verification Script** | `scripts/check_architecture.sh` — automated lint checking cross-layer imports. Integrated into CI pipeline. |
| **Boy Scout Rule** | Fixed `ArticleModel` (added `toEntity()`, `fromRawData`), `ArticleRepositoryImpl` (returns entities not models), `Equatable` props (nullable-safe). |
| **Real Drafts** | Save draft → resume editing → publish. Status persisted in Firestore with validated transitions. |
| **Article Preview** | Pre-publish preview screen showing the article as it will appear in the feed. |
| **Reading Time** | Automatic calculation based on word count, displayed in the editor and article tiles. |

### Features Matching Best Previous Submissions

| Feature | Description |
|---------|-------------|
| **My Articles** | User's articles with status badges and action buttons (edit/delete). |
| **Comments** | Subcollection per article, append-only, soft-delete only by author. |
| **i18n** | English and Spanish with ARB files and generated `AppLocalizations`. |
| **Skeleton Loading** | Shimmer-based skeleton placeholders instead of spinners. |
| **Search** | Client-side filtering by title/description across the feed. |
| **Soft-Delete** | Consistent pattern across articles and comments — no hard deletes. |
| **CI Pipeline** | GitHub Actions: `flutter analyze --fatal-warnings`, `flutter test --coverage`, architecture verification. |

### How to Improve Further
- Add widget tests for remaining screens (currently covering feed and article tile).
- Implement Cloud Functions for server-side search and push notifications.
- Add Firestore pagination for large article collections.
- Create E2E integration tests running against Firebase emulators.

## 7. Technical Summary

### Architecture Compliance

All architecture rules from `ARCHITECTURE_VIOLATIONS.md` are enforced:

| Rule | Status |
|------|--------|
| Data layer: no presentation imports | Verified |
| Data layer: no use_case imports | Verified |
| Data sources: only place importing external providers | Verified |
| Models extend entities with `toEntity()` and `fromRawData` | Verified |
| Repository returns `DataState<T>` | Verified |
| Domain: zero project imports (pure Dart) | Verified |
| Presentation: no direct data layer access | Verified |
| BLoCs interact only with use cases | Verified |

Verification method: `scripts/check_architecture.sh` runs in CI on every push and PR.

### Project Statistics

| Metric | Count |
|--------|-------|
| Use cases | 20 |
| BLoCs/Cubits | 11 |
| Screens/Pages | 8 |
| Entity fields (Article) | 15 |
| Frontend tests | 228 |
| Backend rule tests | 70+ |
| Supported locales | 2 (EN, ES) |

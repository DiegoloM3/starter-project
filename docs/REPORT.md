# Project Report — Applicant Showcase App

**Author:** Moises Ramirez  
**Role Applied:** Product Engineer  
**Date:** April 2026

---

## 1. Introduction

When I first opened this repository, two things were immediately clear: the team behind Symmetry takes architecture seriously, and this wasn't a typical "build a CRUD" test. The project already had a well-structured Clean Architecture codebase with clear separation of concerns, strict layer boundaries, and documentation that read more like engineering principles than guidelines.

My initial feeling was respect — for the standard being set — followed by a clear mental model of what needed to happen. The assignment asks you to be a journalist who wants to upload articles. But the real test isn't whether you can write a Firestore query. It's whether you can take an existing codebase, understand its constraints, extend it without breaking its contracts, and deliver something that feels like it belongs there — not bolted on.

I approached this project the way I approach product work: start with the user experience I want to deliver, work backwards to the architecture that supports it, and ship incrementally with each commit leaving the codebase better than I found it.

---

## 2. Learning Journey

### Technologies I Already Knew

- **Flutter & Dart** — I work with Flutter daily as Lead Mobile Developer at my current company. I also maintain an independent Flutter app (MORA App) where I've dealt with Riverpod, GoRouter, Rive animations, Isar-to-ObjectBox migrations, and Android 15 compliance.
- **Firebase** (Auth, Firestore, Cloud Storage) — Extensive experience across multiple projects.
- **Clean Architecture** — Familiar with the pattern, though each team's adaptation has its own nuances.

### What I Had to Learn for This Project

- **BLoC/Cubit pattern** — My daily work uses Riverpod, not BLoC. I invested time understanding the existing BLoC implementation in the codebase, the event/state separation, and how cubits simplify the pattern for straightforward use cases. I chose Cubits for the new features (auth, firebase articles) because they matched the complexity level — no need for event-driven indirection when the state transitions are linear.
- **Floor ORM** — I hadn't used Floor before (I've used Isar and ObjectBox). I studied the existing `AppDatabase` and `ArticleDAO` implementation to understand the code generation patterns and avoided touching the generated `.g.dart` files.
- **Retrofit code generation** — Similarly, I analyzed the existing `NewsApiService` implementation to understand how the API layer was structured.
- **Symmetry's specific architecture rules** — I read every document in the `docs/` folder multiple times: `APP_ARCHITECTURE.md`, `ARCHITECTURE_VIOLATIONS.md`, `CODING_GUIDELINES.md`, and `CONTRIBUTION_GUIDELINES.md`. Understanding these rules was essential before writing a single line of code.

### Resources Used

- Symmetry's internal documentation (primary source of truth)
- [Flutter Clean Architecture Tutorial](https://www.youtube.com/watch?v=7V_P6dovixg) (referenced in the project docs)
- [BLoC Library Documentation](https://bloclibrary.dev/)
- [Firebase Firestore documentation](https://firebase.google.com/docs/firestore)
- [Gemini API documentation](https://ai.google.dev/gemini-api/docs) for the AI integration

---

## 3. Challenges Faced

### 3.1 Dart 3 Compatibility with Legacy Generators

**Problem:** The project was originally built with Dart 2 (`sdk: ">=2.16.1 <3.0.0"`). Running `flutter pub run build_runner build` with my Dart 3 SDK caused `retrofit_generator` to fail with `mapperCode` compilation errors. Downgrading the generator created conflicts with `floor_generator` due to incompatible `analyzer` versions.

**Decision:** Rather than fighting version resolution, I recognized that the existing `.g.dart` files were already generated and functional. Since my new features (Firebase articles, auth) don't use Retrofit or Floor — they interact with Firestore and Firebase Auth directly — there was no need to regenerate. I removed the generators from `dev_dependencies` and kept the existing generated code intact.

**Product Thinking:** A Product Engineer's job isn't to modernize everything — it's to ship value without introducing risk. Upgrading the entire dependency tree would have been a multi-day detour with zero user-facing benefit.

### 3.2 Architecture Decision: Shared Entity vs Feature Duplication

**Problem:** The new Firebase articles and the existing API articles both represent the same concept — a news article. I had two options:

- **Option A:** Create a separate `firebase_articles` feature with its own entity in `shared/`, keeping features independent
- **Option B:** Extend the existing `daily_news` feature, adding Firebase as another data source

**Decision:** Option A with a shared entity. I moved `ArticleEntity` to `shared/article/domain/entities/` and added an `authorId` field (nullable, so existing API articles remain unaffected). Each feature has its own Model that maps its specific data source to this shared entity:

- `ArticleModel` (News API JSON → `ArticleEntity`)
- `FirebaseArticleModel` (Firestore DocumentSnapshot → `ArticleEntity`)

**Why this matters:** The presentation layer never knows where an article came from. The home screen combines both sources seamlessly. This is the Dependency Inversion Principle in action — the UI depends on the abstraction (`ArticleEntity`), not the implementation.

### 3.3 Firestore Security Rules — Silent Failures

**Problem:** After implementing Firebase Auth sign-up, user creation succeeded (Auth) but the Firestore write to `users/` failed with `PERMISSION_DENIED`. The deploy command reported "already up to date, skipping upload" — the rules file on disk didn't match what was actually deployed.

**Decision:** I discovered the deployed rules were from an earlier version that didn't include the `users` collection. I rewrote the complete rules file with proper auth checks: `isAuthenticated()`, `isRegisteredUser()`, `isOwner()`, and deployed successfully.

**Lesson:** In production, a silent rule mismatch could block users from core functionality without any server-side error. This reinforced the importance of treating security rules as code — versioned, tested, and deployed deliberately.

### 3.4 State Management Scope — Cubit Instance Sharing

**Problem:** After creating an article, the home screen didn't update. The `AddArticleScreen` had its own `FirebaseArticlesCubit` instance (provided in the route), separate from the home screen's instance. Updates to one didn't propagate to the other.

**Decision:** I elevated `FirebaseArticlesCubit` to the app-level `MultiBlocProvider` in `main.dart`, so both screens share the same instance. When `AddArticleScreen` creates an article, the cubit emits a new state that the home screen's `BlocBuilder` picks up immediately.

**Product Thinking:** This is a retention-critical detail. If a user creates content and doesn't immediately see it, they question whether it worked. That moment of uncertainty is a churn risk. The fix was architecturally correct AND user-experience correct.

### 3.5 Optimistic State Update vs Re-fetch

**Problem:** After fixing the shared cubit, I initially re-fetched all articles from Firestore after creation (`getArticles()`). This worked but was slow and wasteful — an unnecessary network round-trip.

**Decision:** I changed the flow to an optimistic update: `createArticle` returns the created `ArticleEntity`, the cubit prepends it to the current list, and emits immediately. The user sees their article at the top of the feed in milliseconds, not seconds.

**Trade-off acknowledged:** If the Firestore write fails silently after the optimistic update, the UI would show a phantom article. In production, I'd add a rollback mechanism. For this scope, the improved perceived performance justifies the approach.

### 3.6 Android Build Compatibility

**Problem:** The project wouldn't build on Android due to outdated Gradle (8.4) and Kotlin (1.6.10) versions that were incompatible with current Firebase dependencies.

**Decision:** Updated Gradle to 8.11.1 and Kotlin to 2.1.0, and later updated NDK to 28.2.13676358 and AGP to 8.9.1 when `image_picker` and newer AndroidX dependencies required it. Applied the Boy Scout Rule — these upgrades weren't part of the assignment, but they were necessary and I documented them.

---

## 4. Reflection and Future Directions

### What I Learned

**Architecture is a communication tool.** Symmetry's Clean Architecture isn't just a pattern — it's a contract between team members. When I followed the rules strictly (domain layer has zero Flutter imports, presentation only talks to use cases, data sources are the only place that touches Firebase), my features integrated cleanly. When I briefly considered shortcuts, the architecture violations document caught me.

**Product Engineering is about taste in trade-offs.** Every decision in this project involved a trade-off: shared entity vs duplication, optimistic update vs consistency, mock-first vs implementation-first. The right answer was always "what ships the best experience with the least risk to the codebase?"

**Reading the existing code is the most productive hour you spend.** I spent significant time reading every file in the project before writing anything. Understanding the existing patterns — how `GetIt` is structured, how routes are defined, how BLoC states are composed — meant my additions looked like they'd always been there.

### Future Directions

If I were continuing this project, these are the improvements I'd prioritize, ordered by user impact:

1. **Offline-first article creation** — Queue articles locally when offline and sync when connectivity returns. I have direct experience implementing this pattern with WatermelonDB in React Native. In Flutter, Hive or ObjectBox with a sync queue would work.

2. **Real-time article feed** — Replace the one-time Firestore fetch with a `snapshots()` stream so new articles from other users appear without pull-to-refresh.

3. **Image compression pipeline** — The current implementation uploads images at `imageQuality: 85`. For production scale (300k+ users), I'd add server-side thumbnail generation via Cloud Functions to create multiple resolutions.

4. **Analytics integration** — The role description emphasizes "metrics first." I'd integrate Firebase Analytics or Mixpanel to track activation (first article created), retention (return visits), and conversion (guest to registered) events.

5. **A/B testing framework** — Firebase Remote Config to test different onboarding flows, AI prompt suggestions, and feature placements.

6. **Push notifications** — Notify users when someone bookmarks their article, driving engagement loops.

7. **Article editing and deletion from the UI** — The backend supports it (rules enforce author-only modification), but the UI doesn't expose it yet.

---

## 5. Proof of the Project

> Screenshots and video recordings of the final application are attached separately in the `/docs/media/` folder.
>
> **[🎥 Click here to watch the App Demo Video/GIF (Google Drive)](https://drive.google.com/file/d/1K8lCeH6qE5HrhMluH2xLpalW3nhywUNG/view?usp=sharing)**

### Feature Walkthrough

### Feature Walkthrough

1. **Welcome Screen** — Three entry points: Sign In, Create Account, Continue as Guest
2. **Sign Up** — Creates Firebase Auth account + Firestore user profile
3. **Sign In** — Email/password authentication
4. **Guest Mode** — Firebase Anonymous Auth with read-only access
5. **Home Feed** — Combined API + Firebase articles with SliverAppBar, shimmer loading, and staggered animations
6. **Article Detail** — Hero image transition from feed, full content display
7. **Create Article** — Title, description, content fields with AI generation
8. **AI Assistant** — Gemini-powered article text + thumbnail generation with model fallback
9. **Profile** — Real publication count, bookmark count, horizontal publication cards
10. **Bookmarks** — Save/remove articles with local persistence

---

## 6. Overdelivery

### 6.1 Authentication System (Email + Anonymous)

**Functionality:** Full authentication flow with three modes — email/password registration, email/password sign-in, and anonymous guest access. Guest users can browse all articles but cannot create content. When a guest taps the "+" button, a contextual snackbar offers sign-in with a single tap.

**Architecture:**

- `features/auth/domain/` — `UserEntity`, `AuthRepository` interface, 5 use cases
- `features/auth/data/` — `FirebaseAuthDataSource`, `UserModel`, `AuthRepositoryImpl`
- `features/auth/presentation/` — `AuthCubit` with 5 states, 3 screens
- Firestore security rules enforce permission boundaries server-side

**Product Impact:** Authentication is the foundation of any content creation platform. Without it, you can't attribute articles, enforce ownership, or build social features. The anonymous mode reduces friction — users can explore before committing.

### 6.2 AI-Powered Article Generation (Text + Image)

**Functionality:** Users write a short prompt or key points, tap "Generate with AI," and the system produces a complete article (title, description, content) plus a relevant thumbnail image. All fields auto-populate and can be edited before publishing.

**Technical Implementation:**

- **Text generation:** Gemini API with `responseMimeType: 'application/json'` and a defined `responseSchema` — the model is forced to return structured JSON, eliminating parsing failures in production
- **Image generation:** Gemini 2.5 Flash Image (Nano Banana) via REST API, returning base64-encoded images saved to temporary storage
- **Model fallback:** Both text and image generation cycle through multiple models (`gemini-2.5-flash` → `gemini-2.0-flash` → `gemini-2.5-flash-lite`) if the primary model returns 503 or is unavailable
- **Error handling:** Graceful degradation — if image generation fails, the user still gets the text and can add their own image

**Architecture:** Follows Clean Architecture strictly — `AiArticleDataSource` is the only class that touches the Gemini API, `FirebaseArticleRepository` abstracts it, and the Cubit exposes it to the UI.

**Product Impact:** This directly addresses the job description's requirement for "AI integration" and "recommendation systems." It also dramatically reduces the activation barrier — a user can go from idea to published article in under 30 seconds.

### 6.3 UI/UX Redesign

**Functionality:** Complete visual overhaul of the application while maintaining all existing functionality.

**Key implementations:**

- **SliverAppBar with collapsing animation** — "Breaking News" title smoothly transitions from large expanded text to compact toolbar text on scroll, with the date fading out. Custom `LayoutBuilder` + `Stack` approach for pixel-perfect control
- **Shimmer loading skeletons** — Custom `ShimmerBox` widget with animated gradient, and skeleton screens (`FeaturedArticleSkeleton`, `ArticleTileSkeleton`) that mirror the exact layout of real content
- **Hero image transitions** — Shared `heroTag` on `AppCachedImage` enables smooth image fly-in animations between feed and detail screens
- **Staggered list animations** — Articles fade-in with a subtle slide-up as they enter the viewport, using `addPostFrameCallback` for timing
- **Featured article card** — First article renders as a large hero card, remaining articles as compact tiles

**Reusable components created:**

- `AppCachedImage` — Centralized image widget with loading, error states, and optional Hero support
- `ShimmerBox` — Animated shimmer placeholder, configurable size and border radius
- `UserAvatar` — Auth-aware avatar with initial letter, scales with radius
- `AppColors` — Centralized color constants
- `AppDimensions` — Centralized spacing and sizing constants
- `DateFormatter` — Consistent date formatting across the app

**Product Impact:** Perceived performance (shimmer > spinner), spatial continuity (Hero transitions), and visual polish directly correlate with user trust and retention. These aren't cosmetic — they're product decisions.

### 6.4 Profile Screen with Real Data

**Functionality:** User profile displaying real publication count (filtered from `FirebaseArticlesCubit` by `authorId`), real bookmark count (from `LocalArticleBloc`), horizontal scrollable publication cards with navigation to detail, and account management (logout).

**Product Impact:** Showing users their own content creates ownership and investment. "My Publications" transforms a reader into a creator.

### 6.5 Firestore Security Rules with Role-Based Access

**Functionality:** Comprehensive security rules implementing three access tiers:

- **Guest (anonymous):** Read all articles, read user profiles
- **Registered user:** All guest permissions + create articles, upload thumbnails
- **Article author:** All registered permissions + edit/delete own articles only

Cloud Storage rules restrict uploads to registered users, images only, max 10MB.

**Product Impact:** Security rules are invisible to users but critical to trust. A single unauthorized write or delete could damage the entire platform's credibility.

---

## 7. Extra Sections

### 7.1 Branching Strategy

Following Symmetry's Contribution Guidelines, development was done on a feature branch (`feat/firebase-articles-and-auth`) and merged via pull request to main. Commits follow the Conventional Commits specification:

- `feat:` for new features
- `fix:` for bug fixes
- `refactor:` for code restructuring
- `docs:` for documentation
- `chore:` for maintenance tasks

### 7.2 Architecture Compliance Checklist

| Rule                                                   | Status |
| ------------------------------------------------------ | ------ |
| Domain layer has zero Flutter/package imports          | ✅     |
| Presentation layer only imports from domain            | ✅     |
| Data layer only imports from domain                    | ✅     |
| Use cases implement `UseCase<Type, Params>`            | ✅     |
| Models extend entities                                 | ✅     |
| Repository implementations fulfill abstract contracts  | ✅     |
| BLoCs/Cubits are the only place that imports use cases | ✅     |
| Data sources are the only place that imports providers | ✅     |
| Shared/core imports respect layer hierarchy            | ✅     |

### 7.3 Project Structure (Final)

```
lib/
├── config/
│   ├── routes/routes.dart
│   └── theme/app_themes.dart
├── core/
│   ├── constants/
│   │   ├── colors.dart
│   │   ├── constants.dart
│   │   └── dimensions.dart
│   ├── resources/data_state.dart
│   ├── usecase/usecase.dart
│   └── utils/date_formatter.dart
├── shared/
│   ├── article/domain/entities/article.dart
│   └── widgets/
│       ├── app_cached_image.dart
│       ├── shimmer_box.dart
│       └── user_avatar.dart
├── features/
│   ├── auth/
│   │   ├── data/
│   │   │   ├── data_sources/firebase_auth_data_source.dart
│   │   │   ├── models/user_model.dart
│   │   │   └── repository/auth_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/user.dart
│   │   │   ├── params/
│   │   │   ├── repository/auth_repository.dart
│   │   │   └── use_cases/
│   │   └── presentation/
│   │       ├── bloc/
│   │       ├── screens/
│   │       └── widgets/
│   ├── daily_news/
│   │   ├── data/ (existing, minimally modified)
│   │   ├── domain/ (existing, import path updated)
│   │   └── presentation/
│   │       ├── bloc/ (existing)
│   │       ├── pages/ (modified for combined feed)
│   │       └── widgets/
│   │           ├── article_tile.dart (refactored)
│   │           ├── article_tile_skeleton.dart (new)
│   │           ├── featured_article_card.dart (new)
│   │           └── featured_article_skeleton.dart (new)
│   └── firebase_articles/
│       ├── data/
│       │   ├── data_sources/
│       │   │   ├── ai_article_data_source.dart
│       │   │   ├── firestore_article_data_source.dart
│       │   │   └── storage_data_source.dart
│       │   ├── models/firebase_article_model.dart
│       │   └── repository/firebase_article_repository_impl.dart
│       ├── domain/
│       │   ├── entities/generated_article.dart
│       │   ├── params/
│       │   ├── repository/firebase_article_repository.dart
│       │   └── use_cases/
│       └── presentation/
│           ├── bloc/
│           ├── screens/add_article_screen.dart
│           └── widgets/markdown_toolbar.dart
├── injection_container.dart
└── main.dart
```

### 7.4 Values Alignment

**Truth is King** — When the Firestore rules silently failed, I didn't assume the deploy worked because the CLI said "success." I debugged, found the mismatch, and fixed the root cause. When I noticed `DioError` was deprecated, I evaluated whether upgrading was worth the risk instead of blindly modernizing.

**Total Accountability** — Every commit in this project compiles and runs. I didn't leave broken states or "TODO: fix later" comments. When the `retrofit_generator` broke, I owned the problem and found a pragmatic solution instead of escalating it as a blocker.

**Maximally Overdeliver** — The assignment asked for a Firebase article upload feature. I delivered that plus authentication, AI content generation, AI image generation with model fallback, a complete UI redesign with animations, shimmer loading, Hero transitions, a profile screen with real data, and reusable components that would benefit the entire codebase.

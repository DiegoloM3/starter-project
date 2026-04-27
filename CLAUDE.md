# CLAUDE.md

## Behavioral Guidelines

Tradeoff: These guidelines bias toward caution over speed. For trivial tasks, use judgment.

### 1. Think Before Coding

Don't assume. Don't hide confusion. Surface tradeoffs.

Before implementing:

- State your assumptions explicitly. If uncertain, ask.
- If multiple interpretations exist, present them. Don't pick silently.
- If a simpler approach exists, say so. Push back when warranted.
- If something is unclear, stop. Name what's confusing. Ask.

### 2. Simplicity First

Minimum code that solves the problem. Nothing speculative.

- No features beyond what was asked.
- No abstractions for single-use code.
- No "flexibility" or "configurability" that wasn't requested.
- No error handling for impossible scenarios.
- If you write 200 lines and it could be 50, rewrite it.

Ask yourself: "Would a senior engineer say this is overcomplicated?" If yes, simplify.

### 3. Surgical Changes

Touch only what you must. Clean up only your own mess.

When editing existing code:

- Don't "improve" adjacent code, comments, or formatting.
- Don't refactor things that aren't broken.
- Match existing style, even if you'd do it differently.
- If you notice unrelated dead code, mention it. Don't delete it.

When your changes create orphans:

- Remove imports/variables/functions that YOUR changes made unused.
- Don't remove pre-existing dead code unless asked.

The test: Every changed line should trace directly to the user's request.

### 4. Goal-Driven Execution

Define success criteria. Loop until verified.

Transform tasks into verifiable goals:

- "Add validation" → "Write tests for invalid inputs, then make them pass"
- "Fix the bug" → "Write a test that reproduces it, then make it pass"
- "Refactor X" → "Ensure tests pass before and after"

For multi-step tasks, state a brief plan:

```
1. [Step] → verify: [check]
2. [Step] → verify: [check]
3. [Step] → verify: [check]
```

Strong success criteria let you loop independently. Weak criteria ("make it work") require constant clarification.

---

## Project Context

### App

**The Daily** — a news app where authenticated users can read curated news and writers can publish their own articles.

### Tech Stack

- **Framework:** Flutter
- **State management:** flutter_bloc (Cubits)
- **Backend:** Firebase (Auth, Firestore, Storage)
- **HTTP:** Retrofit + Dio (existing, for NewsAPI)
- **Local DB:** Floor/SQLite (existing, for saved articles offline)
- **DI:** get_it + injectable
- **Responsive sizing:** flutter_screenutil (design base: 375x812)
- **Navigation:** existing routes in `lib/config/routes/routes.dart`

### Architecture

Clean Architecture with feature-first folder structure. Three layers per feature:

```
lib/
  core/
    constants/       # API keys, app constants
    resources/       # DataState wrapper (Success/Error)
    usecase/         # Base UseCase abstract class
  features/
    daily_news/      # EXISTING — do not modify unless asked
    articles/        # NEW — all new functionality goes here
      data/
        datasources/
          local/
          remote/
        models/
        repositories/
      domain/
        entities/
        repositories/
        usecases/
      presentation/
        bloc/
        pages/
        widgets/
    auth/            # NEW — authentication feature
      data/
      domain/
      presentation/
  config/
    routes/
    theme/
  injection_container.dart
  main.dart
```

### Architecture Rules

- **Domain layer** has zero dependencies on Flutter, Firebase, or any external package. Pure Dart only.
- **Data layer** implements domain repository interfaces. All Firebase calls live here.
- **Presentation layer** communicates only with Cubits/Blocs. Never calls repositories or datasources directly.
- **Cubits** receive use cases via constructor injection (get_it). Never instantiate dependencies inside a Cubit.
- **Existing code** in `features/daily_news/` must not be modified unless explicitly asked.

### Data Layer Conventions

- All repository methods return `DataState<T>` (already defined in `core/resources/data_state.dart`).
- Models extend their corresponding entities and add `fromJson`/`toJson`/`fromFirestore`/`toFirestore`.
- Firestore document IDs are used as the entity `id` field.
- `authorName` and `authorPhotoURL` are denormalized into articles to avoid extra reads on feed rendering.
- `excerpt` is auto-generated from the first 160 characters of `body` at write time.
- `readTime` is calculated as `(wordCount / 200).ceil()` at write time.

### State Management Conventions

- Use **Cubits** for simple state (auth status, form state, profile).
- Use **Blocs** only if event complexity justifies it (existing Blocs in `daily_news` use this pattern).
- Every Cubit/Bloc state must have explicit loading, success, and error states.
- Emit loading state immediately before any async operation.

### Firebase Collections

```
users/{userId}
  savedArticles/{articleId}   ← subcollection

articles/{articleId}
```

Full schema documented in `backend/docs/DB_SCHEMA.md`.

### Storage Paths

```
media/articles/{articleId}    ← article thumbnails
media/avatars/{userId}        ← user profile photos
```

### Auth Flow

1. User opens app.
2. If not authenticated → Auth screen (Sign In / Sign Up / Forgot Password).
3. If authenticated but `onboardingCompleted == false` → Onboarding flow (3 screens).
4. If authenticated and `onboardingCompleted == true` → Home Feed.

### Role-Based UI

- `role == "reader"`: hide FAB, hide My Posts tab.
- `role == "writer"`: show FAB, show My Posts tab, can create/edit/delete articles.

### Naming Conventions

- Files: `snake_case.dart`
- Classes: `PascalCase`
- Variables/functions: `camelCase`
- Cubit states: `ArticleState`, `AuthState`, etc.
- Cubit events (if Bloc): `ArticleEvent`, `AuthEvent`, etc.
- Use cases: `GetArticlesUseCase`, `CreateArticleUseCase`, etc.
- Repository interfaces: `ArticleRepository`, `AuthRepository`
- Repository implementations: `ArticleRepositoryImpl`, `AuthRepositoryImpl`

### Key Dependencies (pubspec.yaml)

Already present:

- `flutter_bloc: ^8.1.2`
- `get_it: ^7.6.0`
- `retrofit + dio`
- `floor` (SQLite ORM)
- `firebase_core`, `cloud_firestore`, `firebase_storage`
- `cached_network_image`

To be added:

- `firebase_auth`
- `google_sign_in`
- `flutter_screenutil`
- `image_picker`
- `flutter_dotenv` (move API key out of constants.dart)
- `google_fonts` (Fraunces + Plus Jakarta Sans)

### Environment Variables

The NewsAPI key must be moved from `core/constants/constants.dart` to a `.env` file loaded with `flutter_dotenv`. Never hardcode API keys.

```
# .env
NEWS_API_KEY=your_key_here
```

`.env` must be added to `.gitignore`.

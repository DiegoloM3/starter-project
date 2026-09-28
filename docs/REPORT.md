# Report — Applicant Showcase App

**Applicant:** Brandon Cantú
**Role applied for:** Jr Mobile Engineer, Symmetry
**Time invested:** 72 hours

---

## 1. Introduction

I'm a Flutter developer with about 3 years of hands-on experience, coming from a background that started in C and C++, moved through web development, and settled on mobile. I've worked professionally with Flutter before (including a role at PHS), and I already knew Clean Architecture and BLoC conceptually going into this test — what I hadn't done before was take a project through a *complete* Firebase integration end-to-end (Firestore + Storage, real security rules, a real deployed backend) inside an existing codebase that wasn't mine to begin with.

My first feeling opening the repo was less "how do I learn Flutter" and more "how do I understand *this specific* codebase well enough to improve it responsibly." The README made it clear early on that the evaluation isn't just "did you add the feature" — it's whether I could read an existing architecture, find where it was inconsistent with its own rules, and make deliberate, explained decisions rather than either blindly following instructions or blindly imposing my own preferences. That framing shaped how I spent my 72 hours: a large portion of the time went into *reading* the existing code, the `ARCHITECTURE_VIOLATIONS.md`, `APP_ARCHITECTURE.md`, and `CODING_GUIDELINES.md` documents, and cross-checking my own code against them before writing anything new.

---

## 2. Learning Journey

I didn't need to learn Flutter, BLoC, or Clean Architecture from scratch — I already had working knowledge of all three. What this project pushed me to actually learn deeply, for the first time, was:

- **Firebase end-to-end**: not just calling Firestore from Flutter, but setting up a real project in the Firebase Console, understanding the split between *frontend* configuration (`flutterfire configure`, which wires the Dart code to a project) and *backend* configuration (`firebase login` / `firebase init` / `firebase deploy`, which pushes actual security rules to the cloud) — these are two genuinely separate workflows that I hadn't had to run through together before.
- **Firestore and Storage security rules syntax** — writing rules that validate field presence, types, and content, and discovering the hard way that Firestore field names are case-sensitive against the rules (more on this in Challenges).
- **`get_it`'s lifecycle registration options** (`registerFactory` vs. `registerSingleton` vs. `registerLazySingleton`) and how they interact with `flutter_bloc`'s `BlocProvider(create:)` vs. `BlocProvider.value()` — I understood the concepts in isolation before, but this project is where I ran into a real bug caused by mismatching them, which forced me to actually understand the mechanism, not just the syntax (see Challenges).
- **Dart 3's `sealed` classes** for exhaustive `switch` pattern matching over `Events`/`States`/`DataState` — I used this deliberately across the project so the compiler enforces handling every case.
- **Firestore's offline persistence model**, and specifically that it does *not* extend to Firebase Storage — this came up while reasoning about what happens to a delete/upload action when there's no internet connection.

For resources, I relied mostly on official documentation (Firebase docs, Flutter's own API deprecation notes) and, for two specific tooling bugs I hit, public GitHub issue trackers (the Firebase CLI `--only` flag bug, and a documented Firebase team response about why Storage has no offline queue).

---

## 3. Challenges Faced

I'm listing these roughly in the order I hit them, because several of them build on each other.

### 3.1 Getting the project to even compile
The starter project didn't run out of the box on my machine. In order: the bundled JDK was too new for the project's Gradle version; the project's pinned Kotlin version was below Flutter's current minimum; the `pubspec.yaml` SDK constraint was old enough that `pub get` resolved a `win32` version incompatible with my installed Dart; and once dependencies were modernized, `firebase_core`'s current version needed a newer Gradle/AGP/Kotlin trio than the project shipped with. Each fix surfaced the next one. I resolved this by isolating exactly which layer (JDK, Kotlin, Gradle, Dart SDK constraint) was the actual blocker at each step rather than guessing, and only changing what the error message pointed at.

### 3.2 A repeated architecture bug in the original codebase
After fixing a runtime crash in `RemoteArticlesState` (`props` forcing a null-check `!` on a field that a given subclass never populates), I later found the *exact same pattern* independently in `LocalArticlesState` and `LocalArticlesEvent` — a shared nullable field on the sealed base class, force-unwrapped in `props`. Rather than patch each occurrence individually, I standardized all `Events`/`States` in the project (6 files total, across both features) to a single pattern: each subclass declares its own non-nullable field and its own `props` override, with the sealed base holding nothing. This removes the entire bug category rather than the three instances I happened to find.

### 3.3 A real cross-screen state bug from a DI lifecycle mismatch
The "save article" button in the article detail screen never reflected whether an article was already saved. First cause: I was comparing full `Equatable` objects, and an article coming from the API (with a null `id`) never matched the same article once read back from SQLite (with an autogenerated `id`) — fixed by comparing on `url` instead, the one stable field between both sources.

Fixing that revealed a second, deeper problem: `LocalArticleBloc` was registered as `registerFactory`, so the saved-articles list screen and the article detail screen each held their *own* separate instance of the Bloc, with no communication between them. I changed the registration to a singleton so both screens share the same instance — which then caused a *third* bug, since `BlocProvider(create:)` automatically closes any Bloc it creates when its widget is disposed, and two screens sharing one singleton meant the first screen to be destroyed would close it and break the other. The fix was switching both screens to `BlocProvider.value()`, which never closes an instance it didn't create. I came out of this with a clear rule I applied consistently for the rest of the project: a Bloc genuinely shared across two or more simultaneously-relevant screens should be a singleton paired with `.value`; a Bloc exclusive to one screen should be a factory paired with `create:`. Mixing the two causes exactly the bug above.

### 3.4 Two Firebase bugs only visible through live end-to-end testing
- **Upload failing with "permission denied":** my model wrote the field as `thumbnailUrl` (camelCase), but the Firestore rule validated `thumbnailURL` — Firestore rules are case-sensitive against field names, so the validation silently never passed. Fixed by aligning the rule to the code (not the other way around, to avoid renaming across the whole app).
- **Storage image not deleting, function failing mid-way:** the storage rule used a combined `allow write` guard that reads `request.resource.contentType` — a field that simply doesn't exist on a `delete` operation, so the rule always threw. Fixed by splitting into `allow create, update: if <image validation>` and a separate unconditional `allow delete: if true`.

Both were invisible from reading the code alone; I only found them by actually running the full flow on a physical device.

### 3.5 Offline behavior asymmetry between Firestore and Storage
While reasoning about what should happen if a user tries to delete their own article with no internet connection, I confirmed (via Firestore's own documentation and a public statement from the Firebase engineering team) that Firestore has built-in offline persistence — writes and deletes queue locally and sync later — but Cloud Storage has no equivalent mechanism at all. This meant a naive "delete" implementation could report success (because the Firestore half succeeded locally) while silently leaving an orphaned image in Storage. I addressed the case where the operation genuinely can't proceed (upload, which needs Storage first) by checking connectivity before attempting it, and documented the remaining edge case (an orphaned image if a delete happens offline) as a known limitation rather than building a retry queue for it, given the time available.

### 3.6 A rate-limited demo API key, and removing my personal key before submission
The `newsAPIKey` hardcoded in the starter project's `constants.dart` turned out to be a public demo key from a tutorial, shared and exhausted by collective overuse. I initially suspected NewsAPI's known localhost-only restriction on its free plan (which applies to *web* apps checking an `Origin` header), but that theory didn't hold for a native mobile client. I confirmed the real cause with a temporary `print` of the response status code: a `429 Too Many Requests`. I registered my own free key at newsapi.org to keep developing.

Before submitting, I removed my personal key from `constants.dart` rather than commit it into a shared repository — **reviewers running this project will need to register their own free key at [newsapi.org](https://newsapi.org/register) and place it in `constants.dart`**, the same way the project's own README already asks for personal Firebase settings before the frontend will run. I've added the same kind of note to the project's main README so this isn't only documented here.

---

## 4. Reflection and Future Directions

Technically, this project is the first time I've owned a Firebase backend from schema design through deployed security rules through a working client, and the first time a DI lifecycle mismatch has actually broken something for me in a way I had to trace back to its root cause rather than patch around. Both of those are the kind of mistakes I don't think I'll make the same way again.

Professionally, the biggest shift for me was learning to *defend* architectural decisions with a documented reason rather than defaulting to either "the rules say so" or "I prefer it this way." A few times during this project I found a genuine contradiction between the project's own documents (for example, `ARCHITECTURE_VIOLATIONS.md` says the domain layer never imports from anywhere in the project, while `APP_ARCHITECTURE.md` explicitly allows domain to import from `core`/`shared`) — in cases like that, I picked the interpretation the existing code already followed, documented the contradiction rather than silently picking a side, and moved on instead of stalling. I also caught myself, more than once, about to apply a documented pattern (like nesting every shared widget under its own `data`/`domain`/`presentation` folders, per the letter of `APP_ARCHITECTURE.md`) in a place where it would have produced empty, purposeless folders — and chose instead to follow the *reasoning* behind the rule rather than its literal text, which I understood to be exactly what "Truth is King" is asking for.

If I had more time, in order of what I'd prioritize:
1. **Authentication** (even anonymous Firebase Auth), so articles could have a real author and delete/edit could be restricted to the owner instead of being open to anyone.
2. **Edit functionality** for a user's own articles — I scoped this out deliberately given time, but it's a natural next CRUD step.
3. **Real-time updates** (`.snapshots()`) instead of manual refetch-on-navigation, so a second device (or a future multi-user scenario) sees changes live.
4. **An offline retry queue** for Storage operations specifically, to close the orphaned-image edge case described above.
5. **A combined feed** mixing external news and user articles — I chose not to build this given the added complexity of merging two different Entity types and two async sources, but it's a reasonable product direction if the "citizen journalism" framing were taken further.

---

## 5. Proof of the Project

<img src="./assets/screenshot_1.jfif" width="300">
<img src="./assets/screenshot_2.jfif" width="300">
<img src="./assets/screenshot_3.jfif" width="300">
<img src="./assets/screenshot_4.jfif" width="300">
<img src="./assets/screenshot_5.jfif" width="300">
<img src="./assets/screenshot_6.jfif" width="300">
<img src="./assets/screenshot_7.jfif" width="300">
<img src="./assets/screenshot_8.jfif" width="300">
<img src="./assets/screenshot_9.jfif" width="300">
<img src="./assets/screenshot_10.jfif" width="300">
<img src="./assets/screenshot_11.jfif" width="300">
<img src="./assets/screenshot_12.jfif" width="300">
<img src="./assets/screenshot_13.jfif" width="300">
---

## 6. Overdelivery

### 6.1 New Features Implemented

Beyond the assigned functionality (uploading, storing, and viewing personal articles via Firestore/Storage), I implemented:

- **Search** — a client-side search over already-loaded articles (deliberately not hitting the API again, given I'd already run into NewsAPI's rate limit once), with a persisted recent-searches history (`SharedPreferences`) that can be replayed or cleared.
- **Connectivity detection** — a small service wrapping `connectivity_plus`, feeding a `Bloc` that drives a non-blocking banner shown app-wide when the device loses connection, plus connectivity checks before network-dependent actions (upload, delete) so failures are reported honestly instead of hanging.
- **Save/unsave directly from the Daily News list**, via a swipe gesture, not only from the article detail screen.
- **A reusable swipe-to-confirm gesture widget**, generalized enough to power "archive/unarchive" in Daily News, "remove" in Saved Articles, and "delete" in My Articles, with a configurable resistance, threshold, and confirmation callback — plus a one-time (persisted) "peek" animation on first launch, and a periodic repeat of that hint until the gesture is actually discovered, so the interaction is discoverable without an instructional label competing for space.
- **Delete for the user's own articles**, including cleanup of the associated Storage image, and a **"My Articles" viewing screen** — neither was strictly required by the assignment (which asked for upload + storage), but I judged the flow to feel incomplete without a way to see or remove what you'd published.
- **Dark mode**, fully implemented via a `ColorScheme`-based theme (the original project had none).
- **GoRouter migration**, replacing the original `Navigator` + `onGenerateRoute` + `dynamic` arguments with type-safe, declarative routing.
- **A full custom editorial visual redesign** — a deliberate "serious newspaper" direction (a warm paper/ink/oxblood palette, a serif masthead font paired with a sans-serif body, no shadows or rounded corners, a single accent color per screen) built to correct real code issues I found along the way (hardcoded colors ignoring the theme, a FAB with no theme applied, mixed Material/Cupertino widgets) rather than as an unscoped aesthetic pass.
- **Custom skeleton loading states** and a **custom loading indicator** (three squares lighting in sequence, evoking print-press type), built after evaluating existing pub.dev packages and finding none that fit the visual direction without looking like a generic app.
- **Image cropping on upload**, using `image_cropper`, so a user can adjust their photo before publishing rather than being stuck with whatever the gallery picker returned.
- **A native splash screen**, matching the app's own color system for both light and dark mode.

### 6.2 Prototypes Created

I didn't produce separate prototype artifacts (UML diagrams, standalone mockups) outside the working app itself. Instead, the architectural decisions documented in Section 7 below function as the equivalent of a living design prototype: each one (the DI lifecycle rules, the `shared`/`features`/`core` placement criteria, the sealed-class Events/States pattern) is a reusable pattern I'd apply again, not a one-off fix.

### 6.3 How Can You Improve This

Beyond the future directions already listed in Section 4, the overdelivery items themselves have room to grow: the search could be extended to also query the API directly for terms with no local matches; the swipe-to-confirm widget could support a "undo via snackbar" mode instead of always requiring a confirmation sheet, for less destructive actions; and the connectivity banner could queue a retry automatically when the connection returns, instead of requiring the user to manually retry.

---

## 7. Extra Sections

### 7.1 Architecture Violations Found in the Original Codebase, and What I Did About Each

| # | Issue | Decision |
|---|---|---|
| a | `ArticleModel` missing `toEntity()` (rule 1.3.2) | **Fixed** |
| b | `ArticleModel` missing `fromRawData` factory (rule 1.3.3) | **Fixed** — added `fromRawData`, delegating to the existing `fromJson` (kept intact, since Retrofit's generated code depends on it by name) |
| c | `ArticleRepositoryImpl` returning `ArticleModel` instead of `ArticleEntity` (rule 2.4.2) | **Fixed** |
| d | README recommends Cubit; project uses Bloc | **Kept Bloc**, for consistency with the existing codebase — this is a style recommendation, not an `ARCHITECTURE_VIOLATIONS.md` rule |
| e | `ARCHITECTURE_VIOLATIONS.md` (domain never imports from the project) contradicts `APP_ARCHITECTURE.md` (domain may import from `core`/`shared`) | **Documented, not "fixed"** — there's nothing to fix in a documentation contradiction; the existing code follows the permissive version, and my new feature follows the same |
| f | `presentation/pages/` folder name doesn't match `presentation/screens/` from the documented architecture | Old code left untouched; **my new feature uses `screens/`**, per the documented standard |

### 7.2 A Repeated Bug Pattern Found in the Original Code

Three separate files in the original `daily_news` feature (`RemoteArticlesState`, `LocalArticlesState`, `LocalArticlesEvent`) shared the same defect: a nullable field declared once on a sealed base class, force-unwrapped (`!`) inside a shared `props` getter — meaning any subclass that doesn't populate that specific field crashes at runtime with a null-check error. I fixed all three by moving to the standard `flutter_bloc` community pattern: each subclass owns its own non-nullable field and its own `props` override.

### 7.3 Firebase Findings Worth Knowing About

- Firestore rule validation is **case-sensitive** against field names — a mismatch between the model (`thumbnailUrl`) and the rule (`thumbnailURL`) fails silently with a generic permission error, not a field-name error.
- `allow write` in Storage rules applies to create, update, *and* delete — but `request.resource` doesn't exist on a `delete`, so any `write` rule that reads it will always throw on delete. Split delete into its own rule.
- Firestore has built-in offline persistence on mobile by default; **Cloud Storage does not**, and the Firebase team has stated this isn't planned. Any flow that touches both (as delete does here) needs to account for that asymmetry explicitly.
- A known Firebase CLI bug affects `firebase deploy --only firestore:rules,storage:rules` (it fails to find the storage target); the workaround is `--only firestore:rules,storage` (without `:rules` on the storage side).

### 7.4 Notable Architecture Decisions and the Reasoning Behind Them

**Should Blocs live in the DI container at all?**
I questioned this mid-project: Repositories, UseCases, and Services clearly belong in `get_it`, but should Blocs? One legitimate school of thought says no — only data/domain layers belong in a DI container, and Blocs should be constructed directly in the UI, pulling their already-injected UseCases from `get_it` inline, keeping the DI container scoped strictly to data/domain.

I ultimately kept Blocs registered in `get_it` (matching the original Symmetry codebase's own pattern), for three reasons: (1) it's what the reference code already did before I touched it; (2) it solved a real cross-screen state-sharing bug (see 3.3) with a one-word change (`registerFactory` → `registerSingleton`) rather than requiring a top-level `BlocProvider` wrapping the entire app in `main.dart`; (3) for this project's actual size and timeline, it was the more pragmatic path without sacrificing correctness. I don't consider the alternative wrong — I'm documenting the trade-off rather than treating either side as the only "correct" answer.

**Deciding `registerFactory` vs. `registerSingleton` vs. `registerLazySingleton`, systematically**
Rather than deciding case-by-case, I applied one guiding question across the whole service locator: *"Could the user finish a session without ever touching this?"* If yes → `registerLazySingleton` (construct it only if actually needed — e.g. everything under `user_articles`, which a user might never visit in a given session). If no, because it's used from the very first frame regardless of navigation (e.g. `daily_news`'s core dependencies, `ConnectivityBloc`) → `registerSingleton`. Anything exclusive to a single screen, meant to start fresh on every visit (e.g. `UploadUserArticleBloc`, `RemoteArticlesBloc`) → `registerFactory`.

**Where does `ConnectivityService` belong — a feature, `shared`, or `core`?**
`APP_ARCHITECTURE.md` states a "clean folder" always needs all 3 layers (data/domain/presentation), "no exceptions." But connectivity has no real business data to model — just a binary question to the OS. Forcing 3 layers onto it would mean empty, purposeless `data`/`domain` folders, which I judged to conflict with the project's own "Truth is King" value: following a rule's letter past the point it stops serving its purpose isn't the same as following its intent. I also confirmed it didn't need an abstract interface, the way my Repositories do — an interface earns its cost when there are multiple *legitimate* implementations worth swapping (real vs. mock); `ConnectivityService` is a thin wrapper over a third-party package with no business decision of its own worth mocking. It ended up split by role instead of forced into one folder: the service in `core/services/` (generic infrastructure, no business concept involved), its Bloc in `shared/bloc/` (genuinely used by more than one feature), its banner widget in `shared/widgets/` (purely visual, no data of its own).

**Two small "translator" screens instead of one generic wrapper**
When I generalized the article detail UI into a single shared `ArticleDetailsWidget` — after confirming `Image.network()` behaves identically whether the URL comes from NewsAPI or Firebase Storage, which is what made sharing it worthwhile at all — I considered two more "elegant"-looking alternatives: one universal screen branching on entity type via a type-switch, or passing the fully-built widget through the router's `extra`. Both felt more complex than the problem actually warranted. I built two small, near-identical "translator" screens instead, one per source Entity, each just mapping its own fields into the shared widget's plain parameters. Duplicating two simple, obvious files felt like the more honest choice than one clever abstraction covering both.

**What I deliberately did not build, and why**
Authentication, full CRUD (edit), real-time listeners, and drafts were all considered and explicitly scoped out. None are required by the assignment, and building any of them well — authentication in particular, since it would gate who can edit/delete what — would have taken time away from getting the required flow (upload → store → view) fully correct and verified end-to-end on a physical device. Given the time available, I chose to ship the required scope solid rather than a wider scope only partially verified.

**Why GoRouter over the original `Navigator` setup**
The original navigation used `Navigator.pushNamed` with `dynamic` arguments and manual casting at each destination screen — nothing guaranteed at compile time that the right type had actually been passed. I migrated to GoRouter because it gives type-safe route parameters, has native deep-linking support the original setup had none of, and is currently the pattern the Flutter team itself recommends for app-level routing. As part of the same change, route names became static constants on an `AppRouter` class instead of string literals repeated across the UI.

**Why a `GlobalTheme` class with a full `ColorScheme`, not loose theme functions**
The original `theme.dart` was two standalone functions with no dark mode at all. I replaced it with a class exposing a complete light and dark `ColorScheme`, built around a 60-30-10 color distribution (a dominant paper/ink pair, one deliberate accent). Two things drove this: dark mode is a real, missing piece of UX rather than a stylistic add-on, and centralizing color decisions inside one `ColorScheme`-based class means any widget can read `Theme.of(context).colorScheme` instead of hardcoding a color — which is exactly the kind of hardcoding I later found (and had to fix) in several widgets, described next.

### 7.5 The Visual Redesign: Why, and Why This Direction

The README is explicit that design isn't a central evaluation criterion, while still permitting overdelivery through improved prototypes. Rather than treat that as license for an unscoped aesthetic pass, I anchored the redesign to concrete problems I ran into while working on other things: hardcoded colors (`Colors.black87`, `Colors.grey[300]`) ignoring the `ColorScheme` I'd just built, a `FloatingActionButton` with no theme styling applied at all, and a mix of Material and Cupertino widgets (`CupertinoActivityIndicator` sitting next to Material's `CircularProgressIndicator`) producing visible inconsistency. Fixing those properly meant establishing an actual design system rather than patching each hardcoded value in isolation — so the redesign is framed here as a code-quality fix with a visual side effect, not the other way around.

For the direction itself, I chose a deliberate "serious newspaper" identity over a generic "modern app" look: a warm paper/ink/oxblood palette, a serif masthead paired with a sans-serif body, no shadows or rounded corners anywhere, and a rule that only one accent color appears per screen, in one deliberate place. This came directly from the app's own subject matter — it's a news app — rather than being an arbitrary style choice, and it gave me a concrete standard to hold every subsequent widget to. For example, when I needed a loading indicator, I evaluated several existing pub.dev packages first and rejected all of them for using colorful gradients or bouncing-dot animations that would have broken the flat, ink-on-paper language the rest of the app follows — and built a small custom one instead (three squares lighting in sequence, evoking print-press type).

# Discovery & Onboarding Notes

Project exploration findings from initial codebase setup. This document feeds into specs (Phase 0) and becomes raw material for `START_HERE.md`.

---

## Environment Setup

### Flutter & Dart Version

```bash
Flutter: 3.22.2 (stable)
Dart:    3.4.3
```

### Steps to Run

**Android:**
```bash
cd frontend
fvm use 3.22.2
fvm flutter pub get
fvm flutter run -d emulator-5554
```

**iOS (simulator):**
```bash
cd frontend
fvm use 3.22.2
flutter pub get --offline   # pub.dev may time out; packages are already cached
cd ios && pod install && cd ..
flutter run -d {DEVICE_UUID} 
```

> **Note:** `flutter pub get` (without `--offline`) hangs due to network timeouts on pub.dev. Always use `--offline` after the first successful pull.

### Dependencies Changed

- Updated Kotlin plugin: `1.6.10` → `1.8.10` in `android/settings.gradle` and `android/app/build.gradle`
- Added FVM pinning: `.fvmrc` → Flutter `3.22.2`
- Added `dependency_overrides` in `pubspec.yaml`: `win32: 5.5.4`
- Updated Dart SDK constraint: `sdk: ">=3.4.0 <4.0.0"`
- Upgraded: `path_provider` → `2.1.5`, `path_provider_android` → `2.2.10`, `sqflite` → `2.3.3+1`

### Blocking Issues Resolved

| Issue | Resolution |
|-------|-----------|
| Android build failed: Kotlin version mismatch | Updated Kotlin from 1.6.10 to 1.8.10 |
| `win32 5.3.0` `UnmodifiableUint8ListView` error | Added `win32: 5.5.4` override |
| Old `path_provider_android` v1 embedding API | Upgraded to 2.2.10 |
| Old `sqflite` plugin API | Upgraded to 2.3.3+1 |
| iOS — `FirebaseStorage-Swift.h` not found | Patched `Firebase.h` umbrella header guard in post_install; switched to `use_frameworks! :linkage => :static` |
| iOS — `FIRStorageObservableTask` unknown type | `use_modular_headers!` incompatible with firebase_storage 11.6.10; resolved by switching to `use_frameworks! :linkage => :static` |
| iOS — non-modular header inside framework module (Xcode 26) | Set `DEFINES_MODULE = NO` for `firebase_storage` and `cloud_firestore` pods in post_install; prevents Xcode 26 Explicit Module Builds from strictly enforcing module header purity |
| iOS — `flutter pub get` hangs (network) | Use `flutter pub get --offline`; packages already cached locally |

### Firebase Configuration

- `Firebase.initializeApp` is **not** called in `main.dart`.
- `google-services.json` is missing (expected — we create our own Firebase project).
- Firebase dependencies are present in `pubspec.yaml` but unused by current runtime.

---

## What Works

- [x] App compiles and launches (Android emulator)
- [x] App compiles and launches (iOS — iPhone 17 Pro Simulator, Xcode 26.2)
- [x] Home screen loads news articles from NewsAPI
- [x] Article detail screen opens from article tap
- [x] Saved articles screen with local persistence
- [x] FAB visible on home screen (unconnected)

---

## What Doesn't Work

| Issue | Location | Status |
|-------|----------|--------|
| Gradle/AGP/Kotlin below upcoming Flutter minimums | `android/gradle/` configs | Non-blocking warning |
| Firebase platform configs missing | `android/app/`, `ios/Runner/` | Expected — setup in Phase 2 |

---

## Architecture Violations Found

5 violations identified in the existing codebase:

| # | File | Violation | Rule |
|---|------|-----------|------|
| 1 | `data/models/article.dart` | Missing `toEntity()` | 1.3.2 |
| 2 | `data/models/article.dart` | `fromJson` should be `fromRawData` | 1.3.3 |
| 3 | `data/repository/article_repository_impl.dart` | Returns `List<ArticleModel>` not `List<ArticleEntity>` | 2.4.2 |
| 4 | `data/repository/article_repository_impl.dart` | Directly accesses `AppDatabase`, no `ArticleLocalDataSource` | 1.2.3 |
| 5 | `domain/entities/article.dart` | Imports `equatable` (external package in domain) | 2.1.1 |

No additional violations found beyond these 5.

---

## Open Questions (resolved)

- [x] **Firebase Auth for publishing?** → Yes, anonymous sign-in (see spec 002).
- [x] **Article visibility?** → Public to all users (see spec 002 + 003).
- [x] **Mix user articles with `daily_news` feed?** → No, separate "Community" tab (see spec 003).
- [ ] Figma design reference for the Add Article screen? *(still open — built with default Material widgets)*
- [ ] Upgrade Gradle/AGP/Kotlin to future-safe versions now? *(logged in `improvements.md` IMP-008)*

---

## Setup Steps (Draft for START_HERE.md)

### Prerequisites

- Flutter SDK >= 3.22.2 (pinned via FVM)
- Dart SDK (bundled with Flutter)
- Firebase CLI
- Android Studio or Xcode (for simulators)

### Quick Start

```bash
git clone <repo-url>
cd starter-project/frontend
fvm use 3.22.2
fvm flutter pub get
fvm flutter run
```

### Known Setup Issues

- Without the dependency upgrades listed above, Android build fails on plugin compatibility errors.
- Desktop targets (macOS, Linux, Windows) are not configured. Mobile only.
- `flutter pub get` may hang indefinitely due to pub.dev network timeouts — use `--offline` flag.
- iOS requires Xcode 26+ build fixes in `Podfile` (already applied). Do not remove the post_install hooks — they resolve Firebase/CocoaPods incompatibilities with Xcode 26.2 and the Explicit Module Builds system.

### iOS Podfile — Key Decisions

| Setting | Value | Reason |
|---------|-------|--------|
| `use_frameworks! :linkage => :static` | Required | `firebase_storage` 11.6.10 is incompatible with `use_modular_headers!` on Xcode 26 |
| `DEFINES_MODULE = NO` for `firebase_storage`, `cloud_firestore` | Required | Xcode 26 Explicit Module Builds strictly rejects `#import <Firebase/Firebase.h>` inside a framework module header |
| `DEFINES_MODULE = YES` + Swift header name for `FirebaseStorage` | Required | Ensures `FirebaseStorage-Swift.h` is generated so `Firebase.h` umbrella import succeeds |
| `Firebase.h` umbrella header patch | Required | Original guard `__has_include("FirebaseStorage-umbrella.h")` resolves true in static mode but the Swift header doesn't exist — tightened to also check `__has_include(<FirebaseStorage/FirebaseStorage-Swift.h>)` |

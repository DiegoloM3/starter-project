# Flutter Frontend
In this folder are all the [Flutter](https://docs.flutter.dev/) related files.
This folder is essentially the app and what the user sees. 
It has a dependency to the backend which ensures that there is data consistency.
You will be doing most of your work in this folder.

## Getting Started
Before you can run the app, you will need to add the Firebase options file to this project.
To do this, follow these steps:
1. Complete the [backend tutorial](../backend/README.md) to create a Firebase project which satisfies the requirements
2. Watch this [tutorial to setup Firebase for Flutter](https://youtu.be/Wa0rdbb53I8?list=PL4cUxeGkcC9j--TKIdkb3ISfRbJeJYQwC)
Once you have completed this appropriately, you can start to work with the project.

### Firebase configuration (already done in this repository)
The app is connected to the Firebase project `backend-news-symmetry` on Android and iOS.
`lib/firebase_options.dart`, `android/app/google-services.json`, `ios/Runner/GoogleService-Info.plist`
and `firebase.json` were generated with:
```
flutterfire configure --project=backend-news-symmetry --platforms=android,ios --android-package-name=com.example.news_app_clean_architecture --ios-bundle-id=com.example.newsAppCleanArchitecture --out=lib/firebase_options.dart
```
Firebase is initialized in `lib/injection_container.dart` (the composition root), so no presentation or domain code imports Firebase.

### Running against the real project or the local emulators
The project pins Flutter 3.27.4 with [FVM](https://fvm.app/) (`.fvmrc`).
```
fvm flutter run                                             # real Firebase project
fvm flutter run --dart-define=USE_FIREBASE_EMULATORS=true   # local Firebase Emulator Suite
```
In emulator mode, start the emulators and seed them first (see the [backend README](../backend/README.md)).
The app reaches your machine at `10.0.2.2` from the Android emulator and at `127.0.0.1` from the
iOS simulator (chosen automatically). On a physical Android device, forward the ports with
`adb reverse tcp:8080 tcp:8080 && adb reverse tcp:9199 tcp:9199` and add
`--dart-define=FIREBASE_EMULATOR_HOST=127.0.0.1`. Seeded thumbnails use the Android host by
default: for the iOS simulator seed with `EMULATOR_THUMBNAIL_HOST=127.0.0.1 npm run seed:emulator`.

### iOS
Requires Xcode and CocoaPods (the first build runs `pod install`, which takes a few minutes).
The minimum version is iOS 13. The simulator needs no signing; a physical iPhone needs your Apple
Developer team selected in `ios/Runner.xcworkspace` → *Signing & Capabilities*.
```
fvm flutter run -d "iPhone 17"
```

### Tests
```
fvm flutter test                  # unit and widget tests (test/ mirrors lib/)
```
`integration_test/` holds the end-to-end test of the publish journey (CODING_GUIDELINES 4.2).
It runs the real app on a device or emulator against the Firebase Emulator Suite, with the real
security rules. Only the system gallery is replaced by a test image. The test refuses to run
without the emulator flag, so it can never write to the real project.
```
cd ../backend && firebase emulators:start --only firestore,storage              # shell 1
fvm flutter test integration_test --dart-define=USE_FIREBASE_EMULATORS=true      # shell 2
```
Add `--dart-define=SLOW_MOTION=true` to pause after every step, e.g. to record a demo video.

### Demo video
`integration_test/demo_video_test.dart` is the script of `docs/media/demo.mp4`: the whole app,
step by step, with captions, against the emulators. It is skipped unless `RECORD_DEMO=true`, so
CI does not run it. To record it again on an iOS simulator (with the emulators running and seeded
with `EMULATOR_THUMBNAIL_HOST=127.0.0.1 npm run seed:emulator`):
```
tool/record_demo_video.sh <simulator UDID>
```
It records the simulator screen, pauses the emulators for the offline scene, and re-encodes the
video at 720 px wide with `tool/transcode_video.swift` (AVFoundation, no ffmpeg needed).

### Install the project dependencies (in pubspec.yaml)
`fvm flutter pub get` (it also generates the English and Spanish texts from `lib/l10n/*.arb`)
### Generated files of `daily_news` (Floor database and Retrofit)
The `*.g.dart` files are committed, so there is nothing to generate to run the app. The original
instructions ran `flutter pub run build_runner build --delete-conflicting-outputs`, but the pinned
`build_runner` 2.1.2 no longer compiles on Dart 3 (it uses the removed `NullThrownError`).
Regenerating them would require upgrading `build_runner`, `floor_generator` and
`retrofit_generator` together. They also generated the icons with `flutter_launcher_icons`, which
is not a dependency of the project; the app keeps Flutter's default icon.

### How can I best understand this project?
In order to best understand this project and its underlying intricacies, we recommend that you watch this tutorial: [Flutter Clean Architecture Tutorial](https://www.youtube.com/watch?v=7V_P6dovixg).
This tutorial **literally builds this project from the ground up** so we really recommend you watch it before developing.

Furthermore, we will now leave the index of this project with all the documentation that must be read before contributing to the frontend.

# Index
1. [Contribution Guidelines](../docs/CONTRIBUTION_GUIDELINES.md)
2. [Architecture Violations](../docs/ARCHITECTURE_VIOLATIONS.md)
3. [Code Quality Violations](../docs/CODING_GUIDELINES.md)
4. [Our App Architecture](../docs/APP_ARCHITECTURE.md)

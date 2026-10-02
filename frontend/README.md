# Flutter Frontend
In this folder are all the [Flutter](https://docs.flutter.dev/) related files.
This folder is essentially the app and what the user sees. 
It has a dependency to the backend which ensures that there is data consistency.
You will be doing most of your work in this folder.

## Getting Started
> **Just want to try the app?** You do not need your own Firebase project nor `firebase login`: the Firebase options
> of the project are already included and the app runs against the Firebase Local Emulator Suite. Install the
> [requirements](#requirements) and follow [Running the app with the Firebase Local Emulator Suite](#running-the-app-with-the-firebase-local-emulator-suite).

To connect the app to your own Firebase project instead, you will need to add its Firebase options file to this project.
To do this, follow these steps:
1. Complete the [backend tutorial](../backend/README.md) to create a Firebase project which satisfies the requirements
2. Watch this [tutorial to setup Firebase for Flutter](https://youtu.be/Wa0rdbb53I8?list=PL4cUxeGkcC9j--TKIdkb3ISfRbJeJYQwC).
Nowadays the Firebase options file is generated with the [FlutterFire CLI](https://firebase.google.com/docs/flutter/setup):
`flutterfire configure --project=<your-project-id> --platforms=android`
(it creates `lib/firebase_options.dart` and `android/app/google-services.json`).

Once you have completed this appropriately, you can start to work with the project.

### Requirements
- Flutter (tested with Flutter 3.47.5 / Dart 3.13.4)
- Android: an Android emulator or phone (tested on a Pixel 8, API 36)
- iOS (macOS only): Xcode with the iOS Simulator (tested with Xcode 26.3 on an iPhone 17 Pro, iOS 26.3)
- Java 21: the Firebase emulators require it (`firebase-tools` 14 or later) and it also builds the Android app
- Node.js and the Firebase CLI (`npm install -g firebase-tools`, tested with 15.32.0), to run the emulators

### Install the Project Dependencies (in pubspec.yaml)
`flutter pub get`
### Generate files for the local database (Floor):
`dart run build_runner build --delete-conflicting-outputs`
### App icon and splash screen
The app icon and the splash screen are already generated in `android/app/src/main/res` and `ios/Runner`, so nothing
needs to be done to run the app. They come from the images in `assets/branding` (the Daily News logo of the app design) and are generated
with two development tools, configured in `flutter_launcher_icons.yaml` and `flutter_native_splash.yaml`. After changing
those images or settings, generate them again:
```
dart run flutter_launcher_icons
dart run flutter_native_splash:create
```
The images themselves are drawn by `tool/render_branding.swift` (macOS): `swift tool/render_branding.swift assets/branding`.

### Running the app with the Firebase Local Emulator Suite
Journalists sign in with Firebase Authentication (email and password), their articles are stored in Firestore and their
thumbnails in Cloud Storage. Since Cloud Storage requires
the Blaze plan on a real Firebase project (see [backend/README.md](../backend/README.md)), the app connects to the
**Firebase Local Emulator Suite by default**:
1. From the `backend` folder, install its dependencies once (`npm install`) and start the emulators:
   `npm run emulators`. No Firebase account is needed: the warnings "You are not currently authenticated" and, the
   first time, "Could not find import/export metadata file" are expected. The data is kept between runs when the
   emulators are stopped with `Ctrl+C`.
2. Optionally, in another terminal of the `backend` folder, create the demo accounts and articles: `npm run seed`.
3. Android only, with the Android emulator (or a phone over USB) running: `npm run android:connect` (from the `backend` folder;
   it runs `adb reverse` for Authentication, Firestore and Storage). On the Android emulator, FlutterFire already reaches the
   emulators of this computer, but this is still needed to load the thumbnails created by `npm run seed`
   (their URLs point to 127.0.0.1); on a phone it is always needed. Run it again every time the device restarts.
   The iOS Simulator shares the network of this computer, so it reaches the emulators directly.
4. From this folder, after installing the dependencies (see above): `flutter run` and choose the device (on Android,
   `flutter run --release` to record videos: the debug build is slower; the iOS Simulator runs debug builds). The first
   iOS build downloads the Firebase SDK with Swift Package Manager and takes a few minutes.
5. Create an account from the welcome screen, or log in with a demo account created by `npm run seed`
   (see [backend/README.md](../backend/README.md)). The session is kept on the phone, so you only log in once.

Options (`--dart-define`):
- `USE_FIREBASE_EMULATORS=false`: use the real Firebase project instead of the emulators (Cloud Storage requires Blaze).
- `FIREBASE_EMULATORS_HOST=<ip>`: reach emulators running on another computer of the network.

### Running the tests
```
flutter test
```
The `test` folder mirrors `lib`, with one `{fileName}_test.dart` per file. The exception is `test/architecture`, which
checks the whole of `lib` against [Our App Architecture](../docs/APP_ARCHITECTURE.md) and the
[Architecture Violations](../docs/ARCHITECTURE_VIOLATIONS.md): the folders of each clean folder, what each layer may
import, and the shape of models, repositories and use cases. Each test is named after the rule it checks (for example
"1.1.2 the data layer does not import use_cases") and lists every file that breaks it.

### How can I best understand this project?
In order to best understand this project and its underlying intricacies, we recommend that you watch this tutorial: [Flutter Clean Architecture Tutorial](https://www.youtube.com/watch?v=7V_P6dovixg).
This tutorial **literally builds this project from the ground up** so we really recommend you watch it before developing.

Furthermore, we will now leave the index of this project with all the documentation that must be read before contributing to the frontend.

# Index
1. [Contribution Guidelines](../docs/CONTRIBUTION_GUIDELINES.md)
2. [Architecture Violations](../docs/ARCHITECTURE_VIOLATIONS.md)
3. [Code Quality Violations](../docs/CODING_GUIDELINES.md)
4. [Our App Architecture](../docs/APP_ARCHITECTURE.md)

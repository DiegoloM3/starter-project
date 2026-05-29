# Flutter Frontend
In this folder are all the [Flutter](https://docs.flutter.dev/) related files.
This folder is essentially the app and what the user sees. 
It has a dependency to the backend which ensures that there is data consistency.
You will be doing most of your work in this folder.

## Getting Started
Before you can run the app, you must connect it to a Firebase project. The Firebase
config files are **not committed** — they hold your project/app IDs, so every developer
generates their own. To do this, follow these steps:

1. Complete the [backend tutorial](../backend/README.md) to create a Firebase project which satisfies the requirements.
2. Install the FlutterFire CLI (one-time): `dart pub global activate flutterfire_cli`.
3. From this `frontend/` folder, run `flutterfire configure` and select your project. This generates the config the app needs:
   - `lib/firebase_options.dart` — consumed by `Firebase.initializeApp()`
   - `firebase.json` — FlutterFire platform/app mapping
   - `android/app/google-services.json` and `ios/Runner/GoogleService-Info.plist`

   All four are **gitignored** (see the root `.gitignore`) and must never be committed.
4. For context, this [tutorial to setup Firebase for Flutter](https://youtu.be/Wa0rdbb53I8?list=PL4cUxeGkcC9j--TKIdkb3ISfRbJeJYQwC) walks through the same flow.

Once you have completed this appropriately, you can start to work with the project.

### Generate files for routing, di etc.:
`flutter pub run build_runner build --delete-conflicting-outputs`
### Generate the icons:
`flutter pub run flutter_launcher_icons`
### Install the Project Dependencies (in pubsec.yaml)
`flutter pub get`

### Run the app (NewsAPI key required)
The NewsAPI key is read at compile time from the `NEWS_API_KEY` dart-define. Copy
`env.example.json` to `env.json`, fill in your key, then run with the file:

`flutter run --dart-define-from-file=env.json`

`env.json` is gitignored — never commit it. In VS Code, use the bundled **frontend (dev)**
launch configuration, which passes the same flag. Without the key the NewsAPI request
returns 401 and the feed shows only locally created articles.

### How can I best understand this project?
In order to best understand this project and its underlying intricacies, we recommend that you watch this tutorial: [Flutter Clean Architecture Tutorial](https://www.youtube.com/watch?v=7V_P6dovixg).
This tutorial **literally builds this project from the ground up** so we really recommend you watch it before developing.

Furthermore, we will now leave the index of this project with all the documentation that must be read before contributing to the frontend.

# Index
1. [Contribution Guidelines](./docs/CONTRIBUTION_GUIDELINES.md)
2. [Architecture Violations](./docs/ARCHITECTURE_VIOLATIONS.md)
3. [Code Quality Violations](./docs/CODING_GUIDELINES.md)
4. [Our App Architecture](./docs/APP_ARCHITECTURE.md)

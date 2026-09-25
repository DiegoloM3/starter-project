# Flutter Frontend

## Running this submission
Built and tested with **Flutter 3.41.4 (Dart 3.11.1)** on Android. iOS was never configured for this project (no iOS Firebase app), so run it on an Android device or emulator.

No Firebase setup is needed to run it: `android/app/google-services.json` and `lib/firebase_options.dart` are included and point at the author's Firebase project (`pruebasymmetry`). Firebase client config is public by design; access is controlled by `backend/firestore.rules` and `backend/storage.rules`.

**One required step before it builds at all.** `pubspec.yaml` bundles `.env` as a Flutter asset, and `.env` is deliberately gitignored (see below) -- so on a fresh clone, `flutter run`/`flutter build` fails outright (not just "News tab empty") until that file exists. Copy the template and fill it in first:

```
cd frontend
cp .env.template .env   # or copy/paste it by hand -- same folder, new name
```

Then open `.env` and set `NEWS_API_KEY` to either your own free key from [newsapi.org/register](https://newsapi.org/register), or the author's below, to skip that signup:

```
NEWS_API_KEY=8ea849edf7954b52bdda1d5439118f69
```

An API key doesn't normally belong in a README, but this one is free-tier and rate-limited (100 requests/day), so the actual risk of putting it here is someone else spending that quota, not anything sensitive -- the point is specifically so you don't have to sign up for your own just to grade this. It's still never hardcoded in source or committed to git (see `lib/core/constants/constants.dart` and `.gitignore`) -- `.env` itself never goes into git; this README is the one deliberate, explained place its value is shared instead.

Now the normal commands work:

```
flutter pub get
flutter run
flutter test   # unit tests, mirrored under test/ like lib/
```

If the day's 100 requests happen to already be spent by the time you run this (100 is not a lot, and this key was reused across a lot of manual testing while building the News tab), the app says so directly -- "Today's news limit was reached", not "Offline" -- rather than looking broken; see `docs/REPORT.md`, Challenges, for the full story of that distinction. `frontend/.env.template` is committed so you (or anyone) can swap in a different key at any time, no code changes needed.

**Accounts.** The app starts every install as a guest, which works on any build. From "My Articles" a guest can connect Google or email/password:
- **Email/password** works on any build.
- **Google** checks the app's signing certificate, so it only works on builds signed with a key registered in the Firebase project (the author's debug key is). To try it from your own build, add your debug key's SHA-1 in Firebase → Project settings → Android app.
- Using your own Firebase project instead? Enable Anonymous, Email/Password and Google under Authentication → Sign-in method.

---

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

### Generate files for routing, di etc.:
`flutter pub run build_runner build --delete-conflicting-outputs`
### Generate the icons:
`flutter pub run flutter_launcher_icons`
### Install the Project Dependencies (in pubsec.yaml)
`flutter pub get`

### How can I best understand this project?
In order to best understand this project and its underlying intricacies, we recommend that you watch this tutorial: [Flutter Clean Architecture Tutorial](https://www.youtube.com/watch?v=7V_P6dovixg).
This tutorial **literally builds this project from the ground up** so we really recommend you watch it before developing.

Furthermore, we will now leave the index of this project with all the documentation that must be read before contributing to the frontend.

# Index
1. [Contribution Guidelines](./docs/CONTRIBUTION_GUIDELINES.md)
2. [Architecture Violations](./docs/ARCHITECTURE_VIOLATIONS.md)
3. [Code Quality Violations](./docs/CODING_GUIDELINES.md)
4. [Our App Architecture](./docs/APP_ARCHITECTURE.md)

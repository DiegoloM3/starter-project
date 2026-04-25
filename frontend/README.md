# Flutter Frontend

## What's New

This project extends the original News App with:

- **Authentication** (Register, Sign In, Guest mode)
- **Firebase Articles** (Create and publish articles with Firestore + Cloud Storage)
- **AI Content Generation** (Article text and thumbnail generation powered by Gemini)
- **Enhanced UI** (Shimmer loading, Hero transitions, SliverAppBar animations)

For a complete overview of all changes, read the [Project Report](./docs/REPORT.md).

## Getting Started

### Prerequisites

- Flutter SDK (3.x or higher)
- Firebase CLI (`npm install -g firebase-tools`)
- A Firebase project with **Authentication**, **Firestore**, and **Cloud Storage** enabled
- A [Google AI Studio](https://aistudio.google.com/apikey) API key for Gemini

### 1. Firebase Setup

1. Create a Firebase project and enable:
   - **Authentication** (Email/Password + Anonymous sign-in)
   - **Cloud Firestore**
   - **Cloud Storage**
2. Run FlutterFire CLI to generate config:

```bash
   flutterfire configure
```

### 2. Gemini API Key

Add your Gemini API key in `lib/core/constants/constants.dart`:

```dart
const String geminiApiKey = 'YOUR_API_KEY';
```

### 3. Deploy Firestore & Storage Rules

```bash
cd backend
firebase deploy --only firestore:rules,storage
```

### 4. Run the App

```bash
cd frontend
flutter pub get
flutter run
```

> **Note:** The `build_runner` step from the original README is no longer needed. The generated `.g.dart` files are already included in the repository.

> **Note (Android):** If you encounter build errors, verify that your `android/settings.gradle` uses AGP 8.9.1+ and Kotlin 2.1.0+, and that `android/app/build.gradle` includes `ndkVersion = "28.2.13676358"`.

## Project Structure

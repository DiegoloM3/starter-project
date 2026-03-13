# Environment Configuration Guide

This document explains how to configure environment variables for the News App.

## Overview

The app uses build-time environment variables injected via `--dart-define` flags. This keeps sensitive data out of the repository while allowing easy configuration for different environments.

---

## Required Services

### 1. Cloudinary (Image Storage)

We use Cloudinary for article cover images and user profile pictures with global CDN delivery.

**Setup Steps:**
1. Create a free account at [cloudinary.com](https://cloudinary.com)
2. Get your **Cloud Name** from the Dashboard
3. Go to **Settings → Upload → Upload Presets**
4. Click **Add upload preset**
5. Configure:
   - **Preset name:** Custom name (e.g., `xg3gxg9w`)
   - **Signing Mode:** `Unsigned`
   - **Folder:** `articles` (for article images)
6. Save the preset name

**Required Variables:**
| Variable | Description |
|----------|-------------|
| `CLOUDINARY_CLOUD_NAME` | Your cloud name from Dashboard |
| `CLOUDINARY_UPLOAD_PRESET` | Your unsigned upload preset name |

---

### 2. Firebase

Firebase handles authentication (Firebase Auth) and database (Firestore).

**Setup Steps:**
1. Create a project at [Firebase Console](https://console.firebase.google.com)
2. Enable **Firestore Database** (start in test mode)
3. Enable **Authentication** → **Email/Password** provider
4. Install FlutterFire CLI:
   ```bash
   dart pub global activate flutterfire_cli
   ```
5. Configure Firebase for Flutter:
   ```bash
   cd frontend
   flutterfire configure
   ```
   This generates `lib/firebase_options.dart` automatically.

6. Deploy Firestore security rules:
   ```bash
   cd backend
   firebase deploy --only firestore
   ```

**Note:** Firebase configuration is primarily handled by the auto-generated `firebase_options.dart` file. Optional overrides are available via environment variables.

---

## Running the App

### Development

```bash
cd frontend

flutter run \
  --dart-define=NEWS_API_KEY=your_news_api_key \
  --dart-define=CLOUDINARY_CLOUD_NAME=your_cloud_name \
  --dart-define=CLOUDINARY_UPLOAD_PRESET=symmetry_news_unsigned \
  --dart-define=ENV=development
```

### Production

```bash
flutter run --release \
  --dart-define=NEWS_API_KEY=your_news_api_key \
  --dart-define=CLOUDINARY_CLOUD_NAME=your_cloud_name \
  --dart-define=CLOUDINARY_UPLOAD_PRESET=symmetry_news_unsigned \
  --dart-define=ENV=production
```-d <device_id> \
  --dart-define=CLOUDINARY_CLOUD_NAME=your_cloud_name \
  --dart-define=CLOUDINARY_UPLOAD_PRESET=your_upload_preset
```

Example:
```bash
flutter run -d emulator-5554 \
  --dart-define=CLOUDINARY_CLOUD_NAME=dgi3u8chm \
  --dart-define=CLOUDINARY_UPLOAD_PRESET=xg3gxg9w
```

### Production

```bash
flutter run --release -d <device_id> \
  --dart-define=CLOUDINARY_CLOUD_NAME=your_cloud_name \
  --dart-define=CLOUDINARY_UPLOAD_PRESET=your_upload_preset
```

### Using a Shell Script (Recommended)

Create a `run_dev.sh` script for convenience:

```bash
#!/bin/bash
# run_dev.sh - Run app in development mode

DEVICE_ID=${1:-emulator-5554}

flutter run -d $DEVICE_ID \
  -CLOUDINARY_CLOUD_NAME` | **Yes** | - | Cloudinary cloud name |
| `CLOUDINARY_UPLOAD_PRESET` | **Yes** | - | Unsigned upload preset name
Make it executable and run:
```bash
chmod +x run_dev.sh
./run_dev.sh                    # Uses default emulator-5554
./run_dev.sh chrome             # Runs on Chrome
./run_dev.sh <your-device-id>   # Runs on specific device
### Optional Firebase Overrides

These are optional and only needed if you want to override `firebase_options.dart`:

| Variable | Description |
|----------|-------------|
| `FIREBASE_API_KEY` | Firebase API Key |
| `FIREBASE_PROJECT_ID` | Firebase Project ID |
| `FIREBASE_AUTH_DOMAIN` | Firebase Auth Domain |
| `FIREBASE_MESSAGING_SENDER_ID` | Firebase Messaging Sender ID |
| `FIREBASE_APP_ID` | Firebase App ID |

---

## For Reviewers

To run this project:

1. **Clone the repository**
   ```bash
   git clone <repo-url>
   cd starter-project
   ```

2. **Set up Firebase**
   ```bash
   
   Follow the prompts to select your Firebase project.

3. **Set up Cloudinary**
   - Create account at [cloudinary.com](https://cloudinary.com)
   - Note your **Cloud Name** from the dashboard
   - Go to Settings → Upload → Upload Presets
   - Create an **unsigned upload preset**
   - Note the preset name

4. **Deploy Firebase Security Rules**
   ```bash
   cd backend
   firebase deploy --only firestore:rules
   ```

5. **Get Dependencies**
   ```bash
   cd frontend
   flutter pub get
   ```

6. **Run the app**
   ```bash
   cd frontend
   
   # Replace with your actual values
   flutter run -d emulator-5554 \
     --dart-define=CLOUDINARY_CLOUD_NAME=your_cloud_name \
     --dart-define=CLOUDINARY_UPLOAD_PRESET=your_upload_prese
     --dart-define=NEWS_API_KEY=your_news_api_key \
     --dart-define=CLOUDINARY_CLOUD_NAME=your_cloud_name \
     --dart-define=ENV=development
   ```-d <device_id> \
  --dart-define=CLOUDINARY_CLOUD_NAME=your_cloud_name \
  --dart-define=CLOUDINARY_UPLOAD_PRESET=your_preset

## Troubleshooting

### "Missing required environment variables" Error

Make sure you're passing the `--dart-define` flags when running:
```bash
flutter run \
  --dart-define=NEWS_API_KEY=your_key \
  --dart-define=CLOUDINARY_CLOUD_NAME=your_name
```

### Firebase not configured

Run `flutterfire configure` to generate `firebase_options.dart`.

### Cloudinary upload fails

1. Verify your cloud name is correct
2. Ensure the upload preset exists and is set to "Unsigned"
3. Check that the preset folder matches your configuration
✅ Never commit actual Cloudinary credentials to the repository
- ✅ Use `--dart-define` for build-time injection of sensitive data
- ✅ Firebase credentials in `firebase_options.dart` are safe to commit (they're client-side keys protected by Firebase Security Rules)
- ✅ Cloudinary unsigned upload presets are safe for client-side use (configure allowed folders and file types in Cloudinary settings)
- ⚠️ For production, consider server-side image uploads with signed requests for additional security

## Additional Notes

### Why No NEWS_API_KEY?

This app focuses on **user-generated content** (articles created by authenticated users), not fetching external news. The `daily_news` feature exists in the codebase but is not actively used in the main article publishing workflow.

### Cloudinary vs Firebase Storage

We chose Cloudinary over Firebase Storage because:
- Global CDN with faster image delivery
- Advanced image transformations and optimization
- Generous free tier (25GB storage, 25GB bandwidth/month)
- Simpler integration with unsigned uploads
- Better scalability for high-traffic scenarios

- Never commit actual credentials to the repository
- Use `--dart-define` for build-time injection
- The `.env.example` file shows required variables without actual values
- Firebase credentials in `firebase_options.dart` are safe to commit (they're restricted by Firebase Security Rules)

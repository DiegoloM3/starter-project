#!/bin/sh
# Run the app with environment variables loaded from env.json.
#
# Usage:
#   sh scripts/run.sh [flutter run args]
#
# First-time setup:
#   1. cp env.example.json env.json
#   2. Edit env.json to fill in your local values (NEWS_API_KEY, etc.)
#
# Prerequisites:
#   - frontend/lib/firebase_options.dart must exist (run flutterfire configure)
#   - frontend/android/app/google-services.json must exist
#   - frontend/ios/Runner/GoogleService-Info.plist must exist (iOS builds)
set -e

if [ ! -f env.json ]; then
  echo "ERROR: env.json not found in $(pwd)."
  echo "First-time setup: cp env.example.json env.json and fill in values."
  exit 1
fi

flutter run --dart-define-from-file=env.json "$@"

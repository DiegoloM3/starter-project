#!/usr/bin/env bash
# Records the demo video docs/media/demo.mp4 on an iOS simulator.
#
# It runs integration_test/demo_video_test.dart (the whole app, step by step, with captions)
# against the Firebase Emulator Suite and records the simulator screen while the demo plays.
# For the offline scene it pauses the emulators (SIGSTOP) and resumes them (SIGCONT) when the
# demo says so, so the server really stops answering.
#
# Before running it:
#   cd backend && npm run emulators                                    # shell 1
#   cd backend && EMULATOR_THUMBNAIL_HOST=127.0.0.1 npm run seed:emulator  # once
# Then, from frontend/:
#   tool/record_demo_video.sh <simulator UDID>                         # xcrun simctl list devices booted
set -euo pipefail

udid="${1:?Usage: tool/record_demo_video.sh <UDID of a booted iOS simulator>}"
photo="${DEMO_PHOTO:-$HOME/Library/Developer/CoreSimulator/Devices/$udid/data/Media/DCIM/100APPLE/IMG_0001.JPG}"
output="$(cd "$(dirname "$0")/../.." && pwd)/docs/media/demo.mp4"
work="$(mktemp -d)"
log="$work/demo.log"
raw="$work/demo-raw.mp4"

[ -f "$photo" ] || { echo "Demo photo not found: $photo (set DEMO_PHOTO)"; exit 1; }

fvm flutter test integration_test/demo_video_test.dart -d "$udid" \
  --dart-define=USE_FIREBASE_EMULATORS=true \
  --dart-define=RECORD_DEMO=true \
  --dart-define=DEMO_PHOTO="$photo" > "$log" 2>&1 &
test_pid=$!

wait_for() {
  until grep -q "$1" "$log"; do
    kill -0 "$test_pid" 2>/dev/null || { cat "$log"; echo "The demo stopped before $1"; exit 1; }
    sleep 0.2
  done
}

emulator_pids=$(pgrep -f "cloud-firestore-emulator|firebase.*emulators:start" || true)
[ -n "$emulator_pids" ] || { echo "Start the Firebase emulators first (see above)"; kill "$test_pid"; exit 1; }
# Never leave the emulators paused, whatever happens.
trap 'kill -CONT $emulator_pids 2>/dev/null || true' EXIT

wait_for DEMO_START
xcrun simctl io "$udid" recordVideo --codec=h264 --force "$raw" &
recorder_pid=$!
wait_for DEMO_OFFLINE
kill -STOP $emulator_pids
wait_for DEMO_ONLINE
kill -CONT $emulator_pids
wait_for DEMO_END
kill -INT "$recorder_pid"
wait "$recorder_pid" || true
wait "$test_pid"

# The raw recording is full resolution (~85 MB); 720 px wide at 1 Mbps stays sharp at ~20 MB.
swift "$(dirname "$0")/transcode_video.swift" "$raw" "$output" 720 1000
echo "Saved $output ($(du -h "$output" | cut -f1)); raw recording kept in $raw"

# Delivery evidence

This directory contains the small set of evidence needed to review the Case Study Symmetry delivery:
three Figma visual references and one continuous two-browser recording. The recording exercises the local Firebase emulators; it is not a production deployment or native-device build.

## Evidence manifest

| File | Type | Dimensions / duration | Status |
| --- | --- | --- | --- |
| [`figma-home.jpg`](figma-home.jpg) | `image/jpeg` | 1280x720 | Figma visual reference: home/feed layout and publish action |
| [`figma-editor-empty.jpg`](figma-editor-empty.jpg) | `image/jpeg` | 1280x720 | Figma visual reference: empty editor state |
| [`figma-editor-filled.jpg`](figma-editor-filled.jpg) | `image/jpeg` | 1280x720 | Figma visual reference: editor with selected image |
| [`two-browser-live-demo.mp4`](two-browser-live-demo.mp4) | `video/mp4` | 1920x1246, 75.18s | Continuous local-emulator demonstration of crop, publish, realtime likes/comments, and sharing |

The removed numbered browser captures, production snapshots, and sampled walkthrough were historical or duplicate evidence. They are intentionally not part of the delivery proof set.

## Integrity checks

Run from the repository root:

```bash
shasum -a 256 docs/proof/figma-home.jpg
shasum -a 256 docs/proof/figma-editor-empty.jpg
shasum -a 256 docs/proof/figma-editor-filled.jpg
shasum -a 256 docs/proof/two-browser-live-demo.mp4
```

Expected SHA-256 values:

```text
ca0ae707c7719811fafa4359581d4f28ccfb5d7cfd89918b03cf19a24fad5f40  docs/proof/figma-home.jpg
638c1ea31251a988767abe5beae5c4e9129a998a6a2719268f1bdf9bde197741  docs/proof/figma-editor-empty.jpg
5a74f51c1d6a3e00ff566799dfaf2f97c57f7d4a2df23a9a7c7b23963124f0b8  docs/proof/figma-editor-filled.jpg
23660859b5c62eb0c4517e9da161545f5a4f8ee857f399c3fe06f1403391da2d  docs/proof/two-browser-live-demo.mp4
```

## Reproduce the recording scenario

1. Start the Auth, Firestore, and Storage emulators using `backend/firebase.json`.
2. Run the Flutter web app in emulator mode.
3. Open two independent browser windows at the Community feed.
4. Authenticate both users, publish an article with a cropped image, and open the same detail route in both windows.
5. Like and comment from either window and verify that both views update from Firestore snapshots.
6. Use the share action and verify the native/Web Share path or browser fallback.

The video is supporting evidence only. Automated Flutter and emulator security tests remain the authoritative verification.
